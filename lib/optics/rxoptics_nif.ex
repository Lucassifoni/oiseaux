defmodule Optics.RxopticsNif do
  use Rustler, otp_app: :scope, crate: :rxopticsnif

  def non_parallel_rayfan_coords(_focal_length, _radius, _source_distance, _rays), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
