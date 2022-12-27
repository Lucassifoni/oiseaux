defmodule Scope.TelescopeApi do
  def create(name), do: GenServer.start_link(Scope.Telescope, name)

  def home(pid), do: GenServer.call(pid, :home, 10000)

  def show(pid), do: GenServer.cast(pid, :show)

  def up(pid), do: GenServer.cast(pid, :start_move_up)
  def down(pid), do: GenServer.cast(pid, :start_move_down)
  def left(pid), do: GenServer.cast(pid, :start_move_left)
  def right(pid), do: GenServer.cast(pid, :start_move_right)

  def stop(pid), do: GenServer.cast(pid, :stop_move)
end
