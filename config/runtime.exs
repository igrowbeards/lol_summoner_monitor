import Config

riot_api_key = System.get_env("RIOT_API_KEY") ||
  raise """
  Environment variable RIOT_API_KEY is missing.
  Set it in `config/runtime.exs`.
  """

config :summoner_monitor,
  riot_api_key: riot_api_key
