defmodule SummonerMonitor.SummonerWatcher do
  use GenServer

  require Logger

  alias Lol.Api

  @runtime :timer.hours(1)
  @check_interval :timer.minutes(1)

  defmodule State do
    @moduledoc false
    defstruct [
      :puuid,
      :summoner_name,
      :zone,
      recent_matches: [],
      match_check_count: 0,
      initial_delay: 0,
      mode: :automatic
    ]
  end

  ### Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts.worker_name)
  end

  ### Server

  def init(args) do
    {:ok, struct(State, args), {:continue, :initial_delay}}
  end

  def handle_continue(:initial_delay, state) do
    :timer.sleep(state.initial_delay)

    schedule_shutdown()

    if state.mode == :automatic do
      state = check_and_update_state(state)
      schedule_next_check(state)
    end

    {:noreply, state}
  end

  defp check_and_update_state(state) do
    new_matches = new_matches_found(state)
    log_new_matches(new_matches, state)
    state = update_state(state, new_matches)
  end

  def handle_info(:check, state) do
    Logger.debug("Checking for recent matches for #{state.summoner_name}...")
    state = check_and_update_state(state)
    if state.mode == :automatic, do: schedule_next_check(state)

    {:noreply, state}
  end

  def handle_info(:done, state) do
    Logger.debug("Worker for #{state.summoner_name} is shutting down as scheduled")
    Process.exit(self(), :normal)
  end

  ### Private

  defp update_state(state, []), do: %State{state | match_check_count: state.match_check_count + 1}

  defp update_state(state, new_matches) when is_list(new_matches) do
    %State{
      state
      | recent_matches: new_matches ++ [state.recent_matches],
        match_check_count: state.match_check_count + 1
    }
  end

  defp log_new_matches([], _), do: nil

  defp log_new_matches(_, %{match_check_count: 0}), do: nil

  defp log_new_matches(matches, state) when is_list(matches) do
    Enum.each(matches, &Logger.notice("Summoner #{state.summoner_name} completed match #{&1}"))
  end

  defp schedule_next_check(state) do
    Process.send_after(self(), :check, @check_interval)
  end

  defp schedule_shutdown do
    Process.send_after(self(), :done, @runtime)
  end

  defp new_matches_found(state) do
    case Api.recent_matches_for_puuid(state.puuid, state.zone, count: 1) do
      {:ok, [most_recent_match_id]} ->
        if Enum.member?(state.recent_matches, most_recent_match_id) do
          []
        else
          [most_recent_match_id]
        end

      {:error, :rate_limit_met} ->
        []
    end
  end
end
