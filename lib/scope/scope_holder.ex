defmodule Scope.ScopeHolder do
  alias Scope.TelescopeApi
  use Agent

  defp initial_state() do
    {:ok, pid} = TelescopeApi.create("CyberKermit")
    pid
  end

  def start_link(_) do
    Agent.start_link(fn () -> initial_state() end, name: __MODULE__)
  end

  def get_scope() do
    Agent.get(__MODULE__, fn a -> a end)
  end
end
