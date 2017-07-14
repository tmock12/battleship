defmodule BattleshipEngine.CoordinateTest do
  use ExUnit.Case, async: true
  alias BattleshipEngine.Coordinate
  doctest Coordinate

  test "new with column and range within board_range returns ok tuple" do
    row = Enum.random(1..10)
    col = Enum.random(1..10)

    assert Coordinate.new(row, col) == {:ok, %Coordinate{row: row, col: col}}
  end

  test "new with anything outside board_range returns error tuple" do
    outside_range = Enum.random(11..100)

    assert Coordinate.new(outside_range, outside_range) == {:error, :invalid_coordinate}
  end
end
