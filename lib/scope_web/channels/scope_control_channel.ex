defmodule ScopeWeb.ScopeControlChannel do
  use ScopeWeb, :channel

  @impl true
  def join("scope_control:lobby", _payload, socket), do: {:ok, socket}

  @impl true
  def handle_in("show_status", _, socket), do: Scope.VirtualRemote.forward_sync(:show, socket)
  def handle_in("down", _, socket), do: Scope.VirtualRemote.forward_async(:down, socket)
  def handle_in("up", _, socket), do: Scope.VirtualRemote.forward_async(:up, socket)
  def handle_in("left", _, socket), do: Scope.VirtualRemote.forward_async(:left, socket)
  def handle_in("right", _, socket), do: Scope.VirtualRemote.forward_async(:right, socket)
  def handle_in("focus_in", _, socket), do: Scope.VirtualRemote.forward_async(:focus_in, socket)
  def handle_in("focus_out", _, socket), do: Scope.VirtualRemote.forward_async(:focus_out, socket)
  def handle_in("stop", _, socket), do: Scope.VirtualRemote.forward_async(:stop, socket)
  def handle_in("home", _, socket), do: Scope.VirtualRemote.forward_sync(:home, socket)

  def handle_in("stop_focus", _, socket),
    do: Scope.VirtualRemote.forward_async(:stop_focus, socket)

  def handle_in(_, _, socket), do: {:noreply, socket}

  def broadcast_state(state) do
    ScopeWeb.Endpoint.broadcast_from!(self(), "scope_control:lobby", "scope_status", state)
  end
end
