defmodule SummonerMonitor.MixProject do
  use Mix.Project

  def project do
    [
      app: :summoner_monitor,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SummonerMonitor.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17"},
      {:jason, ">= 1.0.0"},
      {:exvcr, "~> 0.11", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end
