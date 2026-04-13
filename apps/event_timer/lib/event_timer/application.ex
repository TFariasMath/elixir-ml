defmodule EventTimer.Application do
  use Application

  alias EventTimer.{Storage, Scheduler}

  @impl true
  def start(_type, _args) do
    Storage.ensure_data_dir()
    Scheduler.start_link()

    children = [
      {Phoenix.PubSub, name: EventTimer.PubSub},
      EventTimerWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: EventTimer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
