defmodule Optics.Segment do
  alias Optics.Point
  alias Optics.Segment

  defstruct a: %Point{x: 0, y: 0}, b: %Point{x: 0, y: 0}

  @spec make(number(), number()) ::
          {:ok,
           %Optics.Segment{
             a: %Optics.Point{},
             b: %Optics.Point{}
           }}
  def make(%Point{} = a, %Point{} = b) do
    {:ok,
     %Segment{
       a: a,
       b: b
     }}
  end

  def make(_a, _b), do: {:error, nil}

  @spec make(number(), number(), number(), number()) ::
          {:ok,
           %Optics.Segment{
             a: %Optics.Point{x: number, y: number},
             b: %Optics.Point{x: number, y: number}
           }}
  def make(a, b, c, d) when is_number(a) and is_number(b) and is_number(c) and is_number(d) do
    {:ok,
     %Segment{
       a: %Point{
         x: a,
         y: b
       },
       b: %Point{
         x: c,
         y: d
       }
     }}
  end

  def make(_a, _b, _c, _d), do: {:error, nil}
end
