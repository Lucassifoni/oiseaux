defmodule Optics.Ellipsoid do
  @doc """
  Optical Path Difference between a spherical & parabolic surface for light coming from infinity
  """
  def parabolic_opd(radius, curvature_radius),
    do: :math.pow(radius, 4) / (4 * :math.pow(curvature_radius, 3))

  @doc """
  λ/4 criteria
  """
  def rayleigh_limit(wavelength), do: wavelength / 4

  @doc """
  Optical Path Difference between a spherical & ellipsoid surface
  """
  def ellipsoid_opd(radius, curvature_radius, object_distance, image_distance) do
    with opdp <- parabolic_opd(radius, curvature_radius),
         c <- object_distance / 2,
         a <- image_distance + c,
         term2 <- :math.pow(c, 2) / :math.pow(a, 2) do
      opdp * term2
    end
  end

  @doc """
  Best fit conic for a given pair of conjugates, rounded to 2 significant digits
  since that's where I trust my measurements when doing interferometry.
  """
  def best_fit_conic(radius, curvature_radius, obj_dist, img_dist) do
    with opde <- ellipsoid_opd(radius, curvature_radius, obj_dist, img_dist),
         opdp <- parabolic_opd(radius, curvature_radius) do
      Float.round(-1 * opde / opdp, 2)
    end
  end
end
