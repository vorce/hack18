defmodule Hack18.Player.Model do
  alias Hack18.Position

  defstruct position: %Position{},
            name: "",
            color: :white,
            start_node: Hack18.Identity.new()

  def new() do
    %__MODULE__{name: random_name()}
  end

  def new(name) when is_binary(name) do
    %__MODULE__{new() | name: name}
  end

  @name_prefix ["mr", "mrs", "ms", "dr"]
  @name_infix ["banana", "fox", "computer", "doom"]
  @name_suffix ["of hugs", "slayer", "beer", "nerd", "!!!!"]

  def random_name() do
    Enum.random(@name_prefix) <> " " <> Enum.random(@name_infix) <> " " <> Enum.random(@name_suffix)
  end
end
