defmodule EventTimer.MixProject do
  use Mix.Project

  def project do
    [
      app: :event_timer,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {EventTimer.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7.0"},
      {:phoenix_html, "~> 3.3"},
      {:bandit, "~> 1.5"},
      {:jason, "~> 1.4"}
    ]
  end
end
