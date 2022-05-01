defmodule RiotLolTest do
  use ExUnit.Case

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Lol.Api

  test "summoners_in_recent_matches" do
    use_cassette "recent_summoners" do
      summoner_id = "jkJO5PAoYMKJGERosZusjt31lYCyKc-Ij71k-js86EBEckpoxDwj1nwBwQ"
      summoner_name = "ThoseLanesOrFeed"
      region = "NA1"

      summoners_from_api_call =
        Lol.summoners_in_recent_matches(summoner_id, region, start_watchers: false)

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

  test "extract_summoners_from_match" do
    use_cassette "match_details" do
      match_id = "NA1_4295670986"
      zone = "americas"

      {:ok, match_details} = Api.match_details(match_id, zone)

      summoners_from_match = Lol.extract_summoners_from_match(match_details)

      expected_summoners = [
        {"MSorenstein",
         "Azkcx_dn8r1ia0XXiEIVdciiR1pEaeeXLpGyIUFxqA0Y1E_K8PVMcXlbUJRUu_rTugvyvNrF8tABqA"},
        {"Contender Bias",
         "DDsjB4qfEopjtWADBhXasb9fj4jVgT7Ik-K3K52TRAu2BHT6EuKhq53iMGhUqwPevKChg5u51djqPQ"},
        {"PhantomThiefJm",
         "-mjlHvUCqW0y3bm9ryVwshbB7FBMpf6UsOcLJpwvydFDSsI4QOqRIhsMBe3m53XakH0Pxq7OxSHJPQ"},
        {"ThoseLanesOrFeed",
         "KP7gRk1kUxVVOv34YD6xe1oEv07hwTKoh6efV_BIwYf4FrFgCLTBSz_8Wv46WPwyGWBrLRB7cyHAjg"},
        {"SBI J",
         "WKM6InpuCcv_Lo4VtiDL9oTCA22Ukkw8YUAXGhq03B_TGwIqUYFEvDPQn9eeEkQPDxHWAyshEyf-Xw"},
        {"TopLaneHokage707",
         "NMzQL5l5TSdvk8NulnZbhjkS-u9F8Fo1hCVAJpyiup3NSsoMLZ-nodPscfa58tmzgBdIyCBRgVsN2Q"},
        {"Omness",
         "Pb1tQydXp59gMmSR6gSdN0oozf3yVDEz3zn1RCcjUHwz_KXQFeaZluD1N9StEwOx6UZKV0EOy4M1Rw"},
        {"P4ndamonster",
         "Tlc85jY7Yi1dUHg73bfj4uUri46yYH4SsK13Pohx_DUCsXONpwLUQd30tMhwwzq18C-ws7WXns5Arw"},
        {"ZAkitehook",
         "Dbh0Y2bHXBsMmDDVppVdSEmlrhCAmVp9eW1u3koQcTAZRcpvKzLrsNZSHU0jhIYaLdVrlQLHNNIgUw"},
        {"Stand Up Kid",
         "WVBOEeMchBELn_ztO2Xo3cd3znuch3u5rSkFvN0a0KDQUpYgaNbj-glo_FCtKVL9j480yxdzmTykuQ"}
      ]

      assert expected_summoners == summoners_from_match
    end
  end

  test "concurrently_fetch_match_details" do
    use_cassette "concurrent_match_details" do
      match_ids = ["NA1_4295670986", "NA1_4295599786"]
      zone = "americas"
      results = Lol.concurrently_fetch_match_details(match_ids, zone)

      expected = [
        {"MSorenstein",
         "Azkcx_dn8r1ia0XXiEIVdciiR1pEaeeXLpGyIUFxqA0Y1E_K8PVMcXlbUJRUu_rTugvyvNrF8tABqA"},
        {"Contender Bias",
         "DDsjB4qfEopjtWADBhXasb9fj4jVgT7Ik-K3K52TRAu2BHT6EuKhq53iMGhUqwPevKChg5u51djqPQ"},
        {"PhantomThiefJm",
         "-mjlHvUCqW0y3bm9ryVwshbB7FBMpf6UsOcLJpwvydFDSsI4QOqRIhsMBe3m53XakH0Pxq7OxSHJPQ"},
        {"ThoseLanesOrFeed",
         "KP7gRk1kUxVVOv34YD6xe1oEv07hwTKoh6efV_BIwYf4FrFgCLTBSz_8Wv46WPwyGWBrLRB7cyHAjg"},
        {"SBI J",
         "WKM6InpuCcv_Lo4VtiDL9oTCA22Ukkw8YUAXGhq03B_TGwIqUYFEvDPQn9eeEkQPDxHWAyshEyf-Xw"},
        {"TopLaneHokage707",
         "NMzQL5l5TSdvk8NulnZbhjkS-u9F8Fo1hCVAJpyiup3NSsoMLZ-nodPscfa58tmzgBdIyCBRgVsN2Q"},
        {"Omness",
         "Pb1tQydXp59gMmSR6gSdN0oozf3yVDEz3zn1RCcjUHwz_KXQFeaZluD1N9StEwOx6UZKV0EOy4M1Rw"},
        {"P4ndamonster",
         "Tlc85jY7Yi1dUHg73bfj4uUri46yYH4SsK13Pohx_DUCsXONpwLUQd30tMhwwzq18C-ws7WXns5Arw"},
        {"ZAkitehook",
         "Dbh0Y2bHXBsMmDDVppVdSEmlrhCAmVp9eW1u3koQcTAZRcpvKzLrsNZSHU0jhIYaLdVrlQLHNNIgUw"},
        {"Stand Up Kid",
         "WVBOEeMchBELn_ztO2Xo3cd3znuch3u5rSkFvN0a0KDQUpYgaNbj-glo_FCtKVL9j480yxdzmTykuQ"},
        {"wathoow",
         "woJOlmhJstzhqNJYtRySmomEWAq6qJJk1ttkko-sgctnABUPAjP0mHv1ce0MCkAxNmBpzvqO3Y06ww"},
        {"SuperyiyiyiyiX",
         "5IILTUUiiOI0ZCgVLjWKbIbKzcmYG9M68wTRVaitbN6rfQ5Vh6JScPaewAgieFCod5gLXPuRDH3EuA"},
        {"TheBigDDuck",
         "A5VIhI0rgB86NxXTxi1JYCFUa8_Oi5SCMkZuUB7FoJ7dTy_C77dF3inxCKLz8sCbnke4AenarO6g2Q"},
        {"UnstoppableVOLI",
         "Pi0Dbhl6e99jgWriarofrDT4bEZy_BcIdGh5SVVHZ9jlvf00A4PNTdAh-JDv2KmVvze25wvNAogW1Q"},
        {"Logang4LIFE",
         "EaczvflcaAZS7E_jVT4GDiRdZMt2YqJRo2OFsIrLwa7cmgwuh1QFnNWLDoSSnJVzbng5l3PSu00fJA"},
        {"Ryuuta",
         "SwFXpIkQlYD8uujfI6HTEelSbEPWE1ujyjJO29ySopJquccUV-j4G4QELXPHmK4luJ_LMi8b1ehcSA"},
        {"yifeigin",
         "MmrAUAiAGdBPFHEk5Yn5UO9VeSSoQqOOCx1WAO6_aq4sXxWcdeXcXjnMmdGn9kMneLcijOoQT6zpyg"},
        {"Mentrius",
         "Xrt3QcxEaULWhAoZgdfNSVPS7JXUxWS3gnWK0TF9uLkTckW4-E2369Z5y1oS-1L7q7pEd3vlV6lJAg"}
      ]

      assert results == expected
    end
  end
end
