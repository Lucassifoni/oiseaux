defmodule Scope.PhysicalRemoteServer do
  use GenServer
  require Logger

  @arduino_product_id 29987

  defp get_arduino() do
    maybe_port =
      Circuits.UART.enumerate()
      |> Enum.find(fn {_k, v} ->
        case v do
          %{product_id: @arduino_product_id} -> true
          _ -> false
        end
      end)

    case maybe_port do
      nil ->
        nil

      {port, _details} ->
        Logger.info("Found arduino on port #{port}")
        {:ok, pid} = Circuits.UART.start_link()
        Circuits.UART.open(pid, port, speed: 9600, active: false)
        pid
    end
  end

  def start_link(_initial_value) do
    pid = get_arduino()

    GenServer.start_link(
      __MODULE__,
      %{
        pid: pid
      },
      name: __MODULE__
    )
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def get_port(), do: GenServer.call(__MODULE__, :get_port)

  def handle_call(:get_port, _from, state), do: {:reply, state, state}

  def handle_cast({:write, data}, state) do
    port = state.pid

    if !is_nil(port) do
      Circuits.UART.write(port, data)
    else
      Logger.info("No port available.")
    end

    {:noreply, state}
  end

  def handle_cast(:init_comm, state) do
    Process.send_after(self(), :flush, 16)
    {:noreply, state}
  end

  def init_comm(), do: GenServer.cast(__MODULE__, :init_comm)

  def handle_info(:flush, state) do
    Scope.PhysicalRemote.handle_read(Circuits.UART.read(state.pid))
    Circuits.UART.flush(state.pid)
    Process.send_after(self(), :flush, 16)
    {:noreply, state}
  end

  def write(data), do: GenServer.cast(__MODULE__, {:write, data})
end
