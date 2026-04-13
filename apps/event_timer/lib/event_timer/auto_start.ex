defmodule EventTimer.AutoStart do
  @moduledoc """
  Manages auto-start configuration for Windows and Mac.
  """

  def get_app_path do
    # Calcula la ruta automáticamente basándose en la ubicación del proyecto
    File.cwd!()
    |> Path.join("_build/prod/rel/event_timer/bin/event_timer.bat")
  end

  def enable_windows do
    app_path = get_app_path() |> String.replace("/", "\\")
    working_dir = get_app_path() |> Path.dirname() |> String.replace("/", "\\")

    startup_dir =
      System.get_env("APPDATA") |> Path.join("Microsoft/Windows/Start Menu/Programs/Startup")

    shortcut_path = Path.join(startup_dir, "EventTimer.lnk") |> String.replace("/", "\\")

    cmd = ~s"""
    powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('#{shortcut_path}'); $Shortcut.TargetPath = '#{app_path}'; $Shortcut.WorkingDirectory = '#{working_dir}'; $Shortcut.Description = 'Event Timer'; $Shortcut.Save()"
    """

    result = :os.cmd(String.to_charlist(cmd))
    File.exists?(shortcut_path)
  end

  def disable_windows do
    startup_dir =
      System.get_env("APPDATA") |> Path.join("Microsoft/Windows/Start Menu/Programs/Startup")

    shortcut_path = Path.join(startup_dir, "EventTimer.lnk")
    File.rm_rf(shortcut_path)
    true
  end

  def enable_mac do
    app_path = get_app_path()
    plist_path = Path.join(System.user_home!(), "Library/LaunchAgents/com.event_timer.plist")

    plist = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>com.event_timer</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{app_path}</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
    </dict>
    </plist>
    """

    File.write!(plist_path, plist)
    {_, 0} = System.cmd("launchctl", ["load", plist_path])
    true
  rescue
    _ -> false
  end

  def disable_mac do
    plist_path = Path.join(System.user_home!(), "Library/LaunchAgents/com.event_timer.plist")
    System.cmd("launchctl", ["unload", plist_path])
    File.rm_rf(plist_path)
    true
  end

  def enable do
    case :os.type() do
      {:win32, _} -> enable_windows()
      {:darwin, _} -> enable_mac()
      _ -> false
    end
  end

  def disable do
    case :os.type() do
      {:win32, _} -> disable_windows()
      {:darwin, _} -> disable_mac()
      _ -> false
    end
  end

  def set(true), do: enable()
  def set(false), do: disable()

  def enabled? do
    case :os.type() do
      {:win32, _} ->
        startup_dir =
          System.get_env("APPDATA") |> Path.join("Microsoft/Windows/Start Menu/Programs/Startup")

        File.exists?(Path.join(startup_dir, "EventTimer.lnk"))

      {:darwin, _} ->
        plist_path =
          Path.join(System.user_home!(), "Library/LaunchAgents/com.event_timer.plist")

        File.exists?(plist_path)

      _ ->
        false
    end
  end
end
