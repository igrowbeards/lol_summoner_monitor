defmodule Lol.Region do
  @moduledoc "Functions for working with LOL regions/zones"

  # Dev Note: To be honest i'm not 100% sure I understand Riot's system for zones/regions.
  # My abstraction of regions <> routing zones (just "zones" in my code) works for the given problem,
  # but i'm not sure how accurately it reflects the rest of the regions/zones/endpoints that I didn't use,
  # or if there's a better way to work with these.

  @americas ~w(BR1 LA1 LA2 OC1 NA1)
  @asia ~w(KR JP1)
  @europe ~w(EUN1 EUW1 TR1 RU)

  def to_zone(region_id) do
    case String.upcase(region_id) do
      reg when reg in @americas -> {:ok, "americas"}
      reg when reg in @asia -> {:ok, "asia"}
      reg when reg in @europe -> {:ok, "europe"}
      _ -> {:error, :invalid_region_id}
    end
  end

  def zones do
    %{
      americas: @americas,
      asia: @asia,
      europe: @europe
    }
  end

  def americas, do: @americas
  def asia, do: @asia
  def europe, do: @europe
end
