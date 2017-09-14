defmodule BattleshipEngine.GameTest do
  alias BattleshipEngine.Game
  use ExUnit.Case

  setup do
    {:ok, state} = Game.init("Taylor")
    {:ok, state: state}
  end

  describe "when rules state is players_set" do
    setup context do
      context = put_in(context.state.rules.state, :players_set)
      {:ok, context}
    end

    test "it doesn't set vehicles unless all positioned", %{state: state} do
      response = Game.handle_call({:set_vehicles, :player1}, nil, state)
      assert {:reply, {:error, :not_all_vehicles_positioned}, state} == response
    end
  end

  describe "when rules state is player1_turn" do
    setup context do
      context = put_in(context.state.rules.state, :player1_turn)
      {:ok, context}
    end

    test "guessing coordinates advances state with player1", %{state: state} do
      {:reply, {:miss, :none, :no_win}, new_state}  = Game.handle_call(
        {:guess_coordinate, :player1, 1, 1}, nil, state
      )
      assert new_state.rules.state == :player2_turn
    end
  end
end
