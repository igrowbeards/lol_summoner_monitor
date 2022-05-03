defmodule Lol.Api.RateLimiter do
  @moduledoc "Tracks requests to the LOL api"

  use GenServer

  defmodule State do
    @moduledoc false
    defstruct [
      :long_limit,
      :short_limit,
      :long_period,
      :short_period,
      long_count: 0,
      short_count: 0,
      enabled: true
    ]
  end

  ### Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def under_limits? do
    GenServer.call(__MODULE__, :under_limits?)
  end

  ### Server

  def init(opts) do
    state = struct(State, opts)

    if state.enabled do
      schedule_long_reset(state)
      schedule_short_reset(state)
    end

    {:ok, state, :hibernate}
  end

  # if limiter is disabled just always say we are under limits
  def handle_call(:under_limits?, _from, %{enabled: false} = state) do
    {:reply, true, state}
  end

  def handle_call(:under_limits?, _from, state) do
    if state.short_count < state.short_limit && state.long_count < state.long_limit do
      {:reply, true,
       %State{state | long_count: state.long_count + 1, short_count: state.short_count + 1}}
    else
      {:reply, false, state}
    end
  end

  def handle_info(:clear_long, state) do
    schedule_long_reset(state)
    {:noreply, %State{state | long_count: 0}}
  end

  def handle_info(:clear_short, state) do
    schedule_short_reset(state)
    {:noreply, %State{state | short_count: 0}}
  end

  ### Private

  defp schedule_long_reset(state) do
    Process.send_after(self(), :clear_long, state.long_period)
  end

  defp schedule_short_reset(state) do
    Process.send_after(self(), :clear_short, state.short_period)
  end
end
