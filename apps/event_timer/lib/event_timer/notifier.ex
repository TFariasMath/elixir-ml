defmodule EventTimer.Notifier do
  @moduledoc """
  Handles system notifications across platforms.
  """

  @spec send_notification(String.t(), String.t()) :: :ok | {:error, any()}
  def send_notification(title, body) do
    case :os.type() do
      {:win32, _} ->
        send_windows_notification(title, body)

      {:darwin, _} ->
        send_mac_notification(title, body)

      _ ->
        send_fallback_notification(title, body)
    end
  end

  defp send_windows_notification(title, body) do
    escaped_title = String.replace(title, "'", "")
    escaped_body = String.replace(body, "'", "")

    script = """
    Add-Type -AssemblyName System.Windows.Forms
    $notifyIcon = New-Object System.Windows.Forms.NotifyIcon
    $notifyIcon.Icon = [System.Drawing.SystemIcons]::Information
    $notifyIcon.Visible = $true
    $notifyIcon.ShowBalloonTip(10000, "#{escaped_title}", "#{escaped_body}", "Info")
    Start-Sleep -Seconds 2
    $notifyIcon.Dispose()
    """

    temp_script = System.tmp_dir!() |> Path.join("event_timer_notif_#{:rand.uniform(10000)}.ps1")
    File.write!(temp_script, script)

    try do
      System.cmd("powershell", ["-ExecutionPolicy", "Bypass", "-File", temp_script],
        stderr_to_stdout: true
      )
    after
      File.rm(temp_script)
    end

    :ok
  rescue
    e ->
      {:error, e}
  end

  defp send_mac_notification(title, body) do
    script = "display notification \"#{body}\" with title \"#{title}\""
    {_, 0} = System.cmd("osascript", ["-e", script])
    :ok
  rescue
    _ -> :ok
  end

  defp send_fallback_notification(title, body) do
    IO.puts("=== NOTIFICATION: #{title} - #{body} ===")
    :ok
  end

  def notify_event(event, days_left) do
    title = "Event Alert: #{event.name}"
    body = "#{days_left} day#{if days_left == 1, do: "", else: "s"} until #{event.date}"
    send_notification(title, body)
  end
end
