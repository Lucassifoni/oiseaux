defmodule Optics.RxopticsNif do
  use Rustler, otp_app: :scope, crate: :rxopticsnif

  def non_parallel_rayfan_coords(_focal_length, _radius, _source_distance, _source_height, _rays), do: error()

  def reflection_angle(_focal_length, _radius, _source_distance, _source_height), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
