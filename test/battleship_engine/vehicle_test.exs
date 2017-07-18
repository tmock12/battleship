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
end
