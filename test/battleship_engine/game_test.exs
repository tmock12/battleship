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
end
