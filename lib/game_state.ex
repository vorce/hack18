defmodule Hack18.GameState do
  alias Loom.AWORSet

  use GenServer

  require Logger

  defstruct players: AWORSet.new(),
            version: "v1",
            node_id: Hack18.Identity.new()

  def start_link() do
    player = Hack18.Player.Model.new()
    GenServer.start_link(__MODULE__, player, name: __MODULE__)
  end

  def init(%Hack18.Player.Model{} = player) do
    node_id = Hack18.Identity.new()
    local_player = %Hack18.Player.Model{player | start_node: node_id}

    initial_players = AWORSet.new()
    |> AWORSet.add(node_id.uuid, local_player)

    state = %__MODULE__{players: initial_players, node_id: node_id}
    Logger.info("Starting with local game state: #{inspect(state)}")

    {:ok, state}
  end

  def join(%__MODULE__{} = gs) do
    GenServer.call(__MODULE__, {:join, gs})
  end

  def local_player() do
    GenServer.call(__MODULE__, :local_player)
  end

  def list_players() do
    GenServer.call(__MODULE__, :list_players)
  end

  def handle_call({:join, gs}, _from, %__MODULE__{} = state) do
    {:reply, :ok, %__MODULE__{state | players: join_players(state.players, gs.players)}}
  end

  def handle_call(:local_player, _from, %__MODULE__{} = state) do
    result = state.players
    |> list_players()
    |> Enum.find(&(&1 .start_node == state.node_id))

    {:reply, result, state}
  end

  def handle_call(:list_players, _from, %__MODULE__{} = state) do
    {:reply, AWORSet.value(state.players), state}
  end

  defp list_players(%AWORSet{} = players) do
    AWORSet.value(players)
  end

  defp join_players(%AWORSet{} = players1, %AWORSet{} = players2) do
    AWORSet.join(players1, players2)
  end
end
