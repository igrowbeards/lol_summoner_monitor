defmodule Lol do
  @moduledoc "Coordinator module that calls the `Api` module and transforms the responses"

  alias Lol.Api
  alias Lol.Region

  @doc """
  Retrieves the summoners recently played with from a series of calls to the LOL api.
  Returns a list of {<summoner_name>, <puuid>} tuples.
  """
  def summoners_in_recent_matches(summoner_name, region, opts \\ []) do
    count = Keyword.get(opts, :count, 5)

    with {:ok, %{"puuid" => puuid}} <- Api.summoner_by_name_in_region(summoner_name, region),
         {:ok, zone} <- Region.to_zone(region),
         {:ok, match_ids} <- Api.recent_matches_for_puuid(puuid, zone, count: count),
         initial_summoners <- concurrently_fetch_match_details(match_ids, zone) do
         remove_target_from_results(initial_summoners, puuid)
    end
  end

  @doc """
  Given match details as reported by the LOL api, extracts a {<summoner_name>, <puuid>}
  for each participant.
  """
  def extract_summoners_from_match(match_details) do
    participants = match_details["info"]["participants"]
    Enum.map(participants, &{&1["summonerName"], &1["puuid"]})
  end

  @doc """
  Spawns a series of tasks to fetch the details of the given `match_ids`
  Don't go crazy with the number of match_ids or you may overrun your api limit,
  especially if you're using a dev key.
  """
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

  ### Private

  defp remove_target_from_results(results, target_puuid) do
    Enum.reject(results, fn {_name, puuid} -> puuid == target_puuid end)
  end
end
