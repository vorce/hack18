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

  def verify(%Hack18.Player.Model{} = model), do: {:ok, model}
  def verify(_), do: :invalid_data

  def init(model, _opts, _parent) do
    IO.inspect(binding(), label: "player component")

    graph = Graph.build()
    |> render(model)

    state = %{graph: graph, model: model, focused: false}
    {:ok, state}
  end

  def animation_frame(_scene_state, %{graph: graph, model: model} = state) do
    new_graph =
      graph
      |> Graph.modify(
        model.name,
        &Primitives.update_opts(&1,
          translate: {model.position.x, model.position.y},
          stroke: stroke(state.focused)
        )
      )
      |> push_graph()

    {:noreply, %{state | graph: new_graph}}
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
    new_model = %Model{model | position: %Position{model.position | x: model.position.x + @step_size}}

    {:noreply, %{state | model: new_model}}
  end

  def handle_input({:key, {"left", type, _}}, _context, %{model: model} = state) when type in [:press, :repeat] do
    new_model = %Model{model | position: %Position{model.position | x: model.position.x - @step_size}}

    {:noreply, %{state | model: new_model}}
  end

  def handle_input({:key, {"up", type, _}}, _context, %{model: model} = state) when type in [:press, :repeat] do
    new_model = %Model{model | position: %Position{model.position | y: model.position.y - @step_size}}

    {:noreply, %{state | model: new_model}}
  end

  def handle_input({:key, {"down", type, _}}, _context, %{model: model} = state) when type in [:press, :repeat] do
    new_model = %Model{model | position: %Position{model.position | y: model.position.y + @step_size}}

    {:noreply, %{state | model: new_model}}
  end

  def handle_input(_event, _, state) do
    # IO.inspect(event, label: "handle_input in player component")
    {:noreply, state}
  end

  defp stroke(false) do
    {0, :black}
  end
  defp stroke(true) do
    {3, :green}
  end

  defp capture_focus(context, %{focused: false} = state) do
    ViewPort.capture_input(context, @input_capture)
    IO.puts("Focused")
    %{state | focused: true}
  end

  # --------------------------------------------------------
  defp release_focus(context, %{focused: true} = state) do
    ViewPort.release_input(context, @input_capture)
    IO.puts("Unfocused")
    %{state | focused: false}
  end

  # def filter_event({:player_move_right, %Model{name: name}}, _from, %{model: %Model{name: my_name} = model} = state) when name == my_name do
  #   IO.inspect(name, label: "moving to the right")
  #   new_model = %Model{position: %Position{model.position | x: model.position.x + 10}}
  #   {:stop, %{state | model: new_model}}
  # end
  # def filter_event(event, _from, state) do
  #   IO.inspect(event, label: "filter_event")
  #   {:continue, state}
  # end
end
