defmodule SummonerMonitor.SummonerWatcherTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import ExUnit.CaptureLog
  require Logger

  alias SummonerMonitor.SummonerWatcher

  setup do
    args = %{
      summoner_name: "MSorenstein",
      puuid: "Azkcx_dn8r1ia0XXiEIVdciiR1pEaeeXLpGyIUFxqA0Y1E_K8PVMcXlbUJRUu_rTugvyvNrF8tABqA",
      zone: "americas",
      worker_name: :test_summoner_worker,
      mode: :manual
    }

    {:ok, _pid} = start_supervised({SummonerWatcher, args})

    # we want to assert against the logs in this test,
    # but don't want to donk up the log level from the config, whatever it may be
    # so we change it in the setup and then reset it on_exit
    Logger.configure(level: :debug)

    on_exit(fn ->
      level = Application.get_env(:logger, :level) || :error
      Logger.configure(level: level)
    end)

    %{setup_args: args}
  end

  describe "summoner watcher" do
    test "worker does not log a match completion for it's initial check", %{setup_args: args} do
      {_result, log} =
        with_log(fn ->
          use_cassette "recent_matches_initial", custom: true do
            Process.send(args.worker_name, :check, [])
            :timer.sleep(100)
          end
        end)

      assert log =~ "querying api for recent matches for #{args.puuid}"

      # initial call to api does not trigger a "completed match" log event
      refute log =~ "Summoner #{args.summoner_name} completed match"
    end

    test "worker logs new matches that are found during checks", %{setup_args: args} do
      {_result, log} =
        with_log(fn ->
          # initial query
          use_cassette "recent_matches_initial", custom: true do
            Process.send(args.worker_name, :check, [])
            :timer.sleep(200)
          end

          use_cassette "recent_matches_updated", custom: true do
            Process.send(args.worker_name, :check, [])
            :timer.sleep(200)
          end
        end)

      expected_completed_match_id = "NA1_5296379965"

      assert log =~
               "Summoner #{args.summoner_name} completed match #{expected_completed_match_id}"
    end
  end
end
