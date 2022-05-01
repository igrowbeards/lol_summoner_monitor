defmodule SummonerMonitorTest do
  use ExUnit.Case
  doctest SummonerMonitor

  test "greets the world" do
    assert SummonerMonitor.hello() == :world
  end
end
