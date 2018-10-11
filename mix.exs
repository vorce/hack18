defmodule Hack18.MixProject do
  use Mix.Project

  def project do
    [
      app: :hack18,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_env: %{"MIX_ENV" => to_string(Mix.env())},
      make_clean: ["clean"],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Hack18, []},
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.4"},
      {:scenic, "~> 0.7.0"},
      {:scenic_driver_glfw, "~> 0.7.0"},
      {:ranch, "~> 1.6"},
      {:loom, git: "https://github.com/asonge/loom", branch: "master"},
      {:socket, "~> 0.3"},
      {:uuid, "~> 1.1"},
    ]
  end
end
