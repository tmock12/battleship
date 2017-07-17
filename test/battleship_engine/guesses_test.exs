defmodule BattleshipEngine.GuessesTest do
  use ExUnit.Case, async: true
  alias BattleshipEngine.{Coordinate, Guesses}
  doctest Guesses

  test "new returns mapset of hits and misses" do
    assert Guesses.new() == %Guesses{hits: MapSet.new(), misses: MapSet.new()}
  end

  def valid_coordinate, do: %Coordinate{row: 1, col: 1}

  test "adding coordinates to hits" do
    guesses = Guesses.add(Guesses.new(), :hit, valid_coordinate())

    assert guesses.hits == MapSet.new([valid_coordinate()])
  end

  test "adding coordinates to misses" do
    guesses = Guesses.add(Guesses.new(), :miss, valid_coordinate())

    assert guesses.misses == MapSet.new([valid_coordinate()])
  end
end
