defmodule BattleshipEngine.Board do
  alias BattleshipEngine.Vehicle
  def new(), do: %{}

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

  defp overlaps_existing_vehicle?(board, new_key, new_vehicle) do
    Enum.any?(board, fn {key, vehicle} ->
      key != new_key and Vehicle.overlaps?(vehicle, new_vehicle)
    end)
  end

end
