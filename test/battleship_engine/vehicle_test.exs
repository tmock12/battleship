defmodule BattleshipEngine.VehicleTest do
  use ExUnit.Case, async: true
  alias BattleshipEngine.{Vehicle, Coordinate}
  doctest Vehicle

  defp new_vehicle(vehicle_name, row \\ 1, col \\ 1) do
    Vehicle.new(vehicle_name, %Coordinate{row: row, col: col})
  end

  test "new with valid start returns hit coordinates and coordinates" do
    {:ok, %Vehicle{} = vehicle} = new_vehicle(:b52)

    assert vehicle.hit_coordinates == MapSet.new()
    assert MapSet.size(vehicle.coordinates) == 5
  end

  test "new with invalid start returns invalid coordinate error" do
    assert new_vehicle(:b52, 9, 9) == {:error, :invalid_coordinate}
  end

  test "new with invalid vehicle name returns invalid vehicle type" do
    assert new_vehicle(:non_existant) == {:error, :invalid_vehicle_name}
  end

  test "overlaps if coordinates are matching" do
    {:ok, existing} = new_vehicle(:b52, 1, 1)
    {:ok, new} = new_vehicle(:b52, 1, 1)

    assert Vehicle.overlaps?(existing, new)
  end

  test "does not overlap if no coordinates match" do
    {:ok, existing} = new_vehicle(:b52, 5, 5)
    {:ok, new} = new_vehicle(:b52, 1, 1)

    refute Vehicle.overlaps?(existing, new)
  end

  test "guess with a miss" do
    coordinate = %Coordinate{row: 1, col: 1}
    miss_coordinate = %Coordinate{row: 2, col: 2}
    vehicle = %Vehicle{coordinates: MapSet.new([coordinate]), hit_coordinates: MapSet.new()}

    assert Vehicle.guess(vehicle, miss_coordinate) == :miss
  end

  test "guess with a hit" do
    coordinate = %Coordinate{row: 1, col: 1}
    vehicle = %Vehicle{coordinates: MapSet.new([coordinate]), hit_coordinates: MapSet.new()}

    {:hit, vehicle} = Vehicle.guess(vehicle, coordinate)
    assert vehicle.hit_coordinates == MapSet.new([coordinate])
  end

  test "sunk?" do
    coordinate = %Coordinate{row: 1, col: 1}
    sunk_vehicle = %Vehicle{
      coordinates: MapSet.new([coordinate]),
      hit_coordinates: MapSet.new([coordinate])
    }
    floating_vehicle = %Vehicle{
      coordinates: MapSet.new([coordinate]),
      hit_coordinates: MapSet.new()
    }

    assert Vehicle.sunk?(sunk_vehicle)
    refute Vehicle.sunk?(floating_vehicle)
  end
end
