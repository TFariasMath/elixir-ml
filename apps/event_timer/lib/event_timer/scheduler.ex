defmodule EventTimer.Scheduler do
  @moduledoc """
  Background scheduler that checks for upcoming events and triggers notifications.
  """

  use GenServer

  alias EventTimer.{Storage, Notifier}

  @check_interval :timer.minutes(1)

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    schedule_check()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:check_events, state) do
    check_and_notify()
    schedule_check()
    {:noreply, state}
  end

  defp schedule_check do
    Process.send_after(self(), :check_events, @check_interval)
  end

  defp check_and_notify do
    today = Date.utc_today()

    events = Storage.all_events()
    notified = Storage.notified_events()

    Enum.each(events, fn event ->
      event_id = event.id
      should_notify = event_id not in notified

      if should_notify do
        case parse_date(event.date) do
          {:ok, event_date} ->
            days_left = Date.diff(event_date, today)

            if days_left > 0 and days_left <= event.alert_days do
              Notifier.notify_event(event, days_left)
              Storage.mark_notified([event_id])
            end

          _ ->
            nil
        end
      end
    end)
  end

  defp parse_date(date) when is_binary(date) do
    Date.from_iso8601(date)
  end

  defp parse_date(date), do: {:ok, date}
end
