import Config

config :event_timer, EventTimerWeb.Endpoint,
  url: [host: "localhost"],
  http: [port: System.get_env("PORT") || if(config_env() == :test, do: 4002, else: 4000)],
  server: config_env() != :test,
  live_view: [signing_salt: "event_timer_secret_salt"]

config :logger, :console,
  format: "$time $level $message\n",
  level: :info

config :phoenix, :json_library, Jason
