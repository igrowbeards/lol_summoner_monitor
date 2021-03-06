import Config

config :tesla, adapter: Tesla.Adapter.Hackney

# these settings are for a dev key
config :summoner_monitor,
  rate_limiter: [
    long_period: :timer.minutes(2),
    long_limit: 200,
    short_period: :timer.seconds(20),
    short_limit: 20
  ],
  summoner_watcher: [
    runtime: :timer.hours(1),
    check_interval: :timer.minutes(1)
  ]

import_config "#{config_env()}.exs"
