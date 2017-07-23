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

  test "all_vehicles_positioned?" do
    full_board = Vehicle.types() |> Enum.into(%{}, &({&1, nil}))
    missing_vehicles = %{b52: nil, destroy: nil}

    assert Board.all_vehicles_positioned?(full_board)
    refute Board.all_vehicles_positioned?(missing_vehicles)
  end
end
