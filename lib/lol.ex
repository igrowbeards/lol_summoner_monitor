defmodule Lol do
  @moduledoc "Coordinator module that calls the `Api` module and transforms the responses"

  alias Lol.Api
  alias Lol.Region
  alias SummonerMonitor.SummonerWatcher

  def summoners_in_recent_matches(summoner_id, region, opts \\ []) do
    count = Keyword.get(opts, :count, 5)
    spawn_watchers = Keyword.get(opts, :spawn_watches, true)

    with {:ok, %{"puuid" => puuid}} <- Api.summoner_by_id_in_region(summoner_id, region),
         {:ok, zone} <- Region.to_zone(region),
         {:ok, match_ids} <- Api.recent_matches_for_puuid(puuid, zone, count: count),
         initial_summoners <- concurrently_fetch_match_details(match_ids, zone),
         filtered_summoners <- remove_target_from_results(initial_summoners, puuid) do
      if spawn_watchers do
        # the watechers are designed to sleep for `jitter` ms before they begin their loop
        # this helps us spread the recurring api calls out a bit and avoid hitting our per second rate limit
        filtered_summoners
        |> Enum.with_index()
        |> Enum.each(fn {{name, id}, index} ->
          SummonerWatcher.start_link(%{
            summoner_name: name,
            puuid: id,
            zone: zone,
            # TODO: this probably belongs elsewhere
            jitter: index * 2000
          })
        end)
      end

      Enum.map(filtered_summoners, fn {name, _} -> name end)
    end
  end

  def extract_summoners_from_match(match_details) do
    participants = match_details["info"]["participants"]
    Enum.map(participants, &{&1["summonerName"], &1["puuid"]})
  end

  def concurrently_fetch_match_details(match_ids, zone) do
    match_ids
    |> Task.async_stream(fn match_id ->
      {:ok, match_details} = Api.match_details(match_id, zone)
      match_details
    end)
    |> Stream.map(fn {:ok, result} -> result end)
    |> Stream.flat_map(&extract_summoners_from_match/1)
    |> Stream.uniq()
    |> Enum.to_list()
  end

  defp remove_target_from_results(results, target_puuid) do
    Enum.reject(results, fn {_name, puuid} -> puuid == target_puuid end)
  end
end
