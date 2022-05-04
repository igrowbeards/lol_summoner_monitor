defmodule SummonerMonitor do
  @moduledoc """
  TODO
  """

  alias Lol.Region
  alias SummonerMonitor.SummonerWatcher

  @doc """
  Retrieves the summoners a given `summoner_name` has
  played with over their last 5 matches from the LOL api,
  and starts a process which monitors for newly completed matches for each one. 

  The match check frequency and the total runtime for each watcher process is 
  defined in the app config.
  """
  def monitor_summoners(summoner_name, region) do
    summoners = Lol.summoners_in_recent_matches(summoner_name, region)
    spawn_watchers(summoners, region)
    Enum.map(summoners, fn {name, _} -> name end)
  end

  ### Private

  defp spawn_watchers(summoners, region) do
    {:ok, zone} = Region.to_zone(region)

    summoners
    |> Enum.with_index()
    |> Enum.each(fn args -> spawn_watcher(args, zone) end)
  end

  defp spawn_watcher({{name, puuid}, index}, zone) do
      GenServer.start(SummonerWatcher, %{
        summoner_name: name,
        puuid: puuid,
        zone: zone,
        initial_delay: index * 2000
      })
  end
end
