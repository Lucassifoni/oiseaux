defmodule Scope.IoBehaviour do
  @callback handle_notify(term) :: :ok | {:error, String.t()}
  @callback handle_notify(term, term) :: :ok | {:error, String.t()}
end
