defmodule SummonerMonitorTest do
  use ExUnit.Case

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  test "monitor_summoners" do
    use_cassette "recent_summoners" do
      summoner_name = "ThoseLanesOrFeed"
      region = "NA1"

      summoners_from_api_call =
        SummonerMonitor.monitor_summoners(summoner_name, region)

      expected_summoners = [
        "T0NSOFDAMAGE",
        "PhantomThiefJm",
        "Rin4TheWinTezuka",
        "cptcornIog",
        "IIRisk",
        "igvic",
        "wheresmyramen",
        "epicnarlee",
        "pipisey",
        "MSorenstein",
        "Contender Bias",
        "SBI J",
        "TopLaneHokage707",
        "Omness",
        "P4ndamonster",
        "ZAkitehook",
        "Stand Up Kid",
        "wathoow",
        "SuperyiyiyiyiX",
        "TheBigDDuck",
        "UnstoppableVOLI",
        "Logang4LIFE",
        "Ryuuta",
        "yifeigin",
        "Mentrius",
        "Terry Andrews",
        "VeganWiFi",
        "Catboy Bargus",
        " Ricky Španish",
        "LMSISNOTMSL",
        "puebl0inru1ns",
        "qwecwbjkb",
        "Sabercheetah",
        "puddy2345",
        "Dawoon",
        "Bobeaht",
        "Bleu Foncé",
        "Rotane"
      ]

      refute Enum.member?(summoners_from_api_call, summoner_name)

      assert summoners_from_api_call == expected_summoners
    end
  end
end
