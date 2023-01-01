defmodule Optics.Parabola do
  alias Optics.Point
  alias Optics.Segment

  @spec x_coord_on_parabola(number(), number()) :: number()
  def x_coord_on_parabola(focal_length, y) do
    y * y / 4 / focal_length
  end

  @spec parabola_coords(number(), number()) :: list(%Optics.Point{})
  def parabola_coords(radius, focal_length) do
    r = Range.new(-radius, radius)

    Enum.map(r, fn y ->
      x = x_coord_on_parabola(focal_length, y)
      {:ok, p} = Point.make(x, y)
      p
    end)
  end

  @spec segment_delta(%Optics.Segment{}) :: %Optics.Segment{}
  def segment_delta(%Segment{} = s) do
    {:ok, s1} = Segment.make(0, 0, s.b.x - s.a.x, s.b.y - s.a.y)
    s1
  end

  @spec point_and_angle_to_x_coord(
          %Optics.Point{},
          number
        ) :: float
  def point_and_angle_to_x_coord(%Point{} = p, angle) do
    slope = :math.tan(angle)
    case slope do
      0.0 -> 9999999999999.0
      _ -> (slope * p.x - p.y) / slope
    end
  end

  @spec angle_with_x_axis(%Optics.Segment{}) :: float
  def angle_with_x_axis(%Segment{} = s) do
    derived = segment_delta(s)
    :math.atan2(derived.b.y, derived.b.x)
  end

  @spec angle_between_segments(
          %Optics.Segment{},
          %Optics.Segment{}
        ) :: float
  def angle_between_segments(%Segment{} = a, %Segment{} = b) do
    angle_with_x_axis(b) - angle_with_x_axis(a)
  end

  @spec normal_coords(number, number) :: %Optics.Segment{}
  def normal_coords(focal_length, y) do
    x = x_coord_on_parabola(focal_length, y)
    dx = -2 * x
    dy = -y
    {:ok, s} = Segment.make(-dy + x, dx + y, dy + x, -dx + y)
    s
  end

  @spec tangent_coords(number, number) :: %Optics.Segment{}
  def tangent_coords(focal_length, y) do
    x = x_coord_on_parabola(focal_length, y)
    dx = -2 * x
    dy = -y
    {:ok, s} = Segment.make(-x, 0, x - dx, y - dy)
    s
  end

  @spec parallel_rayfan_coords(number, number, integer) :: list(%Segment{})
  def parallel_rayfan_coords(radius, focal_length, rays) do
    base_y = -radius
    step = abs(radius) / rays * 2
    range = Range.new(0, rays)

    Enum.flat_map(range, fn r ->
      y = base_y + r * step
      x = x_coord_on_parabola(focal_length, y)
      {:ok, s1} = Segment.make(x, y, 9_999_999_999_999, y)
      {:ok, s2} = Segment.make(x, y, focal_length, 0)
      [s1, s2]
    end)
  end

  @spec reflection_coords(number, number, number) ::
          {:ok, %Optics.Segment{}}
  def reflection_coords(focal_length, y, source_distance) do
    x = x_coord_on_parabola(focal_length, y)
    {:ok, v1} = Segment.make(x, y, source_distance, 0)
    normal = normal_coords(focal_length, y)
    angle = angle_between_segments(v1, normal)
    output_angle = angle_with_x_axis(v1) + 2 * angle
    x_coord = point_and_angle_to_x_coord(%Point{x: x, y: y}, output_angle)
    Segment.make(x, y, x_coord, 0)
  end

  @spec non_parallel_rayfan_coords(number, number, number, integer) :: list(%Segment{})
  @doc """
  Returns a list of rays (Segments) and their reflections.

      iex> rays = Optics.Parabola.non_parallel_rayfan_coords(400, 57, 10000, 4)
      iex> last_ray = rays |> List.last()
      iex> %Optics.Segment{a: %Optics.Point{x: 2.030625, y: 57.0},b: %Optics.Point{x: 416.836314941448, y: 0}} = last_ray
      iex> rays = Optics.Parabola.non_parallel_rayfan_coords(400, 57, 99999999999999, 4)
      iex> last_ray = rays |> List.last()
      iex> 400.0 = Float.round(last_ray.b.x, 2)
  """
  def non_parallel_rayfan_coords(focal_length, radius, source_distance, rays) do
    base_y = -radius
    base_x = source_distance
    step = abs(radius) / rays * 2
    range = Range.new(0, rays)

    Enum.flat_map(range, fn r ->
      y = base_y + r * step
      x = x_coord_on_parabola(focal_length, y)
      {:ok, s1} = Segment.make(x, y, base_x, 0)
      {:ok, s2} = reflection_coords(focal_length, y, source_distance)
      [s1, s2]
    end)
  end
end
