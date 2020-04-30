defmodule DiscoverRedditBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :discover_reddit_bot,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DiscoverRedditBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_gram, "~> 0.12"},
      {:hackney, "~> 1.12"},
      {:tesla, "~> 1.2.1"},
      {:jason, "~> 1.1"},
      {:logger_file_backend, "0.0.11"}
    ]
  end
end
