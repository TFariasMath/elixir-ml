defmodule EventTimerWeb.PageViewTest do
  use ExUnit.Case, async: true

  alias EventTimerWeb.PageView

  describe "countdown/1" do
    test "returns 'Passed' for past dates" do
      assert PageView.countdown("2020-01-01") == "Passed"
    end

    test "returns 'Today!' for today's date" do
      today = Date.utc_today() |> Date.to_iso8601()
      assert PageView.countdown(today) == "Today!"
    end

    test "returns '1 day' for tomorrow" do
      tomorrow = Date.add(Date.utc_today(), 1) |> Date.to_iso8601()
      assert PageView.countdown(tomorrow) == "1 day"
    end

    test "returns days for dates within a week" do
      in_5_days = Date.add(Date.utc_today(), 5) |> Date.to_iso8601()
      assert PageView.countdown(in_5_days) == "5 days"
    end

    test "returns weeks and days for dates within a month" do
      in_20_days = Date.add(Date.utc_today(), 20) |> Date.to_iso8601()
      result = PageView.countdown(in_20_days)
      assert String.contains?(result, "w")
      assert String.contains?(result, "d")
    end

    test "returns months and days for dates beyond a month" do
      in_60_days = Date.add(Date.utc_today(), 60) |> Date.to_iso8601()
      result = PageView.countdown(in_60_days)
      assert String.contains?(result, "m")
      assert String.contains?(result, "d")
    end

    test "returns 'Unknown' for invalid dates" do
      assert PageView.countdown("invalid-date") == "Unknown"
    end
  end

  describe "passed?/1" do
    test "returns true for past dates" do
      assert PageView.passed?("2020-01-01") == true
    end

    test "returns false for today's date" do
      today = Date.utc_today() |> Date.to_iso8601()
      assert PageView.passed?(today) == false
    end

    test "returns false for future dates" do
      future = Date.add(Date.utc_today(), 1) |> Date.to_iso8601()
      assert PageView.passed?(future) == false
    end

    test "returns false for invalid dates" do
      assert PageView.passed?("invalid") == false
    end
  end

  describe "next_event_name/1" do
    test "returns 'None' for empty list" do
      assert PageView.next_event_name([]) == "None"
    end

    test "returns name of first event" do
      events = [%{name: "First"}, %{name: "Second"}]
      assert PageView.next_event_name(events) == "First"
    end
  end
end
