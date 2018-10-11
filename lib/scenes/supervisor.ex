defmodule Hack18.Scene.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    # player = %Hack18.Player.Model{Hack18.GameState.local_player() | position: %Hack18.Position{x: 400, y: 300}}

    children = [
      # {Hack18.Player.Scene, {player, [name: :player_scene]}},
      #{Scenic.Clock.Digital, {[], [name: :clock]}}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
