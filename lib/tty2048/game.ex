defmodule Tty2048.Game do
  # FIXME add back struct
  defstruct [:grid, score: 0]

  use GenServer

  alias Tty2048.Grid

  def start_link(size) do
    GenServer.start_link(__MODULE__, size, name: __MODULE__)
  end

  def init(size) do
    :random.seed(:os.timestamp())
    {:ok, new(size)}
  end

  def peek() do
    GenServer.call(__MODULE__, :peek)
  end

  def move(side) do
    GenServer.call(__MODULE__, {:move, side})
  end

  # FIXME dont default side to 6
  def restart() do
    GenServer.call(__MODULE__, :restart)
  end

  def handle_call(:peek, _from, game) do
    {:reply, game, game}
  end

  def handle_call({:move, side}, _from, {_stage, game}) do
    {can_move?, game} = move(game, side)
    highest_value = game.grid |> List.flatten() |> Enum.max()

    cond do
      # highest_value >= 2048 -> GenEvent.notify(manager, {:game_won, game})
      highest_value >= 32 -> reply({:game_won, game})
      can_move? == true -> reply({:running, game})
      can_move? == false -> reply({:game_over, game})
    end
  end

  def handle_call(:restart, _from, _game) do
    # FIXME dont default side to 6
    new_game = new(6)
    {:reply, new_game, new_game}
  end

  defp new(size) when is_integer(size) do
    {:running, %{grid: Grid.new(size), score: 0}}
  end

  defp move(%{grid: grid, score: score}, side) do
    {grid, points} = Grid.move(grid, side)
    game = %{grid: grid, score: score + points}
    {Grid.has_move?(grid), game}
  end

  defp reply(state) do
    {:reply, state, state}
  end
end
