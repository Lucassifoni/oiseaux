defmodule Scope.VirtualTelescope do
  use Scope.DeviceMacro

  @behaviour Scope.DeviceBehaviour
  @server Scope.VirtualTelescopeServer

  def notifier(term), do: notify(term)

  def handle_input(:up) do
    GenServer.cast(@server, :start_move_up)
    :ok
  end

  def handle_input(:stop) do
    GenServer.cast(@server, :stop_move)
    :ok
  end

  def handle_input(:home) do
    GenServer.call(@server, :home, 10000)
    :ok
  end

  def handle_input(:show) do
    GenServer.call(@server, :show)
    :ok
  end

  def handle_input(:down) do
    GenServer.cast(@server, :start_move_down)
    :ok
  end

  def handle_input(:left) do
    GenServer.cast(@server, :start_move_left)
    :ok
  end

  def handle_input(:right) do
    GenServer.cast(@server, :start_move_right)
    :ok
  end

  def handle_input(:focus_in) do
    GenServer.cast(@server, :start_focus_in)
    :ok
  end

  def handle_input(:focus_out) do
    GenServer.cast(@server, :start_focus_out)
    :ok
  end

  def handle_input(:stop_focus) do
    GenServer.cast(@server, :stop_focusing)
    :ok
  end

  def handle_input(_), do: :ok

  def create() do
    r = GenServer.start_link(@server, nil, name: @server)
    {:ok, s} = GenServer.call(@server, :show)
    notify(s)
    r
  end
end
