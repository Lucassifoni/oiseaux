defmodule Scope.PhysicalRemote do
  alias Scope.IoBehaviour
  use Scope.IoMacro
  @behaviour IoBehaviour

  @communication_ready <<105>>
  @move_left "1\r\n"
  @move_up "2\r\n"
  @move_right "3\r\n"
  @move_down "4\r\n"
  @focus_in "5\r\n"
  @focus_out "6\r\n"
  @stop_focusing "7\r\n"
  @stop_moving "8\r\n"

  def handle_read({:ok, @move_up}), do: input(:up)
  def handle_read({:ok, @stop_moving}), do: input(:stop)
  def handle_read({:ok, @move_left}), do: input(:left)
  def handle_read({:ok, @move_right}), do: input(:right)
  def handle_read({:ok, @move_down}), do: input(:down)
  def handle_read({:ok, @focus_in}), do: input(:focus_in)
  def handle_read({:ok, @focus_out}), do: input(:focus_out)
  def handle_read({:ok, @stop_focusing}), do: input(:stop_focusing)
  def handle_read({:error, _}), do: input(:stop)
  def handle_read(_), do: input(:stop)

  def handle_notify(state) do
    ScopeWeb.ScopeControlChannel.broadcast_state(state)
  end

  def handle_notify(_, _), do: :ok
end
