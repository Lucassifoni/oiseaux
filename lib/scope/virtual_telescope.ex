defmodule Scope.VirtualTelescope do
  use Scope.DeviceMacro

  @behaviour Scope.DeviceBehaviour
  @server Scope.VirtualTelescopeServer

  def notifier(term), do: notify(term)

  def ok(_), do: :ok
  def handle_input(:up), do: ok(GenServer.cast(@server, :start_move_up))
  def handle_input(:stop), do: ok(GenServer.cast(@server, :stop_move))
  def handle_input(:home), do: ok(GenServer.call(@server, :home, 10000))
  def handle_input(:show), do: ok(GenServer.call(@server, :show))
  def handle_input(:down), do: ok(GenServer.cast(@server, :start_move_down))
  def handle_input(:left), do: ok(GenServer.cast(@server, :start_move_left))
  def handle_input(:right), do: ok(GenServer.cast(@server, :start_move_right))
  def handle_input(:focus_in), do: ok(GenServer.cast(@server, :start_focus_in))
  def handle_input(:focus_out), do: ok(GenServer.cast(@server, :start_focus_out))
  def handle_input(:stop_focus), do: ok(GenServer.cast(@server, :stop_focusing))
  def handle_input(_), do: :ok

  def create() do
    r = GenServer.start_link(@server, nil, name: @server)
    {:ok, s} = GenServer.call(@server, :show)
    notify(s)
    r
  end
end
