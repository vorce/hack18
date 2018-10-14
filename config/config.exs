# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger, level: :info

# Configure the main viewport for the Scenic application
config :hack18, :viewport, %{
  name: :main_viewport,
  size: {800, 600},
  default_scene: {Hack18.Scene.Game, :game},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "hack18"]
    }
  ]
}

config :hack18, Hack18.Net.Server,
  port: String.to_integer(System.get_env("PORT") || "3418")

config :peerage, via: Peerage.Via.List, node_list: [
  :"1@127.0.0.1",
  :"2@127.0.0.1",
  :"3@127.0.0.1",
  :"4@127.0.0.1"
]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "prod.exs"
