defmodule BattleshipEngine.Vehicle do
  alias BattleshipEngine.{Vehicle, Coordinate}
  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]

  def new(vehicle_name, %Coordinate{} = upper_left) do
    with [_|_] = offsets <- offsets(vehicle_name),
         %MapSet{} = coordinates <- add_coordinates(offsets, upper_left)
    do
      { :ok, %Vehicle{coordinates: coordinates, hit_coordinates: MapSet.new()} }
    else
      error -> error
    end
  end

  def overlaps?(existing_vehicle, new_vehicle) do
    not MapSet.disjoint?(existing_vehicle.coordinates, new_vehicle.coordinates)
  end

  def guess(vehicle, %Coordinate{} = coordinate) do
    case MapSet.member?(vehicle.coordinates, coordinate) do
      true ->
        hit_coordinates = MapSet.put(vehicle.hit_coordinates, coordinate)
        {:hit, %{vehicle | hit_coordinates: hit_coordinates} }
      false ->
        :miss
    end
  end

  defp offsets(:b52), do: [{0, 1}, {1, 1}, {1, 0}, {1, 2}, {2, 1}]
  defp offsets(:stiletto), do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  defp offsets(:battleship), do: [{0, 0}, {0, 1}, {0, 2}, {0, 3}]
  defp offsets(:destroyer), do: [{0, 0}, {0, 1}, {0, 2}]
  defp offsets(:higgins), do: [{0, 0}]
  defp offsets(_), do: {:error, :invalid_vehicle_name}

  defp add_coordinates(offsets, upper_left) do
    Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
      add_coordinate(acc, upper_left, offset)
    end)
  end

  defp add_coordinate(coordinates,
                      %Coordinate{row: row, col: col},
                      {offset_row, offset_col}) do
    case Coordinate.new(row + offset_row, col + offset_col) do
      {:ok, coordinate} ->
        {:cont, MapSet.put(coordinates, coordinate)}
      {:error, :invalid_coordinate} ->
        {:halt, {:error, :invalid_coordinate}}
    end
  end
end
