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
      supervisor(Scenic, viewports: [main_viewport_config]),
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
