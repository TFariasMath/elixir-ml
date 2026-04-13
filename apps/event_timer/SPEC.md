# Event Timer - Special Dates Countdown App

## 1. Project Overview

**Project Name:** Event Timer
**Type:** Desktop Application (Windows/Mac)
**Core Functionality:** A background application that tracks special dates/events and displays system notifications countdown alerts before each event occurs.
**Target Users:** General users who want to remember important dates (birthdays, anniversaries, bills, appointments, etc.)

## 2. Technical Stack

- **Language:** Elixir 1.14+
- **Framework:** Phoenix Framework with PhoenixDesktop
- **Notifications:** WinRT (Windows) / NotificationCenter (Mac)
- **Storage:** JSON file (application_data/event_timer/events.json)
- **Build:** Mix + Distillery/Elixir Launcher

## 3. UI/UX Specification

### 3.1 Window Structure

- **Main Window:** Single window application (800x600, resizable min 600x400)
- **System Tray:** App minimizes to tray, runs in background
- **Dialogs:** Modal dialogs for add/edit events

### 3.2 Visual Design

- **Color Palette:**
  - Primary: #4A90D9 (blue)
  - Secondary: #2C3E50 (dark gray)
  - Accent: #E74C3C (red for urgent)
  - Background: #F5F6FA (light gray)
  - Success: #27AE60 (green)
  - Text Primary: #2C3E50
  - Text Secondary: #7F8C8D

- **Typography:**
  - Font Family: System default (Segoe UI on Windows, SF Pro on Mac)
  - Heading: 24px bold
  - Subheading: 18px semibold
  - Body: 14px regular
  - Small: 12px

- **Spacing:** 8px base unit (multiples of 8)

### 3.3 Components

#### Main Window Layout
```
┌─────────────────────────────────────────────────────┐
│ [Header]                                    [_][□][X]│
│   Event Timer                          [Settings ⚙] │
├─────────────────────────────────────────────────────┤
│ [Sidebar]        │ [Content Area]                     │
│                │                                    │
│ + Add Event    │  Upcoming Events                    │
│                │  ┌────────────────────────────┐    │
│                │  │ 🎂 John's Birthday        │    │
│ Events List    │  │    15 days, 3 hours       │    │
│ • John's Bday  │  │    Dec 25, 2024          │    │
│ • Anniversary │  └────────────────────────────┘    │
│ • Payment Due  │  ┌────────────────────────────┐    │
│                │  │ 💼 Team Meeting             │    │
│                │  │    2 days                  │    │
│                │  │    Jan 10, 2025             │    │
│                │  └────────────────────────────┘    │
│                │                                    │
├─────────────────────────────────────────────────────┤
│ [Status Bar] Events: 3 | Next: John's Birthday     │
└─────────────────────────────────────────────────────┘
```

#### Add/Edit Event Dialog
```
┌────────────────────────────────────┐
│ Add New Event                    X │
├────────────────────────────────────┤
│ Event Name:  [________________]     │
│                                    │
│ Date:       [📅 Select Date   ]   │
│                                    │
│ Description:                       │
│ [______________________________]    │
│ [______________________________]    │
│                                    │
│ Alert Days Before: [7] (1-30)       │
│                                    │
│         [Cancel]  [Save Event]      │
└────────────────────────────────────┘
```

### 3.4 Component States

- **Buttons:** Default, Hover (lighten 10%), Active (darken 5%), Disabled (50% opacity)
- **Event Cards:** Default, Hover (shadow), Selected (border accent)
- **Inputs:** Default, Focus (border primary), Error (border red)

## 4. Functional Specification

### 4.1 Core Features

#### Event Management
1. **Create Event**
   - Name (required, max 100 chars)
   - Date (required, future date)
   - Description (optional, max 500 chars)
   - Alert X days before (configurable 1-30 days, default 7)

2. **Edit Event**
   - Modify any field
   - Preserve alert settings

3. **Delete Event**
   - Confirmation dialog
   - Remove from storage

4. **List Events**
   - Sorted by date (nearest first)
   - Show countdown (days and hours)
   - Visual indicator for passed events (grayed out)

#### Notifications
1. **Alert Trigger**
   - Check every minute when app is running
   - Trigger at configured days before event
   - Persistent notification until user acknowledges

2. **Notification Display**
   - System notification (not in-app only)
   - Title: "Event Alert: {event_name}"
   - Body: "{X} days until {date}"
   - Action buttons: "View" / "Dismiss"

3. **Alert Configuration**
   - User sets X days (1-30) per event
   - Global default: 7 days

#### Background Operation
1. **System Tray**
   - Minimize to tray on close
   - Tray icon with context menu
   - Menu: Show Window, Settings, Exit

2. **Auto-start**
   - Register with Windows: Registry key or Startup folder
   - Register with Mac: LaunchAgents
   - Start minimized to tray

3. **Persistent Timer**
   - Check events even when window minimized
   - System notification triggers work in background

### 4.2 Data Flow

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  UI Layer    │────▶│ Business     │────▶│ Data Layer   │
│  (LiveView)  │◀────│ Logic        │◀────│ (JSON)       │
└──────────────┘     └──────────────┘     └──────────────┘
       │                     │                     │
       ▼                     ▼                     ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ Desktop      │     │ Notification │     │ File System  │
│ Components   │     │ Service      │     │ (events.json)│
└──────────────┘     └──────────────┘     └──────────────┘
```

### 4.3 Key Modules

- **EventTimer.Application** - Main application module
- **EventTimer.Events** - Event management (CRUD)
- **EventTimer.Notifications** - System notification handling
- **EventTimer.Storage** - JSON file persistence
- **EventTimer.Scheduler** - Background timer for alerts
- **EventTimerWeb** - Phoenix endpoints
- **EventTimerWeb.Endpoint** - Phoenix endpoint
- **EventTimerWeb.PageController** - Main page handlers
- **EventTimerWeb.EventView** - LiveView components

## 5. Acceptance Criteria

### 5.1 Event Management
- [ ] User can create an event with name, date, description, alert days
- [ ] User can edit existing events
- [ ] User can delete events with confirmation
- [ ] Events persist after app restart

### 5.2 Countdown Display
- [ ] Events sorted by date (nearest first)
- [ ] Countdown shows days and hours
- [ ] Passed events shown as grayed out

### 5.3 Notifications
- [ ] System notification appears at configured days before
- [ ] Notification shows event name and days remaining
- [ ] Notifications are persistent until dismissed

### 5.4 Background Operation
- [ ] App minimizes to system tray
- [ ] App can run in background without window
- [ ] Notifications work when minimized

### 5.5 Auto-start
- [ ] App can be configured to start with Windows
- [ ] App can be configured to start with Mac
- [ ] Starts minimized to tray

### 5.6 Packaging
- [ ] .exe file builds successfully for Windows
- [ ] App runs standalone without Elixir installed
- [ ] Storage created in appropriate user directory