defmodule ScopeWeb.PageController do
  use ScopeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def dof_simulation(
        conn,
        %{
          "scene_distance" => scene_distance,
          "sensor_distance" => sensor_distance,
          "pxsize" => pxsize,
          "radius" => radius,
          "base_fl" => base_fl
        } = _params
      ) do
    [
      p_scene_distance,
      p_sensor_distance,
      p_pxsize,
      p_radius,
      p_base_fl
    ] =
      [scene_distance, sensor_distance, pxsize, radius, base_fl]
      |> Enum.map(fn f ->
        {pf, _rest} = Float.parse(f)
        pf
      end)
    scene = Optics.SceneHolder.get_scene()
    {:ok, blurred} = Optics.RxopticsNif.blur(scene, p_scene_distance, p_sensor_distance, p_pxsize, p_radius, p_base_fl)
    bin = :binary.list_to_bin(blurred)
    conn |> put_resp_header("Content-Type", "image/png") |> send_resp(:ok, bin)
  end
end
