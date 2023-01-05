defmodule Optics.SceneHolder do
  use Agent

  def get_path() do
    Path.join(:code.priv_dir(:scope), "resource/img_n_depth.png")
  end

  defp initial_state() do
    {:ok, ref} = Optics.RxopticsNif.load_image(get_path())
    ref
  end

  def start_link(_) do
    Agent.start_link(fn () -> initial_state() end, name: __MODULE__)
  end

  def get_scene() do
    Agent.get(__MODULE__, fn a -> a end)
  end
end
