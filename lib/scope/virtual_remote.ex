defmodule Scope.VirtualRemote do
  alias Scope.IoBehaviour
  alias Scope.IoMacro
  use IoMacro
  @behaviour IoBehaviour

  def forward_sync(kind, socket) do
    case input(kind) do
      {:ok, r} ->
        {:reply, {:ok, r}, socket}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_notify(term) do
    ScopeWeb.ScopeControlChannel.broadcast_state(term)
    :ok
  end

  def handle_notify(_, _), do: :ok

  def forward_async(kind, socket) do
    input(kind)
    {:noreply, socket}
  end
end
