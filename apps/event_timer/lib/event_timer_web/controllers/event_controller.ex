defmodule EventTimerWeb.EventController do
  use EventTimerWeb, :controller

  alias EventTimer.Storage

  def create(conn, params) do
    event_params = %{
      name: Map.get(params, "name"),
      date: Map.get(params, "date"),
      description: Map.get(params, "description", ""),
      alert_days: Map.get(params, "alert_days", 7) |> parse_int()
    }

    case Storage.create_event(event_params) do
      event ->
        json(conn, %{success: true, event: event})

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{success: false, error: inspect(reason)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    event_params = %{
      name: Map.get(params, "name"),
      date: Map.get(params, "date"),
      description: Map.get(params, "description", ""),
      alert_days: Map.get(params, "alert_days", 7) |> parse_int()
    }

    case Storage.update_event(id, event_params) do
      _events ->
        json(conn, %{success: true})

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{success: false, error: inspect(reason)})
    end
  end

  def delete(conn, %{"id" => id}) do
    Storage.delete_event(id)
    json(conn, %{success: true})
  end

  def test_notification(conn, _params) do
    case Storage.all_events() do
      [] ->
        json(conn, %{success: false})

      [event | _] ->
        EventTimer.Notifier.notify_event(event, 7)
        json(conn, %{success: true})
    end
  end

  defp parse_int(val) when is_integer(val), do: val

  defp parse_int(val) when is_binary(val) do
    case Integer.parse(val) do
      {int, _} -> int
      _ -> 7
    end
  end

  defp parse_int(_), do: 7
end
