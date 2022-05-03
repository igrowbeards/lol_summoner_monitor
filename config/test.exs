import Config

config :logger, level: :error

config :exvcr,
  vcr_cassette_library_dir: "test/fixture/lol/vcr_cassettes",
  custom_cassette_library_dir: "test/fixture/lol/vcr_cassettes/custom/",
  filter_request_headers: ["X-Riot-Token"]

# disable the limiter in test
config :summoner_monitor,
  rate_limiter: [
    enabled: false
  ]
