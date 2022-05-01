defmodule SummonerMonitor.SummonerWatcher do
  use GenServer

  require Logger

  alias Lol.Api

  @check_interval :timer.seconds(60)
  @runtime :timer.hours(1)

  defmodule State do
    @moduledoc false
    defstruct [:puuid, :summoner_name, :zone, jitter: 0, recent_matches: []]
  end

  ### Client

  def start_link(args) do
    state = struct(State, args)

    GenServer.start_link(__MODULE__, state)
  end

  ### Server

  def init(%State{} = state) do
    {:ok, state, {:continue, :initial_query}}
  end

  def handle_continue(:initial_query, state) do
    :timer.sleep(state.jitter)

    case Api.recent_matches_for_puuid(state.puuid, state.zone, count: 1) do
      {:ok, [most_recent_match_id]} ->
        Process.send_after(self(), :check, @check_interval)
        Process.send_after(self(), :done, @runtime)

        {:noreply, %State{state | recent_matches: [most_recent_match_id | state.recent_matches]},
         :hibernate}

      {:error, :rate_limit_met} ->
        {:noreply, state, {:continue, :initial_query}}
    end
  end

  def handle_info(:check, %State{recent_matches: []} = state) do
    case Api.recent_matches_for_puuid(state.puuid, state.zone, count: 1) do
      {:ok, [most_recent_match_id]} ->
        {:noreply, %State{state | recent_matches: [most_recent_match_id | state.recent_matches]},
         :hibernate}

      {:error, :rate_limit_met} ->
        Process.send_after(self(), :check, @check_interval)
        {:noreply, state, :hibernate}
    end
  end

  def handle_info(:done, state) do
    Logger.notice("Watcher #{inspect(self())} has finished it's work and is going to bed.")
    {:stop, :normal, state}
  end

  def handle_info(:check, state) do
    case Api.recent_matches_for_puuid(state.puuid, state.zone, count: 1) do
      {:ok, [most_recent_match_id]} ->
        if Enum.member?(state.recent_matches, most_recent_match_id) do
          Process.send_after(self(), :check, @check_interval)
          {:noreply, state, :hibernate}
        else
          Logger.notice("Summoner #{state.summoner_name} completed match #{most_recent_match_id}")
          Process.send_after(self(), :check, @check_interval)

          {:noreply,
           %State{state | recent_matches: [most_recent_match_id | state.recent_matches]},
           :hibernate}
        end

      {:error, :rate_limit_met} ->
        Process.send_after(self(), :check, @check_interval)
        {:noreply, state, :hibernate}
    end
  end
end
