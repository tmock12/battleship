defmodule BattleshipEngine.Rules do
  alias __MODULE__
  defstruct state: :iniitialized,
            player1: :ships_not_set,
            player2: :ships_not_set

  def new(), do: %Rules{}

  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  def check(%Rules{state: :players_set} = rules, {:position_ships, player}) do
    case Map.fetch!(rules, player) do
      :ships_set -> :error
      :ships_not_set -> {:ok, rules}
    end
  end

  def check(_state, _action), do: :error
end
