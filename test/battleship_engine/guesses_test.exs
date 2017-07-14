defmodule BattleshipEngine.GuessesTest do
  use ExUnit.Case, async: true
  alias BattleshipEngine.Guesses
  doctest Guesses

  test "new returns mapset of hits and misses" do
    assert Guesses.new() == %Guesses{hits: MapSet.new(), misses: MapSet.new()}
  end
end
