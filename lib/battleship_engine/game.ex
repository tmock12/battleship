defmodule BattleshipEngine.Game do
  @moduledoc """
  Genserver for creating new games, adding players and transitioning through
  Rule states
  """

  @players [:player1, :player2]
  use GenServer
  alias BattleshipEngine.{Board, Coordinate, Guesses, Vehicle, Rules}

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name, [])
  end

  def init(name) do
    player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    {:ok, %{player1: player1, player2: player2, rules: Rules.new()}}
  end

  def handle_call({:add_player, name}, _from, state) do
    with {:ok, rules} <- Rules.check(state.rules, :add_player) do
      state
      |> update_player2_name(name)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state}
    end
  end

  def handle_call({:position_vehicle, player, key, row, col}, _from, state) do
    board = player_board(state, player)

    with {:ok, rules} <- Rules.check(state.rules, {:position_vehicles, player}),
         {:ok, coordinate} <- Coordinate.new(row, col),
         {:ok, vehicle} <- Vehicle.new(key, coordinate),
         %{} = board <- Board.position_vehicle(board, key, vehicle)

    do
      state
      |> update_board(player, board)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      {:error, :invalid_coordinate} ->
        {:reply, {:error, :invalid_coordinate}, state}
      {:error, :invalid_vehicle_name} ->
        {:reply, {:error, :invalid_vehicle_name}, state}
      {:error, :overlapping_vehicle} ->
        {:reply, {:error, :overlapping_vehicle}, state}
      error ->
        {:reply, error, state}
    end
  end

  def add_player(game, name) when is_binary(name),
    do: GenServer.call(game, {:add_player, name})

  def position_vehicle(game, player, key, row, col) when player in @players,
    do: GenServer.call(game, {:position_vehicle, player, key, row, col})

  defp reply_success(state, reply), do: {:reply, reply, state}

  defp update_player2_name(state, name), do: put_in(state.player2.name, name)

  defp update_rules(state, rules), do: %{state | rules: rules}

  defp player_board(state, player), do: get_in(state, [player, :board])

  defp update_board(state, player, board), do:
    Map.update!(state, player, fn player -> %{player | board: board} end)
end
