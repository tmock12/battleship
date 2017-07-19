defmodule BattleshipEngine.BoardTest do
  use ExUnit.Case, async: true
  alias BattleshipEngine.{Board, Vehicle, Coordinate}

  test "position_vehicle puts non overlapping battleship on board" do
    coordinates = MapSet.new([%Coordinate{row: 1, col: 1}])
    vehicle = %Vehicle{coordinates: coordinates, hit_coordinates: coordinates}

    assert Board.position_vehicle(%{}, :b52, vehicle) == %{b52: vehicle}
  end

  test "position_vehicle with overlapping vehicle" do
    coordinates = MapSet.new([%Coordinate{row: 1, col: 1}])
    vehicle = %Vehicle{coordinates: coordinates, hit_coordinates: coordinates}

    assert Board.position_vehicle(%{stiletto: vehicle}, :b52, vehicle) == {:error, :overlapping_vehicle}
  end
end
