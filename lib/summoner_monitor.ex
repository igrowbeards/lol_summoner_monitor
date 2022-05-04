defmodule SummonerMonitor do
  @moduledoc """
  TODO
  """

  alias Lol.Region
  alias SummonerMonitor.SummonerWatcher

  @doc "todo"
  def monitor_summoners(summoner_id, region) do
    summoners = Lol.summoners_in_recent_matches(summoner_id, region)

    {:ok, zone} = Region.to_zone(region)

    summoners
    |> Enum.with_index()
    |> Enum.each(fn {{name, puuid}, index} ->
      GenServer.start(SummonerWatcher, %{
        summoner_name: name,
        puuid: puuid,
        zone: zone,
        initial_delay: index * 2000
      })
    end)

    Enum.map(summoners, fn {name, _} -> name end)
  end
end
