# Event Timer

A desktop application for tracking special dates and events with countdown notifications.

## Features

- **Event Management**: Create, edit, and delete events with name, date, description, and customizable alert days
- **Countdown Display**: View your upcoming events with days/weeks/months countdown
- **System Notifications**: Get notified X days before each event (Windows native notifications)
- **Background Operation**: Runs in background, checks events continuously
- **Auto-start**: Configure to start automatically with Windows or Mac

## Requirements

- Elixir 1.14+
- Erlang/OTP 24+
- Windows 10+ or macOS

## Installation

### 1. Clone and Build

```bash
cd event_timer
mix deps.get
mix build
```

### 2. Run Locally

```bash
mix run --no-halt
```

The app will start at http://localhost:4000

### 3. Build Standalone Executable

```bash
mix release
```

Then find the executable in `_build/${MIX_ENV}/rel/event_timer/bin/event_timer`

## Usage

### Adding Events

1. Click "+ Add Event" button
2. Enter event name (e.g., "John's Birthday")
3. Select the event date
4. Optionally add a description
5. Set how many days before to notify (default: 7)
6. Click "Save Event"

### Event List

Events are displayed sorted by date (nearest first). Each event shows:
- Event name
- Countdown (days/weeks/months)
- Date and alert configuration

Passed events appear grayed out.

### System Notifications

When the app is running, it checks every minute for upcoming events. When an event is within the configured alert days, a system notification is displayed.

### Test Notifications

Click "Test Notif" to manually trigger a test notification.

## Auto-start Configuration

### Windows

#### Method 1: Built-in Command

Add to your code:
```elixir
EventTimer.AutoStart.enable()
```

#### Method 2: Manual Startup Folder

1. Press `Win + R`
2. Type `shell:startup`
3. Create a shortcut to the executable

#### Method 3: Registry

```bash
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v EventTimer /t REG_SZ /d "C:\path\to\event_timer.exe"
```

### macOS

#### Method 1: Built-in Command

Add to your code:
```elixir
EventTimer.AutoStart.enable()
```

#### Method 2: LaunchAgent

Create `~/Library/LaunchAgents/com.event_timer.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.event_timer</string>
  <key>ProgramArguments</key>
  <array>
    <string>/path/to/event_timer</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
```

Then run:
```bash
launchctl load ~/Library/LaunchAgents/com.event_timer.plist
```

## Data Storage

Events are stored in:
- Windows: `%APPDATA%/event_timer/events.json`
- Mac: `~/Library/Application Support/event_timer/events.json`

## Project Structure

```
event_timer/
├── lib/
│   ├── event_timer/
│   │   ├── application.ex      # Main application
│   │   ├── storage.ex          # JSON file persistence
│   │   ├── scheduler.ex     # Background event checker
│   │   ├── notifier.ex       # System notifications
│   │   └── auto_start.ex     # Auto-start management
│   └── event_timer_web/
│       ├── endpoint.ex       # Phoenix endpoint
│       ├── router.ex          # Routes
│       ├── controllers/      # Page & event controllers
│       ├── views/             # View helpers
│       └── templates/        # HTML templates
├── config/
│   └── config.exs            # Configuration
├── mix.exs                   # Project file
└── README.md                 # This file
```

## Configuration

Edit `config/config.exs`:

```elixir
config :event_timer, EventTimerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  server: true
```

## License

MIT