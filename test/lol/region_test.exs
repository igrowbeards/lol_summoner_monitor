defmodule Lol.RegionTest do
  use ExUnit.Case
  alias Lol.Region

  describe "to_zone/1" do
    test "routes to the proper zone for a v4 api compatible region" do
      for region <- Region.americas() do
        assert {:ok, "americas"} = Region.to_zone(region)
      end

      for region <- Region.asia() do
        assert {:ok, "asia"} = Region.to_zone(region)
      end

      for region <- Region.europe() do
        assert {:ok, "europe"} = Region.to_zone(region)
      end
    end

    test "to_zone/1 handles lowercase region ids" do
      for region <- Region.americas() do
        region = String.downcase(region)
        assert {:ok, "americas"} = Region.to_zone(region)
      end

      for region <- Region.asia() do
        region = String.downcase(region)
        assert {:ok, "asia"} = Region.to_zone(region)
      end

      for region <- Region.europe() do
        region = String.downcase(region)
        assert {:ok, "europe"} = Region.to_zone(region)
      end
    end
  end
end
