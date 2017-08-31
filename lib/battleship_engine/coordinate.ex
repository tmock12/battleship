defmodule BattleshipEngine.Coordinate do
  @moduledoc """
  Container for row and column for guesses and vehicle positioning
  """

  alias __MODULE__
  @enforce_keys [:row, :col]
  @board_range 1..10
  defstruct [:row, :col]

  @doc ~S"""
  If row and column between 1 and 10, returns a Coordinate module otherwise
  invalid coordinate error

  ## Examples

      iex> BattleshipEngine.Coordinate.new(5, 2)
      {:ok, %BattleshipEngine.Coordinate{row: 5, col: 2}}
      iex> BattleshipEngine.Coordinate.new(11, 2)
      {:error, :invalid_coordinate}

  """

  def new(row, col) when row in(@board_range) and col in(@board_range), do:
    {:ok, %Coordinate{row: row, col: col}}
  def new(_row, _col), do: {:error, :invalid_coordinate}
end
