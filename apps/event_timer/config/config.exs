import Config

config :event_timer, EventTimerWeb.Endpoint,
  url: [host: "localhost"],
  http: [ip: {127, 0, 0, 1}, port: if(Mix.env() == :test, do: 4002, else: 4000)],
  server: Mix.env() != :test,
  adapter: Bandit.PhoenixAdapter,
  live_view: [signing_salt: "event_timer_secret_salt_12345"]

config :event_timer, :app_path,
  windows: "event_timer.bat"

config :logger, :console,
  format: "$time $level $message\n",
  level: :info

config :phoenix, :json_library, Jason
