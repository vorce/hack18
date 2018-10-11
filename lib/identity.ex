defmodule Hack18.Identity do
  defstruct uuid: "",
            name: ""

  def new() do
    %__MODULE__{
      name: "",
      uuid: UUID.uuid1()
    }
  end

  def new(name) when is_binary(name) do
    %__MODULE__{new() | name: name}
  end
end
