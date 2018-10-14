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
    graph = Graph.build(font: :roboto)
    |> render(model)

    state = %{graph: graph, model: model, focused: false, start_node: start_node}
    {:ok, state}
  end

  def animation_frame(_scene_state, %{graph: graph, model: model} = state) do
    latest_model = Hack18.GameState.list_players()
    |> Enum.find(&(&1 .start_node.uuid == model.start_node.uuid))

    gun_angle = angle(latest_model.position, model.aim)

    new_graph =
      graph
      |> Graph.modify(
        latest_model.name,
        &Primitives.update_opts(&1,
          translate: {latest_model.position.x, latest_model.position.y},
          stroke: stroke(state.focused, latest_model.start_node.uuid, state.start_node)
        )
      )
      |> Graph.modify(latest_model.name <> "_text", &Primitives.update_opts(&1,
          translate: {latest_model.position.x, latest_model.position.y + 28}))
      |> Graph.modify(latest_model.name <> "_gun", &Primitives.update_opts(&1,
          rotate: gun_angle,
          translate: {latest_model.position.x + 3, latest_model.position.y - 3},
          hidden: hidden?(latest_model.start_node.uuid, state.start_node)))
      |> push_graph()

    {:noreply, %{state | graph: new_graph, model: %Model{latest_model|aim: model.aim}}}
  end

  defp hidden?(model_id, start_node_id) when model_id == start_node_id, do: false
  defp hidden?(_model_id, _start_node_id), do: true

  def angle(%Hack18.Position{} = a, %Hack18.Position{} = b) do
    :math.atan2(b.x - a.x, - (b.y - a.y))
  end

  def render(%Graph{} = graph, %Model{} = model) do
    graph
    |> Scenic.Primitives.rectangle({20, 20}, fill: model.color, translate: {model.position.x, model.position.y}, id: model.name)
    |> Scenic.Primitives.text(model.name, font_size: 12, translate: {model.position.x, model.position.y + 28}, id: model.name <> "_text")
    |> Scenic.Primitives.triangle({{0, 20}, {14, 20}, {7, -3}}, fill: :white, translate: {model.position.x + 3, model.position.y + 5}, id: model.name <> "_gun")
    |> push_graph()
  end

  def handle_input(
        {:cursor_button, {:left, :press, _, _}},
        context,
        %{focused: false} = state
      ) do
    {:noreply, capture_focus(context, state)}
  end

  def handle_input(
        {:cursor_button, {:left, :press, _, _}},
        context,
        %{focused: true} = state
      ) do
    {:continue, release_focus(context, state)}
  end

  def handle_input({:key, {"D", type, _}}, _context, %{model: %Model{alive?: true} = model} = state) when type in [:press, :repeat] do
    new_model = if model.start_node.uuid == state.start_node do
      new_x = horizontal_wrap(model.position.x + @step_size)
      new = %Model{model | position: %Position{model.position | x: new_x}}
      Hack18.GameState.update_player(new.start_node.uuid, new)
      new
    else
      model
    end

    {:noreply, %{state | model: new_model}}
  end

  def handle_input({:key, {"A", type, _}}, _context, %{model: %Model{alive?: true} = model} = state) when type in [:press, :repeat] do
    new_model = if model.start_node.uuid == state.start_node do
      new_x = horizontal_wrap(model.position.x - @step_size)
      new = %Model{model | position: %Position{model.position | x: new_x}}
      Hack18.GameState.update_player(new.start_node.uuid, new)
      new
    else
      model
    end

    {:noreply, %{state | model: new_model}}
  end

  def handle_input({:key, {"W", type, _}}, _context, %{model: %Model{alive?: true} = model} = state) when type in [:press, :repeat] do
    new_model = if model.start_node.uuid == state.start_node do
      new_y = vertical_wrap(model.position.y - @step_size)
      new = %Model{model | position: %Position{model.position | y: new_y}}
      Hack18.GameState.update_player(new.start_node.uuid, new)
      new
    else
      model
    end

    {:noreply, %{state | model: new_model}}
  end

  def handle_input({:key, {"S", type, _}}, _context, %{model: %Model{alive?: true} = model} = state) when type in [:press, :repeat] do
    new_model = if model.start_node.uuid == state.start_node do
      new_y = vertical_wrap(model.position.y + @step_size)
      new = %Model{model | position: %Position{model.position | y: new_y}}
      Hack18.GameState.update_player(new.start_node.uuid, new)
      new
    else
      model
    end

    {:noreply, %{state | model: new_model}}
  end

  def handle_input({:key, {" ", type, _}}, _, state) when type in [:press, :repeat] do
    # TODO: Shoot something
    {:noreply, state}
  end

  def handle_input({:cursor_pos, {x, y}}, _, state) do
    new_aim = %Hack18.Position{x: x, y: y}
    {:noreply, %{state | model: %Model{state.model | aim: new_aim}}}
  end

  def handle_input(event, _, state) do
    IO.inspect(event, label: "event")
    {:noreply, state}
  end

  defp stroke(false, _, _) do
    {0, :black}
  end
  defp stroke(true, model_id, start_node_id) when model_id == start_node_id do
    {4, :green}
  end
  defp stroke(true, _model_id, _start_node_id) do
    {1, :red}
  end

  defp vertical_wrap(new_y) do
    cond do
       new_y <= -20 ->
        600
       new_y >= 620 ->
        0
       true ->
        new_y
    end
  end

  defp horizontal_wrap(new_x) do
    cond do
       new_x <= -20 ->
        800
       new_x >= 820 ->
        0
       true ->
        new_x
    end
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

  defp release_focus(context, %{focused: true} = state) do
    ViewPort.release_input(context, @input_capture)
    # IO.puts("Unfocused")
    %{state | focused: false}
  end
end
