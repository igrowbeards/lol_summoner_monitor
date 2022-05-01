import Config

config :logger, level: :error

config :exvcr,
  vcr_cassette_library_dir: "test/fixture/lol/vcr_cassettes",
  filter_request_headers: ["X-Riot-Token"]
