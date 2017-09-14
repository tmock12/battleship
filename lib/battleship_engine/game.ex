defmodule BattleshipEngine.Game do
  @moduledoc """
  Genserver for creating new games, adding players and transitioning through
  Rule states
  """

  @players [:player1, :player2]
  use GenServer
  alias BattleshipEngine.{Board, Coordinate, Guesses, Vehicle, Rules}

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def via_tuple(name), do:
    {:via, Registry, {Registry.Game, name}}

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
      error ->
        {:reply, error, state}
    end
  end

  def handle_call({:set_vehicles, player}, _from, state) do
    with {:ok, rules} <- Rules.check(state.rules, {:set_vehicles, player}),
         true <- player_board(state, player) |> Board.all_vehicles_positioned?
    do
      state
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      false ->
        {:reply, {:error, :not_all_vehicles_positioned}, state}
      error ->
        {:reply, error, state}
    end
  end

  def handle_call({:guess_coordinate, player, row, col}, _from, state) do
    opponent_key = opponent(player)
    opponent_board = player_board(state, opponent_key)

    with {:ok, rules} <-
           Rules.check(state.rules, {:guess_coordinate, player}),
         {:ok, coordinate} <-
           Coordinate.new(row, col),
         {hit_or_miss, sunk, win_status, opponent_board} <-
           Board.guess(opponent_board, coordinate),
         {:ok, rules} <-
           Rules.check(rules, {:win_check, win_status})
    do
      state
      |> update_board(opponent_key, opponent_board)
      |> update_guesses(player, hit_or_miss, coordinate)
      |> update_rules(rules)
      |> reply_success({hit_or_miss, sunk, win_status})
    else
      error ->
        error
    end
  end

  def add_player(game, name) when is_binary(name),
    do: GenServer.call(game, {:add_player, name})

  def position_vehicle(game, player, key, row, col) when player in @players,
    do: GenServer.call(game, {:position_vehicle, player, key, row, col})

  def set_vehicles(game, player) when player in @players,
    do: GenServer.call(game, {:set_vehicles, player})

  def guess_coordinate(game, player, row, col) when player in @players,
    do: GenServer.call(game, {:guess_coordinate, player, row, col})

  defp reply_success(state, reply), do: {:reply, reply, state}

  defp update_player2_name(state, name), do: put_in(state.player2.name, name)

  defp update_rules(state, rules), do: %{state | rules: rules}

  defp player_board(state, player), do: get_in(state, [player, :board])

  defp update_board(state, player, board), do:
    Map.update!(state, player, fn player -> %{player | board: board} end)

  defp update_guesses(state, player, hit_or_miss, coordinate) do
    update_in(state[player].guesses, fn guesses ->
      Guesses.add(guesses, hit_or_miss, coordinate)
    end)
  end

  defp opponent(:player1), do: :player2
  defp opponent(:player2), do: :player1
end
