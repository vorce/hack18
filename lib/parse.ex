defmodule Hack18.Parse do
  def decode(<<131, _tag :: size(8), _data :: binary>> = iodata) when is_binary(iodata) do
    %Hack18.GameState{} = term = :erlang.binary_to_term(iodata)
    {:ok, term}
  rescue
    _e in ArgumentError ->
      {:error, :invalid_erlang_binary, iodata}
  end

  def encode(data) do
    binary = :erlang.term_to_binary(data)
    {:ok, binary}
  rescue
    _e in ArgumentError ->
      {:error, :invalid_erlang_term, data}
  end
end
