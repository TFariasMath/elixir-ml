defmodule AudioSensor.MixProject do
  use Mix.Project

  def project do
    [
      app: :audio_sensor,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:bumblebee, "~> 0.6.0"},
      {:nx, "~> 0.9.0"},
      {:castore, ">= 0.0.0"}
    ]
  end
end
