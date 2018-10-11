defmodule Hack18.Parse do
  def input(<<131, _tag :: size(8), _data :: binary>> = input) when is_binary(input) do
    %Hack18.GameState{} = term = :erlang.binary_to_term(input)
    {:ok, term}
  rescue
    _e in ArgumentError ->
      {:error, :invalid_erlang_binary, input}
  end
end
