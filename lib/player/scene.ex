defmodule Hack18.Player.Scene do
  use Hack18.Scene
  alias Scenic.Graph

  def init({player, opts}) do
    IO.inspect(binding(), label: "#{inspect(__MODULE__)} init bindings")

    #{:ok, info} = Scenic.ViewPort.info(opts[:viewport])
    #player = %Hack18.Player.Model{Hack18.GameState.local_player() | position: Hack18.Position.random(info)}

    # Graph.build()
    #|> Hack18.Player.Component.add_to_graph(player, id: :local_player)
    # |> push_graph()

    state = %{local_player: player}
    {:ok, state}
  end

  def handle_info({:DOWN, _, _, _, _} = msg, state) do
    IO.inspect(msg, label: "received down msg")
    {:noreply, state}
  end
end
