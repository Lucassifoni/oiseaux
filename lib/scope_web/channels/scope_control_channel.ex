defmodule ScopeWeb.ScopeControlChannel do
  alias Scope.TelescopeApi
  use ScopeWeb, :channel

  @impl true
  def join("scope_control:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("show_status", _, socket) do
    {:reply, {:ok, TelescopeApi.show(Scope.ScopeHolder.get_scope())}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (scope_control:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_in("down", _, socket) do
    TelescopeApi.down(Scope.ScopeHolder.get_scope())
    {:reply, {:ok, ""}, socket}
  end

  def handle_in("up", _, socket) do
    TelescopeApi.up(Scope.ScopeHolder.get_scope())
    {:reply, {:ok, ""}, socket}
  end

  def handle_in("left", _, socket) do
    TelescopeApi.left(Scope.ScopeHolder.get_scope())
    {:reply, {:ok, ""}, socket}
  end

  def handle_in("right", _, socket) do
    TelescopeApi.right(Scope.ScopeHolder.get_scope())
    {:reply, {:ok, ""}, socket}
  end

  def handle_in("focus_in", _, socket) do
    TelescopeApi.focus_in(Scope.ScopeHolder.get_scope())
    {:reply, {:ok, ""}, socket}
  end

  def handle_in("focus_out", _, socket) do
    TelescopeApi.focus_out(Scope.ScopeHolder.get_scope())
    {:reply, {:ok, ""}, socket}
  end

  def handle_in("stop", _, socket) do
    TelescopeApi.stop(Scope.ScopeHolder.get_scope())
    {:reply, {:ok, ""}, socket}
  end

  def handle_in("home", _, socket) do
    TelescopeApi.home(Scope.ScopeHolder.get_scope())
    {:reply, {:ok, ""}, socket}
  end

  def handle_in("stop_focus", _, socket) do
    TelescopeApi.stop_focus(Scope.ScopeHolder.get_scope())
    {:reply, {:ok, ""}, socket}
  end

  def broadcast_state(state) do
    ScopeWeb.Endpoint.broadcast_from!(self(), "scope_control:lobby", "scope_status", state)
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
