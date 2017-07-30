defmodule BattleshipEngine.Board do
  alias BattleshipEngine.{Vehicle, Coordinate}
  def new(), do: %{}

  def guess(board, %Coordinate{} = coordinate) do
    board
    |> check_all_vehicles(coordinate)
    |> guess_response(board)
  end

  def position_vehicle(board, key, %Vehicle{} = vehicle) do
    case overlaps_existing_vehicle?(board, key, vehicle) do
      true  -> {:error, :overlapping_vehicle}
      false -> Map.put(board, key, vehicle)
    end
  end

  def all_vehicles_positioned?(board) do
    Vehicle.types()
    |> Enum.all?(&(Map.has_key?(board, &1)))
  end

  defp check_all_vehicles(board, coordinate) do
    Enum.find_value(board, :miss, fn {key, vehicle} ->
      case Vehicle.guess(vehicle, coordinate) do
        {:hit, vehicle} -> {key, vehicle}
        :miss          -> false
      end
    end)
  end

  defp guess_response(:miss, board) do
    {:miss, :none, :no_win, board}
  end

  defp guess_response({vehicle_key, vehicle}, board) do
    {:hit, sunk_check?(board, vehicle_key), win_check?(board), %{board | vehicle_key => vehicle}}
  end

  defp overlaps_existing_vehicle?(board, new_key, new_vehicle) do
    Enum.any?(board, fn {key, vehicle} ->
      key != new_key and Vehicle.overlaps?(vehicle, new_vehicle)
    end)
  end

  defp win_check?(board) do
    case all_sunk?(board) do
      true -> :win
      false -> :no_win
    end
  end

  defp all_sunk?(board) do
    Enum.all?(board, fn ({_k,v}) ->Vehicle.sunk?(v) end)
  end

  defp sunk_check?(board, key) do
    case sunk?(board, key) do
      true -> key
      false -> :none
    end
  end

  defp sunk?(board, key) do
    board
    |> Map.fetch!(key)
    |> Vehicle.sunk?
  end
end
