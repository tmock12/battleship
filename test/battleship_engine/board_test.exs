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

  test "guess/2 when hit" do
    coordinates = MapSet.new([%Coordinate{row: 1, col: 1}])
    board = %{b52: %Vehicle{coordinates: coordinates, hit_coordinates: MapSet.new}}
    hit_board = %{b52: %Vehicle{coordinates: coordinates, hit_coordinates: coordinates}}

    assert Board.guess(board, %Coordinate{row: 1, col: 1}) == {:hit, :none, :no_win, hit_board}
  end

  test "guess/2 when miss" do
    coordinates = MapSet.new([%Coordinate{row: 1, col: 1}])
    board = %{b52: %Vehicle{coordinates: coordinates, hit_coordinates: MapSet.new}}

    assert Board.guess(board, %Coordinate{row: 2, col: 3}) == {:miss, :none, :no_win, board}
  end
end
