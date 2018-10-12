defmodule Hack18.Player.Component do
  use Hack18.Component

  alias Scenic.Graph
  alias Scenic.Primitives
  alias Hack18.Player.Model
  alias Hack18.Position
  alias Scenic.Scene
  alias Scenic.ViewPort

  @input_capture [:cursor_button, :cursor_pos, :codepoint, :key]
  @step_size 20

  def verify({_, %Hack18.Player.Model{}} = ok), do: {:ok, ok}
  def verify(_), do: :invalid_data

  def init({start_node, model}, _opts, _parent) do
    IO.inspect(binding(), label: "player component")

    graph = Graph.build()
    |> render(model)

    state = %{graph: graph, model: model, focused: false, start_node: start_node}
    {:ok, state}
  end

  def animation_frame(_scene_state, %{graph: graph, model: model} = state) do
    latest_model = Hack18.GameState.list_players()
    |> Enum.find(&(&1 .start_node.uuid == model.start_node.uuid))

    new_graph =
      graph
      |> Graph.modify(
        latest_model.name,
        &Primitives.update_opts(&1,
          translate: {latest_model.position.x, latest_model.position.y},
          stroke: stroke(state.focused, latest_model.start_node.uuid, state.start_node)
        )
      )
      |> push_graph()

    {:noreply, %{state | graph: new_graph, model: latest_model}}
  end

  def render(%Graph{} = graph, %Model{} = model) do
    IO.inspect(model, label: "rendering player")
    Scenic.Primitives.rectangle(graph, {20, 20}, fill: model.color, translate: {model.position.x, model.position.y}, id: model.name)
    # graph
    # |> Primitives.group(
    #   fn g ->
    #     g
    #     |> Primitives.rect(
    #       {50, 50},
    #       id: String.to_atom(model.name), fill: model.color
    #     )
    #   end,
    #   translate: {model.position.x, model.position.y}
    # )
    |> push_graph()
  end

  # unfocused click in the text field
  def handle_input(
        {:cursor_button, {:left, :press, _, _}},
        context,
        %{focused: false} = state
      ) do
    {:noreply, capture_focus(context, state)}
  end

  # --------------------------------------------------------
  # focused click outside the text field
  def handle_input(
        {:cursor_button, {:left, :press, _, _}},
        context,
        %{focused: true} = state
      ) do
    {:continue, release_focus(context, state)}
  end

  def handle_input({:key, {"right", type, _}}, _context, %{model: model} = state) when type in [:press, :repeat] do
    new_model = if model.start_node.uuid == state.start_node do
      new = %Model{model | position: %Position{model.position | x: model.position.x + @step_size}}
      Hack18.GameState.update_player(new.start_node.uuid, new)
      new
    else
      model
    end

    {:noreply, %{state | model: new_model}}
  end

  def handle_input({:key, {"left", type, _}}, _context, %{model: model} = state) when type in [:press, :repeat] do
    new_model = if model.start_node.uuid == state.start_node do
      new = %Model{model | position: %Position{model.position | x: model.position.x - @step_size}}
      Hack18.GameState.update_player(new.start_node.uuid, new)
      new
    else
      model
    end

    {:noreply, %{state | model: new_model}}
  end

  def handle_input({:key, {"up", type, _}}, _context, %{model: model} = state) when type in [:press, :repeat] do
    new_model = if model.start_node.uuid == state.start_node do
      new = %Model{model | position: %Position{model.position | y: model.position.y - @step_size}}
      Hack18.GameState.update_player(new.start_node.uuid, new)
      new
    else
      model
    end

    {:noreply, %{state | model: new_model}}
  end

  def handle_input({:key, {"down", type, _}}, _context, %{model: model} = state) when type in [:press, :repeat] do
    new_model = if model.start_node.uuid == state.start_node do
      new = %Model{model | position: %Position{model.position | y: model.position.y + @step_size}}
      Hack18.GameState.update_player(new.start_node.uuid, new)
      new
    else
      model
    end

    {:noreply, %{state | model: new_model}}
  end

  def handle_input(_event, _, state) do
    # IO.inspect(event, label: "handle_input in player component")
    {:noreply, state}
  end

  defp stroke(false, _, _) do
    {0, :black}
  end
  defp stroke(true, model_id, start_node_id) when model_id == start_node_id do
    {4, :green}
  end
  defp stroke(true, _model_id, _start_node_id) do
    {2, :red}
  end

  defp capture_focus(context, %{focused: false} = state) do
    ViewPort.capture_input(context, @input_capture)

    if state.start_node == state.model.start_node.uuid do
      IO.puts("Selected yourself: #{inspect(state.model.name)}")
    else
      IO.puts("Selected enemy: #{inspect(state.model.name)}")
    end

    %{state | focused: true}
  end

  # --------------------------------------------------------
  defp release_focus(context, %{focused: true} = state) do
    ViewPort.release_input(context, @input_capture)
    # IO.puts("Unfocused")
    %{state | focused: false}
  end
end
