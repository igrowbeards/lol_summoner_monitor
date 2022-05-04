defmodule Lol.Api do
  @moduledoc """
  Functions for calling the Riot LOL api
  Everything is rate limited by the <TODO> 
  Any requests over the limit will return an error response
  and the api will not actually be hit.
  """

  require Logger

  alias Lol.Api.RateLimiter

  use Tesla

  plug(Tesla.Middleware.JSON)

  # set api key in header
  plug(Tesla.Middleware.Headers, [
    {"X-Riot-Token", Application.get_env(:summoner_monitor, :riot_api_key)}
  ])

  def summoner_by_name_in_region(name, region) do
    if under_rate_limits?() do
      Logger.debug("querying api for summoner #{name} in #{region}")

      (base_url(region) <> "summoner/v4/summoners/by-name/#{name}")
      |> get()
      |> format_response()
    else
      Logger.warn(
        "over rate limit - attempted to call `summoner_by_name_in_region` with name: #{name}, region: #{region}"
      )

      {:error, :rate_limit_met}
    end
  end

  def recent_matches_for_puuid(puuid, zone, query_params \\ []) do
    if under_rate_limits?() do
      Logger.debug("querying api for recent matches for #{puuid} in #{zone}")

      (base_url(zone) <> "match/v5/matches/by-puuid/#{puuid}/ids")
      |> get(query: query_params)
      |> format_response()
    else
      Logger.warn(
        "over rate limit - attempted to call `recent_matches_for_puuid` with puuid: #{puuid}, zone: #{zone}"
      )

      {:error, :rate_limit_met}
    end
  end

  def match_details(match_id, zone) do
    if under_rate_limits?() do
      Logger.debug("querying api for match details for match #{match_id} in #{zone}")

      (base_url(zone) <> "match/v5/matches/#{match_id}")
      |> get()
      |> format_response()
    else
      Logger.warn(
        "over rate limit - attempted to call `match_details` with match_id: #{match_id}, zone: #{zone}"
      )

      {:error, :rate_limit_met}
    end
  end

  ### Private

  defp base_url(region_or_zone) do
    "https://#{region_or_zone}.api.riotgames.com/lol/"
  end

  defp format_response(resp) do
    case resp do
      {:ok, %{body: body, status: 200}} -> {:ok, body}
      {:ok, other} -> {:error, other}
      other -> other
    end
  end

  defp under_rate_limits? do
    RateLimiter.under_limits?()
  end
end
