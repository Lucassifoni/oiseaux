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
  @az_divisions 3600
  @az_time 60
  @alt_increment :math.pi() / 2 / @alt_divisions
  @az_increment :math.pi() * 2 / @az_divisions
  @alt_time_interval trunc(@alt_time / @alt_divisions * 1000)
  @az_time_interval trunc(@az_time / @az_divisions * 1000)

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



  def handle_call(:home, _, state), do: do_home(state)
  def handle_info(:continue_move, %Telescope{moving: :no} = state), do: {:noreply, state}
  def handle_info(:continue_move, %Telescope{moving: _dir} = state), do: continue_move(state)

  def handle_cast(:show, state), do: {:noreply, IO.inspect(state)}

  def handle_cast(:start_move_down, state), do: start_move(:down, state)
  def handle_cast(:start_move_left, state), do: start_move(:left, state)
  def handle_cast(:start_move_up, state), do: start_move(:up, state)
  def handle_cast(:start_move_right, state), do: start_move(:right, state)

  def handle_cast(:move_up, state), do: do_move(:up, state)
  def handle_cast(:move_down, state), do: do_move(:down, state)
  def handle_cast(:move_left, state), do: do_move(:right, state)
  def handle_cast(:move_right, state), do: do_move(:left, state)

  def handle_cast(:stop_move, %Telescope{} = state), do: stop_move(state)

  def valid_move_preconditions?(_, %{position_alt: -1}), do: false
  def valid_move_preconditions?(:down, %{lower_alt_stop: true}), do: false
  def valid_move_preconditions?(:up, %{upper_alt_stop: true}), do: false
  def valid_move_preconditions?(_, _), do: true

  def dir_to_msg(dir) do
    case dir do
      :up -> :move_up
      :down -> :move_down
      :right -> :move_right
      :left -> :move_left
      _ -> nil
    end
  end

  def start_move(dir, state) do
    msg = dir_to_msg(dir)

    if valid_move_preconditions?(dir, state) and !is_nil(msg) do
      GenServer.cast(self(), msg)
      {:noreply, %{state | moving: dir}}
    else
      {:noreply, state}
    end
  end

  def do_move(_dir, %Telescope{moving: :no} = state), do: {:noreply, state}
  def do_move(dir, %Telescope{} = state) do
    case dir do
      :left -> do_move_az(-1 * @az_increment, state)
      :right -> do_move_az(@az_increment, state)
      :up -> do_move_alt(@alt_increment, state)
      :down -> do_move_alt(-1 * @alt_increment, state)
      _ -> {:noreply, state}
    end
  end

  def do_move_az(inc, %Telescope{} = state) do
    pos = state.position_az + inc
    turns = trunc(pos / :math.pi())
    normalized = pos - turns * :math.pi()
    home_az = normalized == 0
    Process.send_after(self(), :continue_move, @az_time_interval)
    {:noreply, %{state | home_az: home_az, position_az: normalized}}
  end

  def do_move_alt(inc, %Telescope{} = state) do
    pos = state.position_alt + inc
    mmax = :math.pi() / 2
    lower_stop = pos <= 0
    upper_stop = pos >= mmax
    normalized = min(mmax, max(pos, 0))
    if lower_stop or upper_stop do
      GenServer.cast(self(), :stop_move)
    else
      Process.send_after(self(), :continue_move, @alt_time_interval)
    end
    {:noreply, %{state |
      lower_alt_stop: lower_stop,
      upper_alt_stop: upper_stop,
      position_alt: normalized
    }}
  end

  def continue_move(%Telescope{} = state) do
    msg = dir_to_msg(state.moving)

    if !is_nil(msg) do
      GenServer.cast(self(), msg)
    end

    {:noreply, state}
  end

  def do_home(state) do
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

  def stop_move(state), do: {:noreply, %{state | moving: :no}}
end
