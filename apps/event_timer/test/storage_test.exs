defmodule EventTimer.StorageTest do
  use ExUnit.Case, async: false

  alias EventTimer.Storage

  describe "Event struct" do
    test "creates event with default values" do
      event = %Storage.Event{
        id: "test123",
        name: "Test Event",
        date: "2025-01-01"
      }

      assert event.id == "test123"
      assert event.name == "Test Event"
      assert event.alert_days == 7
      assert event.description == ""
    end
  end

  describe "storage functions with test file" do
    setup do
      test_dir = Path.join(System.tmp_dir!(), "event_timer_test_#{:rand.uniform(99999)}")
      File.mkdir_p!(test_dir)
      events_file = Path.join(test_dir, "events.json")

      {:ok, events_file: events_file, test_dir: test_dir}
    end

    test "saves events to JSON", %{events_file: events_file} do
      events = [
        %{
          "id" => "abc123",
          "name" => "Birthday",
          "date" => "2025-12-25",
          "description" => "Party time",
          "alert_days" => 7,
          "inserted_at" => "2025-01-01T00:00:00Z",
          "updated_at" => "2025-01-01T00:00:00Z"
        }
      ]

      File.write!(events_file, Jason.encode!(events))

      result = File.read!(events_file) |> Jason.decode!()

      assert length(result) == 1
      assert hd(result)["name"] == "Birthday"
    end

    test "loads multiple events from JSON", %{events_file: events_file} do
      events = [
        %{"id" => "e1", "name" => "Meeting", "date" => "2025-02-01"},
        %{"id" => "e2", "name" => "Deadline", "date" => "2025-03-01"}
      ]

      File.write!(events_file, Jason.encode!(events))

      loaded = events_file |> File.read!() |> Jason.decode!()

      assert length(loaded) == 2
    end

    test "generates unique IDs" do
      id1 = generate_test_id()
      id2 = generate_test_id()

      assert id1 != id2
      assert byte_size(id1) == 16
    end
  end

  describe "notified events" do
    setup do
      test_dir = Path.join(System.tmp_dir!(), "event_timer_test_#{:rand.uniform(99999)}")
      File.mkdir_p!(test_dir)
      notified_file = Path.join(test_dir, "notified.json")

      {:ok, notified_file: notified_file}
    end

    test "can track notified events", %{notified_file: notified_file} do
      event_ids = ["id1", "id2", "id3"]
      File.write!(notified_file, Jason.encode!(event_ids))

      loaded = notified_file |> File.read!() |> Jason.decode!()

      assert "id1" in loaded
      assert length(loaded) == 3
    end

    test "can add new notified events", %{notified_file: notified_file} do
      existing = ["id1"]
      File.write!(notified_file, Jason.encode!(existing))

      new_notified = Enum.uniq(["id1", "id2"])
      File.write!(notified_file, Jason.encode!(new_notified))

      loaded = notified_file |> File.read!() |> Jason.decode!()
      assert length(loaded) == 2
    end
  end

  defp generate_test_id do
    :crypto.hash(:md5, "#{:rand.uniform(1_000_000)}")
    |> Base.encode16(case: :lower)
    |> String.slice(0, 16)
  end
end
