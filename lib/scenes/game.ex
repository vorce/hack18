defmodule Hack18.Scene.Game do
  #use Scenic.Scene
  use Hack18.Scene
  alias Scenic.Graph

  @viewport Application.get_env(:hack18, :viewport)
  @cell_size 10
  @width elem(@viewport.size, 0)
  @height elem(@viewport.size, 1)

  def init({what, opts}) do
    IO.inspect(binding(), label: "Game init bindings")
    {:ok, info} = Scenic.ViewPort.info(opts[:viewport])
    player = %Hack18.Player.Model{Hack18.GameState.local_player() | position: Hack18.Position.random(info)}
    player_id = player.start_node.uuid

    graph = Graph.build()
    |> build_grid({@width, @height}, @cell_size)
    # |> Scenic.Primitives.scene_ref(:player_scene)
    #|> Scenic.Primitives.group(fn g ->
      #      Hack18.Player.Component.add_to_graph(g, player, id: player_id)
    #end, id: :players)
    |> Hack18.Player.Component.add_to_graph(player, id: player_id)
    |> push_graph()

    {:ok, _timer} = :timer.send_interval(500, :add_or_remove_players)

    state = %{graph: graph, graph_player_ids: [player_id]}
    {:ok, state}
  end

  def handle_info(:add_or_remove_players, state) do
    present_players = Hack18.GameState.list_players()
    current_graph_players = state.graph_player_ids
    add_to_graph = Enum.reject(present_players, fn p -> Enum.member?(current_graph_players, p.start_node.uuid) end)
    |> IO.inspect(label: "players to add")

    present_player_ids = present_players |> Enum.map(fn p -> p.start_node.uuid end)

    delete_from_graph = Enum.reject(current_graph_players, fn id -> Enum.member?(present_player_ids, id) end)
    |> IO.inspect(label: "players to remove")

    with_additions = Enum.reduce(add_to_graph, state.graph, fn p, acc ->
      acc
      |> Hack18.Player.Component.add_to_graph(p, id: p.start_node.uuid)
    end)

    new_graph = Enum.reduce(delete_from_graph, with_additions, fn p_id, acc ->
      acc
      |> Graph.delete(p_id)
    end)
    |> push_graph()

    {:noreply, %{state | graph: new_graph, graph_player_ids: present_player_ids}}
  end

  def build_grid(graph, {width, height}, spacing) do
    horizontal =
      Enum.reduce(0..height, graph, fn y, acc ->
        acc
        |> Scenic.Primitives.line({{0, spacing * y}, {width, spacing * y}},
          stroke: {1, :gray}
        )
      end)

    Enum.reduce(0..width, horizontal, fn x, acc ->
      acc
      |> Scenic.Primitives.line({{spacing * x, 0}, {spacing * x, height}},
        stroke: {1, :gray}
      )
    end)
  end

  def handle_call({:add_player, player}, _from, state) do

    {:reply, :ok, state}
  end
end
