defmodule Hack18.Position do
  @moduledoc """
  A position in the game world
  """
  alias Scenic.ViewPort

  defstruct x: 10,
            y: 10

  def random(%ViewPort.Status{size: {width, height}}) do
    %__MODULE__{
      x: :rand.uniform(width),
      y: :rand.uniform(height)
    }
  end
end
