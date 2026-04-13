defmodule EventTimer.Storage do
  @moduledoc """
  Handles persistence of events to local JSON file.
  """

  defstruct [:id, :name, :date, :description, :alert_days, :inserted_at, :updated_at]

  defmodule Event do
    defstruct id: nil,
              name: nil,
              date: nil,
              description: "",
              alert_days: 7,
              inserted_at: nil,
              updated_at: nil
  end

  def data_dir, do: get_data_dir()
  def events_file, do: Path.join(get_data_dir(), "events.json")

  defp get_data_dir do
    case Application.get_env(:event_timer, :data_dir) do
      nil -> Path.join(System.get_env("APPDATA") || System.get_env("HOME"), "event_timer")
      dir -> dir
    end
  end

  def ensure_data_dir do
    dir = get_data_dir()

    unless File.exists?(dir) do
      File.mkdir_p!(dir)
    end
  end

  def all_events do
    ensure_data_dir()

    events_file_path = events_file()

    case File.read(events_file_path) do
      {:ok, contents} ->
        case Jason.decode(contents) do
          {:ok, events} ->
            Enum.map(events, &to_event/1)

          _ ->
            []
        end

      _ ->
        []
    end
  end

  def get_event(id) do
    all_events()
    |> Enum.find(fn event -> event.id == id end)
  end

  def create_event(attrs) do
    name = attrs[:name]
    date = attrs[:date]

    if is_nil(name) or name == "" or is_nil(date) or date == "" do
      {:error, "name and date are required"}
    else
      event = %__MODULE__.Event{
        id: generate_id(),
        name: name,
        date: date,
        description: attrs[:description] || "",
        alert_days: attrs[:alert_days] || 7,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }

      save_event(event)
    end
  end

  def update_event(id, attrs) do
    name = attrs[:name]
    date = attrs[:date]

    if is_nil(name) or name == "" or is_nil(date) or date == "" do
      {:error, "name and date are required"}
    else
      events = all_events()

      updated_events =
        Enum.map(events, fn event ->
          if event.id == id do
            Map.merge(event, %{
              name: name,
              date: date,
              description: attrs[:description] || event.description,
              alert_days: attrs[:alert_days] || event.alert_days,
              updated_at: DateTime.utc_now()
            })
          else
            event
          end
        end)

      write_events(updated_events)
    end
  end

  def delete_event(id) do
    events =
      all_events()
      |> Enum.filter(fn event -> event.id != id end)

    write_events(events)
  end

  def events_for_alert(days_before \\ 7) do
    today = Date.utc_today()
    target_date = Date.add(today, days_before)

    all_events()
    |> Enum.filter(fn event ->
      case parse_date(event.date) do
        {:ok, event_date} ->
          Date.compare(event_date, today) == :gt and
            Date.compare(event_date, target_date) != :gt

        _ ->
          false
      end
    end)
  end

  def notified_events do
    ensure_data_dir()
    notified_file = Path.join(get_data_dir(), "notified.json")

    case File.read(notified_file) do
      {:ok, contents} ->
        case Jason.decode(contents) do
          {:ok, ids} -> ids
          _ -> []
        end

      _ ->
        []
    end
  end

  def mark_notified(event_ids) when is_list(event_ids) do
    ensure_data_dir()
    notified_file = Path.join(get_data_dir(), "notified.json")

    existing = notified_events()
    new_notified = Enum.uniq(existing ++ event_ids)

    File.write!(notified_file, Jason.encode!(new_notified))
  end

  def clear_notified do
    ensure_data_dir()
    notified_file = Path.join(get_data_dir(), "notified.json")
    File.rm_rf(notified_file)
  end

  defp save_event(new_event) do
    events = all_events()
    updated_events = events ++ [new_event]
    write_events(updated_events)
    new_event
  end

  defp write_events(events) do
    ensure_data_dir()
    encoded = Jason.encode!(Enum.map(events, &Map.from_struct/1), pretty: true)
    File.write!(events_file(), encoded)
    events
  end

  defp generate_id do
    :crypto.hash(:md5, "#{DateTime.utc_now()}-#{:rand.uniform(1_000_000)}")
    |> Base.encode16(case: :lower)
    |> String.slice(0, 16)
  end

  defp to_event(map) do
    %__MODULE__.Event{
      id: Map.get(map, "id") || Map.get(map, :id),
      name: Map.get(map, "name") || Map.get(map, :name),
      date: Map.get(map, "date") || Map.get(map, :date),
      description: Map.get(map, "description") || Map.get(map, :description, ""),
      alert_days: Map.get(map, "alert_days") || Map.get(map, :alert_days, 7),
      inserted_at: Map.get(map, "inserted_at") || Map.get(map, :inserted_at),
      updated_at: Map.get(map, "updated_at") || Map.get(map, :updated_at)
    }
  end

  defp parse_date(date) when is_binary(date) do
    Date.from_iso8601(date)
  end

  defp parse_date(date), do: {:ok, date}
end
