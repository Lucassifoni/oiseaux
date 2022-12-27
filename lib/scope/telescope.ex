defmodule Scope.Telescope do
  defstruct name: "",
            position_alt: 0,
            position_az: 0,
            position_focus: 0,
            moving: :no,
            home_az: false,
            lower_alt_stop: false,
            upper_alt_stop: false,
            lower_focus_stop: false,
            upper_focus_stop: false

  @alt_time 15
  @alt_divisions 900
  @alt_increment :math.pi() / 2 / @alt_divisions
  @time_interval trunc(@alt_time / @alt_divisions * 1000)

  def show_constants() do
    %{
      alt_time: @alt_time,
      alt_divisions: @alt_divisions,
      alt_increment: @alt_increment,
      time_interval: @time_interval
    }
  end

  use GenServer
  alias Scope.Telescope

  def init(name) do
    {:ok,
     %Telescope{
       name: name,
       position_alt: -1,
       position_az: -1,
       home_az: false,
       moving: :no,
       lower_alt_stop: false,
       upper_alt_stop: false,
       lower_focus_stop: false,
       upper_focus_stop: false
     }}
  end

  def home(pid) do
    GenServer.call(pid, :home, 10000)
  end

  def show(pid) do
    GenServer.cast(pid, :show)
  end

  def start_move_up(pid) do
    GenServer.cast(pid, :start_move_up)
  end

  def stop_move_up(pid) do
    GenServer.cast(pid, :stop_move_up)
  end

  def homed?(%Telescope{position_alt: -1}), do: false
  def homed?(_), do: true

  def handle_info(:continue_move, %Telescope{moving: :no} = state) do
    {:noreply, state}
  end

  def handle_info(:continue_move, %Telescope{moving: dir} = state) do
    msg =
      case dir do
        :up -> :move_up
        :down -> :move_down
        :right -> :move_right
        :left -> :move_left
        _ -> nil
      end

    if !is_nil(msg) do
      GenServer.cast(self(), msg)
    end

    {:noreply, state}
  end

  def handle_cast(:show, state) do
    IO.inspect(state)
    {:noreply, state}
  end

  def handle_cast(:start_move_up, %Telescope{} = state) do
    if not state.upper_alt_stop do
      GenServer.cast(self(), :move_up)
    end

    {:noreply,
     %Telescope{
       state
       | moving: :up
     }}
  end

  def handle_cast(:move_up, %Telescope{moving: :up} = state) do
    pos = state.position_alt + @alt_increment

    {new_pos, new_stop_status} =
      if pos >= :math.pi() / 2, do: {:math.pi() / 2, true}, else: {pos, false}

    new_state = %Telescope{
      state
      | position_alt: new_pos,
        upper_alt_stop: new_stop_status
    }

    if new_stop_status do
      IO.inspect("Hit upper alt endstop.")
      GenServer.cast(self(), :stop_move_up)
    else
      IO.inspect("Moving up to #{new_state.position_alt |> Float.floor(2)} rad")
      Process.send_after(self(), :continue_move, @time_interval)
    end

    {:noreply, new_state}
  end

  def handle_cast(:move_up, %Telescope{moving: :no} = state) do
    {:noreply, state}
  end

  def handle_cast(:stop_move_up, %Telescope{} = state) do
    {:noreply,
     %Telescope{
       state
       | moving: :no
     }}
  end

  def handle_call(:home, _, state) do
    new_state = %{
      state
      | lower_alt_stop: true,
        lower_focus_stop: true,
        home_az: true,
        position_alt: 0,
        position_az: 0
    }

    {:reply, :ok, new_state}
  end
end
