defmodule Scope.DeviceBehaviour do
  @callback handle_input(:up) :: :ok | {:error, String.t()}
  @callback handle_input(:stop) :: :ok | {:error, String.t()}
  @callback handle_input(:home) :: :ok | {:error, String.t()}
  @callback handle_input(:show) :: :ok | {:error, String.t()}
  @callback handle_input(:down) :: :ok | {:error, String.t()}
  @callback handle_input(:left) :: :ok | {:error, String.t()}
  @callback handle_input(:right) :: :ok | {:error, String.t()}
  @callback handle_input(:focus_in) :: :ok | {:error, String.t()}
  @callback handle_input(:focus_out) :: :ok | {:error, String.t()}
  @callback handle_input(:stop_focus) :: :ok | {:error, String.t()}
end
