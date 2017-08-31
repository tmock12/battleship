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

    test "players vehicles not set can position their vehicles in players_set" do
      rules = %Rules{state: :players_set}
      assert Rules.check(rules, {:position_vehicles, :player1}) == {:ok, rules}
    end

    test "players with vehicles set can't set their vehicles in players set" do
      rules = %Rules{state: :players_set, player1: :vehicles_set}
      assert Rules.check(rules, {:position_vehicles, :player1}) == :error
    end

    test "players can lock in their vehicles during players_set" do
      rules = %Rules{state: :players_set, player1: :vehicles_not_set}
      assert Rules.check(rules, {:set_vehicles, :player1}) == {:ok, %Rules{state: :players_set, player1: :vehicles_set}}
    end

    test "when both players lock in vehicles, it transitions to :player1_turn" do
      rules = %Rules{state: :players_set, player1: :vehicles_set, player2: :vehicles_not_set}

      {:ok, new_rules} = Rules.check(rules, {:set_vehicles, :player2})
      assert new_rules.state == :player1_turn
    end

    test "with no win and player1_turn it transitions to player2_turn" do
      rules = %Rules{state: :player1_turn}
      {:ok, new_rules} = Rules.check(rules, {:guess_coordinate, :player1})

      assert new_rules.state == :player2_turn
    end

    test "with no win and player2_turn it transitions to player1_turn" do
      rules = %Rules{state: :player2_turn}
      {:ok, new_rules} = Rules.check(rules, {:guess_coordinate, :player2})

      assert new_rules.state == :player1_turn
    end

    test "with no win and player1_turn, player2 can't guess" do
      rules = %Rules{state: :player1_turn}

      assert Rules.check(rules, {:guess_coordinate, :player2}) == :error
    end

    test "with a win and player1_turn, transitions to :game_over" do
      rules = %Rules{state: :player1_turn}
      {:ok, new_rules} = Rules.check(rules, {:win_check, :win})

      assert new_rules.state == :game_over
    end

    test "with a win and player2_turn, transitions to :game_over" do
      rules = %Rules{state: :player2_turn}
      {:ok, new_rules} = Rules.check(rules, {:win_check, :win})

      assert new_rules.state == :game_over
    end
  end
end
