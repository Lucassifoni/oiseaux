defmodule Optics.RxopticsNif do
  use Rustler, otp_app: :scope, crate: :rxopticsnif

  def non_parallel_rayfan_coords(_focal_length, _radius, _source_distance, _source_height, _rays),
    do: error()

  def reflection_angle(_focal_length, _radius, _source_distance, _source_height), do: error()

  def load_image(_path), do: error()

  def blur(_res, _scene_distance, _sensor_distance, _pxsize, _radius, _base_fl), do: error()

  def blur_diam_px_from_base_fl(_base_fl, _radius, _rd, _sensor_distance, _px_size), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
