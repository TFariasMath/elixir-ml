defmodule EventTimerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :event_timer

  plug(Plug.Static, at: "/", from: :event_timer, gzip: false, only: ~w(css js images))

  plug(EventTimerWeb.Router)
end
