defmodule Lol.RateLimiter do
  @moduledoc "TODO"

  use GenServer

  @long_period :timer.minutes(2)
  @long_limit 200
  @short_period :timer.seconds(20)
  @short_limit 20

  defmodule State do
    @moduledoc false
    defstruct long_count: 0, short_count: 0
  end

  ### Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  def under_limits? do
    GenServer.call(__MODULE__, :under_limits?)
  end

  ### Server

  def init(state) do
    Process.send_after(self(), :clear_long, @long_period)
    Process.send_after(self(), :clear_short, @short_period)
    {:ok, state, :hibernate}
  end

  def handle_call(:under_limits?, _from, state) do
    if state.short_count <= @short_limit && state.long_count <= @long_limit do
      {:reply, true,
       %State{state | long_count: state.long_count + 1, short_count: state.short_count + 1}}
    else
      {:reply, false, state}
    end
  end

  def handle_info(:clear_long, state) do
    Process.send_after(self(), :clear_long, @long_period)
    {:noreply, %State{state | long_count: 0}}
  end

  def handle_info(:clear_short, state) do
    Process.send_after(self(), :clear_short, @short_period)
    {:noreply, %State{state | short_count: 0}}
  end
end
