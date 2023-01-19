defmodule Optics.Point do
  alias Optics.Point

  defstruct x: 0, y: 0

  @spec make(number(), number()) :: {:ok, %Optics.Point{x: number, y: number}}
  def make(x, y) when is_number(x) and is_number(y) do
    {:ok,
     %Point{
       x: x,
       y: y
     }}
  end

  def make(_x, _y), do: {:error, nil}
end
