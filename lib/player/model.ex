defmodule Hack18.Player.Model do
  alias Hack18.Position

  defstruct position: %Position{},
            name: "",
            color: :navajo_white,
            start_node: Hack18.Identity.new()

  def new() do
    %__MODULE__{name: random_name(), color: random_color()}
  end

  def new(name) when is_binary(name) do
    %__MODULE__{new() | name: name}
  end

  @colors [:alice_blue, :aquamarine, :chartreuse, :dark_sea_green, :dark_slate_gray, :deep_pink, :lavender_blush, :mint_cream, :olive_drab, :pale_turquoise, :pale_violet_red, :papaya_whip, :peach_puff, :peru, :rebecca_purple, :sienna, :thistle, :yellow_green]
  defp random_color() do
    Enum.random(@colors)
  end

  @name_prefix ["mr", "mrs", "ms", "dr"]
  @name_infix ["banana", "fox", "computer", "doom"]
  @name_suffix ["of hugs", "slayer", "beer", "nerd", "!!!!"]

  def random_name() do
    Enum.random(@name_prefix) <> " " <> Enum.random(@name_infix) <> " " <> Enum.random(@name_suffix)
  end
end
