defmodule EventTimerWeb.PageView do
  @moduledoc """
  Simple view module for rendering event templates.
  """

  def countdown(date) do
    today = Date.utc_today()

    case Date.from_iso8601(date) do
      {:ok, event_date} ->
        diff = Date.diff(event_date, today)

        cond do
          diff < 0 -> "Passed"
          diff == 0 -> "Today!"
          diff == 1 -> "1 day"
          diff < 7 -> "#{diff} days"
          diff < 30 -> "#{div(diff, 7)}w #{rem(diff, 7)}d"
          true -> "#{div(diff, 30)}m #{rem(diff, 30)}d"
        end

      _ ->
        "Unknown"
    end
  end

  def passed?(date) do
    case Date.from_iso8601(date) do
      {:ok, event_date} ->
        Date.compare(event_date, Date.utc_today()) == :lt

      _ ->
        false
    end
  end

  def next_event_name([]), do: "None"
  def next_event_name([event | _]), do: event.name
end
