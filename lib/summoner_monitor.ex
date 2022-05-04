defmodule SummonerMonitor do
  @moduledoc """
  TODO
  """

  alias Lol.Region
  alias SummonerMonitor.SummonerWatcher

  @doc "todo"
  def monitor_summoners(summoner_id, region) do
    summoners = Lol.summoners_in_recent_matches(summoner_id, region)
    spawn_watchers(summoners, region)
    Enum.map(summoners, fn {name, _} -> name end)
  end

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
