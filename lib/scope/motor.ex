defmodule Scope.Motor do
  require Logger

  @moduledoc """
  Module to use the ULN2003 Stepper drivers.
  See https://42bots.com/tutorials/28byj-48-stepper-motor-with-uln2003-driver-and-arduino-uno/.

  Usage :
  iex> {:ok, my_motor} = Scope.Motor.make({1,2,3,4})
  iex> my_motor |> Scope.Motor.turn_cw()
  iex> my_motor |> Scope.Motor.turn_ccw()
  iex> my_motor |> Scope.Motor.stop()
  iex> my_motor |> Scope.Motor.change_speed(23)
  iex> my_motor |> Scope.Motor.change_speed_accel_linear(30, 150_000, 10)
  """
  @cycle_cw [
    {'1', '0', '0', '0'},
    {'1', '1', '0', '0'},
    {'0', '1', '0', '0'},
    {'0', '1', '1', '0'},
    {'0', '0', '1', '0'},
    {'0', '0', '1', '1'},
    {'0', '0', '0', '1'},
    {'1', '0', '0', '1'}
  ]

  @cycle_ccw @cycle_cw |> Enum.reverse()
  @steps_per_turn 4096

  use GenServer

  defp get_platform(), do: Application.fetch_env!(:scope, :selected_io)


  @doc """
  Returns a GPIO pin file descriptor on the MangoPI,
  or a RAM IO device on Mac OS
  """
  def open_pin(pin_nb) when is_integer(pin_nb) do
    case get_platform() do
      :nezha -> File.open!("/sys/class/gpio/gpio#{pin_nb}/value", [:write])
      _ -> File.open!([], [:ram, :write])
    end
  end

  @doc """
  Converts a value expressed in RPM to the amount of time needed to
  do 1/8th of a step
  """
  def rpm_to_ustep_μs(n) do
    rps = n / 60
    sps = rps * @steps_per_turn
    usps = sps * 8
    trunc(1000 / usps * 1000)
  end

  def init({pin1, pin2, pin3, pin4}) do
    {:ok,
     {
       open_pin(pin1),
       open_pin(pin2),
       open_pin(pin3),
       open_pin(pin4),
       {
         :stop,
         10,
         rpm_to_ustep_μs(10)
       },
       @steps_per_turn
     }}
  end

  @doc """
  Entrypoint of the public API : Given GPIO numbers, init a Motor GenServer.
  """
  def make({p1, p2, p3, p4}) do
    GenServer.start_link(__MODULE__, {p1, p2, p3, p4})
  end

  @doc """
  Makes a step, clockwise
  """
  def step_cw(f1, f2, f3, f4, delay) do
    ustep(@cycle_cw, f1, f2, f3, f4, delay)
  end

  @doc """
  Makes a step, counterclockwise
  """
  def step_ccw(f1, f2, f3, f4, delay) do
    ustep(@cycle_ccw, f1, f2, f3, f4, delay)
  end

  @doc """
  Recurses through the list of bit masks to apply to the 4-pin
  motor driver input.
  """
  def ustep([{v1, v2, v3, v4} | t], f1, f2, f3, f4, delay) do
    IO.binwrite(f1, v1)
    IO.binwrite(f2, v2)
    IO.binwrite(f3, v3)
    IO.binwrite(f4, v4)
    MicroTimer.usleep(delay)
    ustep(t, f1, f2, f3, f4, delay)
  end

  def ustep([], _, _, _, _, _) do
  end

  def handle_cast(:turn_cw, {f1, f2, f3, f4, {_dir, speed, stepμs}, s}) do
    Logger.info("Starting turning clockwise at #{speed} rpm")
    Process.send_after(self(), :continue, 1)
    {:noreply, {f1, f2, f3, f4, {:cw, speed, stepμs}, s}}
  end

  def handle_cast(:turn_ccw, {f1, f2, f3, f4, {_dir, speed, stepμs}, s}) do
    Logger.info("Starting turning counterclockwise at #{speed} rpm")
    Process.send_after(self(), :continue, 1)
    {:noreply, {f1, f2, f3, f4, {:ccw, speed, stepμs}, s}}
  end

  def handle_cast({:change_speed, value}, {f1, f2, f3, f4, {dir, _speed, _ustepμs}, s}) do
    Logger.info("Changed speed to #{value} rpm")
    {:noreply, {f1, f2, f3, f4, {dir, value, rpm_to_ustep_μs(value)}, s}}
  end

  def handle_info(:continue, {f1, f2, f3, f4, {:ccw, speed, stepμs}, s}) do
    ns =
      if s == 0 do
        Logger.info("Made a whole turn")
        @steps_per_turn
      else
        s - 1
      end

    step_ccw(f1, f2, f3, f4, stepμs)
    MicroTimer.send_after(stepμs, :continue, self())
    {:noreply, {f1, f2, f3, f4, {:cw, speed, stepμs}, ns}}
  end

  def handle_info(:continue, {f1, f2, f3, f4, {:cw, speed, stepμs}, s}) do
    ns =
      if s == 0 do
        Logger.info("#{DateTime.utc_now()} Made a whole turn")
        @steps_per_turn
      else
        s - 1
      end

    step_cw(f1, f2, f3, f4, stepμs)
    MicroTimer.send_after(stepμs, :continue, self())
    {:noreply, {f1, f2, f3, f4, {:cw, speed, stepμs}, ns}}
  end

  def handle_info(:continue, state) do
    {:noreply, state}
  end

  def handle_call(:stop, _, {f1, f2, f3, f4, {_dir, speed, ustepμs}, s}) do
    Logger.info("Stopping")
    {:reply, :ok, {f1, f2, f3, f4, {:stop, speed, ustepμs}, s}}
  end

  def handle_call(:get_speed, _, {_, _, _, _, {_, s, _}, _} = state), do: {:reply, {:ok, s}, state}

  def turn_cw(pid) do
    GenServer.cast(pid, :turn_cw)
  end

  def change_speed(pid, value) do
    GenServer.cast(pid, {:change_speed, value})
  end

  @doc """
  Duration is in µs
  """
  def change_speed_accel_linear(pid, new_speed, duration, steps) do
    {:ok, current_speed} = GenServer.call(pid, :get_speed)
    delta_s = (new_speed - current_speed) / steps
    delta_dur = duration / steps
    Logger.info("Accelerating to #{new_speed}rpm")

    for step <- 0..steps do
      new_speed = current_speed + delta_s * step
      GenServer.cast(pid, {:change_speed, new_speed})
      MicroTimer.usleep(trunc(delta_dur))
    end

    :ok
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  def turn_ccw(pid) do
    GenServer.cast(pid, :turn_ccw)
  end
end
