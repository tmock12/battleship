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

    test "players can lock in their ships during players_set" do
      rules = %Rules{state: :players_set, player1: :ships_not_set}
      assert Rules.check(rules, {:set_ships, :player1}) == {:ok, %Rules{state: :players_set, player1: :ships_set}}
    end

    test "when both players lock in ships, it transitions to :player1_turn" do
      rules = %Rules{state: :players_set, player1: :ships_set, player2: :ships_not_set}

      {:ok, new_rules} = Rules.check(rules, {:set_ships, :player2})
      assert new_rules.state == :player1_turn
    end
  end
end
