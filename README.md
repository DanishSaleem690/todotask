# TaskFlow — Flutter Todo App

A modern, cross-platform Todo List application built with **Flutter 3.x**, **Riverpod**, **Hive**, and **Material 3**.

## Features

- **Authentication** — Login, sign up, form validation, remember me, logout
- **Todo management** — CRUD, priority, due dates, descriptions, undo delete
- **Organization** — Filter by status/priority, search, sort
- **Dashboard** — Stats, progress chart, today's tasks
- **UI** — Light/dark mode, animations, responsive layout (mobile → desktop)

## Architecture

```
lib/
├── main.dart
├── models/          # Domain models
├── screens/         # UI screens
├── widgets/         # Reusable components
├── services/        # Business logic
├── providers/       # Riverpod state management
├── repositories/    # Data access layer
├── utils/           # Helpers, routing, validation
├── themes/          # Material 3 theming
└── storage/         # Hive + SharedPreferences
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x or later
- Dart 3.x

### Setup

1. **Generate platform folders** (if not present):

```bash
cd c:\Users\hamza\Desktop\flutter
flutter create . --org com.taskflow --project-name todo_app
```

2. **Install dependencies**:

```bash
flutter pub get
```

3. **Run the app**:

```bash
flutter run
```

For a specific platform:

```bash
flutter run -d chrome    # Web
flutter run -d windows   # Windows
flutter run -d macos     # macOS
```

## Usage

1. **Sign up** with any email and password (min 6 characters).
2. Sample tasks are seeded automatically on first login.
3. Use the **Dashboard** tab for overview and **Tasks** tab to manage items.
4. Toggle theme from the app bar; use **Remember me** to persist login.

## Tech Stack

| Layer            | Package              |
|------------------|----------------------|
| State management | flutter_riverpod     |
| Local storage    | hive, hive_flutter, shared_preferences |
| Navigation       | go_router            |
| Design           | Material 3           |

## License

MIT
