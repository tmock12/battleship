defmodule BattleshipEngine.RulesTest do
  use ExUnit.Case
  alias BattleshipEngine.Rules

  describe "check/2" do
    test "catchall returns error" do
      assert Rules.check(nil, nil) == :error
    end

    test "initialized accepts add_player and transitions to players set" do
      rules = %Rules{state: :initialized}
      assert Rules.check(rules, :add_player) == {:ok, %Rules{state: :players_set}}
    end

    test "players ships not set can position their ships in players_set" do
      rules = %Rules{state: :players_set}
      assert Rules.check(rules, {:position_ships, :player1}) == {:ok, rules}
    end

    test "players with ships set can't set their ships in players set" do
      rules = %Rules{state: :players_set, player1: :ships_set}
      assert Rules.check(rules, {:position_ships, :player1}) == :error
    end
  end
end
