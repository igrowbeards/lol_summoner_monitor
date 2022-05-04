defmodule SummonerMonitor.SummonerMatchWatcher do
  use GenServer

  require Logger

  alias Lol.Api

  defmodule State do
    @moduledoc false
    defstruct [
      :puuid,
      :summoner_name,
      :zone,
      recent_matches: [],
      match_check_count: 0,
      initial_delay: 0,
      # the `mode` determines whether the process will schedule it's own checks
      # or wait for a signal from outside to run a check against the latest api data.
      # Basically just makes testing this process a lot easier.
      mode: :automatic
    ]
  end

  ### Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  ### Server

  def init(args) do
    {:ok, struct(State, args), {:continue, :initial_delay}}
  end

  # this lets us stagger our startups so as not to blow past our api per second limit
  def handle_continue(:initial_delay, state) do
    :timer.sleep(state.initial_delay)

    schedule_shutdown()

    case state.mode do
      :automatic ->
        schedule_next_check()
        new_state = check_and_update_state(state)
        {:noreply, new_state}

      :manual ->
        {:noreply, state}
    end
  end

  # the handler that triggers the work
  def handle_info(:check, state) do
    state = check_and_update_state(state)
    if state.mode == :automatic, do: schedule_next_check()

    {:noreply, state}
  end

  # handles shutting down the process after the runtime has elapsed
  def handle_info(:done, state) do
    Logger.debug("Worker for #{state.summoner_name} is shutting down as scheduled")
    Process.exit(self(), :normal)
  end

  ### Private

  # calls the api to check for new matches, logs, and returns an updated state
  defp check_and_update_state(state) do
    new_matches = new_matches_found(state)
    log_new_matches(new_matches, state)
    update_state(state, new_matches)
  end

  ### Private

  defp update_state(state, []), do: %State{state | match_check_count: state.match_check_count + 1}

  defp update_state(state, new_matches) when is_list(new_matches) do
    %State{
      state
      | recent_matches: new_matches,
        match_check_count: state.match_check_count + 1
    }
  end

  defp log_new_matches([], _), do: nil

  defp log_new_matches(_, %{match_check_count: 0}), do: nil

  defp log_new_matches(matches, state) when is_list(matches) do
    Enum.each(matches, &Logger.notice("Summoner #{state.summoner_name} completed match #{&1}"))
  end

  defp schedule_next_check do
    interval = Application.get_env(:summoner_monitor, :summoner_watcher)[:check_interval]
    Process.send_after(self(), :check, interval)
  end

  defp schedule_shutdown do
    runtime = Application.get_env(:summoner_monitor, :summoner_watcher)[:runtime]
    Process.send_after(self(), :done, runtime)
  end

  # grabs the latest match ids from the lol api,
  # and diffs them vs the ids stored in the process state
  defp new_matches_found(state) do
    Logger.debug("Fetching latest matches for #{state.summoner_name}")

    case Api.recent_matches_for_puuid(state.puuid, state.zone, count: 5) do
      {:ok, most_recent_match_ids} ->
        most_recent_match_ids -- state.recent_matches

      {:error, :rate_limit_met} ->
        Logger.debug("api limit hit, will catch new ones next go around...")
        []
    end
  end
end
