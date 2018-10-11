defmodule Hack18 do
  @moduledoc """
  Starter application using the Scenic framework.
  """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # load the viewport configuration from config
    main_viewport_config = Application.get_env(:hack18, :viewport)
    #player = %Hack18.Player.Model{Hack18.GameState.local_player() | position: %Hack18.Position{x: 400, y: 300}}

    # start the application with the viewport
    children = [
      worker(Hack18.GameState, []),

      # Graphics elements
      supervisor(Hack18.Scene.Supervisor, []),
      #supervisor(Hack18.Player.Scene, [%Hack18.Player.Model{}, [name: :player_scene]]),
      supervisor(Scenic, viewports: [main_viewport_config]),

      # Start accepting peer connections
      supervisor(Hack18.Net.Supervisor, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
