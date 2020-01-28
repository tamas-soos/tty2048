defmodule Tty2048.Game do
  defstruct [:grid, score: 0]

  use GenServer
  alias Tty2048.Grid

  @win_tile 2048
  @grid_size 6
  @random_seed if Mix.env() == :test, do: 0, else: :os.timestamp()

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :random.seed(@random_seed)
    {:ok, new(@grid_size)}
  end

  def peek() do
    GenServer.call(__MODULE__, :peek)
  end

  def move(side) do
    GenServer.call(__MODULE__, {:move, side})
  end

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
      highest_value >= @win_tile -> reply({:game_won, game})
      can_move? == true -> reply({:running, game})
      can_move? == false -> reply({:game_over, game})
    end
  end

  def handle_call(:restart, _from, _game) do
    new_game = new(@grid_size)
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
