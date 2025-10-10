# Study Planner App

A modern, elegant Flutter application designed to help students and professionals manage their study schedules and tasks efficiently. The app provides comprehensive task management capabilities.

## Features

### Core Functionality
- **Task Management**: Create, edit, delete, and mark tasks as complete
- **Calendar Integration**: Visual calendar view with task scheduling
- **Today's View**: Focus on today's tasks with a clean, organized interface
- **Reminder System**: Set custom reminders for important tasks
- **Persistent Storage**: All data is saved locally using SharedPreferences


## Architecture

### Project Structure
```
lib/
├── main.dart                # App entry point and initialization
├── models/
│   └── task.dart            # Task data model
├── routes/
│   └── app_routes.dart      # Navigation routes configuration
├── screens/
│   ├── today_screen.dart    # Today's tasks view
│   ├── calendar_screen.dart # Calendar with task scheduling
│   ├── new_task_screen.dart # Task creation and editing
│   └── settings_screen.dart # App settings and preferences
├── services/
│   ├── task_storage.dart    # Data persistence service
│   └── reminder_service.dart  # Reminder management
└── widgets/
    ├── task_tile.dart       # Reusable task display component
    └── custom_button.dart   # Custom button component
```

### Key Components

#### Data Model (`models/task.dart`)
The `Task` class represents the core data structure with the following properties:
- `id`: Unique identifier
- `title`: Task title (required)
- `description`: Optional task description
- `dueDate`: Task due date
- `reminderDateTime`: Optional reminder time
- `done`: Completion status
- `reminderShown`: Reminder display status

#### Services

**TaskStorage Service** (`services/task_storage.dart`)
- Singleton pattern implementation
- Uses SharedPreferences for local data persistence
- Provides CRUD operations for tasks
- Manages reminder settings

**ReminderService** (`services/reminder_service.dart`)
- Handles reminder logic and notifications
- Shows reminder dialogs when tasks are due
- Manages reminder state tracking

#### Screens

**TodayScreen** (`screens/today_screen.dart`)
- Displays tasks scheduled for the current day
- Features pull-to-refresh functionality
- Shows encouraging message when no tasks are scheduled
- Provides quick access to task creation

**CalendarScreen** (`screens/calendar_screen.dart`)
- Interactive calendar using `table_calendar` package
- Week and month view options
- Visual indicators for days with tasks
- Task list for selected dates

**NewTaskScreen** (`screens/new_task_screen.dart`)
- Form for creating and editing tasks
- Date and time pickers with custom dark theme
- Input validation for required fields
- Supports both creation and editing modes

**SettingsScreen** (`screens/settings_screen.dart`)
- Toggle for enabling/disabling reminders
- Storage method information
- App information and version details

#### Custom Widgets

**TaskTile** (`widgets/task_tile.dart`)
- Reusable component for displaying individual tasks
- Checkbox for marking completion
- Popup menu for edit/delete actions
- Displays task details including due date and reminder time

**CustomButton** (`widgets/custom_button.dart`)
- Styled button component with customizable colors
- Consistent padding and styling across the app

## Dependencies

### Core Dependencies
- **flutter**: Flutter SDK
- **cupertino_icons**: iOS-style icons
- **shared_preferences**: Local data storage
- **table_calendar**: Calendar widget for task scheduling
- **intl**: Internationalization and date formatting

### Development Dependencies
- **flutter_test**: Testing framework
- **flutter_lints**: Code quality and style enforcement

##  Getting Started

### Prerequisites
- Flutter SDK (version 3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android device/emulator or iOS simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd study_planner
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## Platform Support

The app is built with Flutter and supports:
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Web**: Modern browsers with Flutter web support
- **Windows**: Windows 10+
- **macOS**: macOS 10.14+
- **Linux**: Ubuntu 18.04+

##  Configuration

### App Configuration
- **Theme**: Dark theme with brown primary swatch
- **Debug Banner**: Disabled for cleaner UI
- **Visual Density**: Adaptive platform density

### Storage Configuration
- **Method**: SharedPreferences (local device storage)
- **Data Format**: JSON serialization
- **Persistence**: Automatic save on data changes

## Testing

Run tests using:
```bash
flutter test
```

##  Build Information

- **Version**: 1.0.0+1
- **Build Number**: 1
- **Flutter SDK**: ^3.9.2
- **Dart SDK**: ^3.9.2

