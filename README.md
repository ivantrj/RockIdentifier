# Flutter MVVM Template with Provider & GetIt - Snake Identifier

## Overview

This template provides a solid starting point for new Flutter applications, aiming to accelerate development by providing a structured architecture and common boilerplate features. It utilizes the Model-View-ViewModel (MVVM) pattern combined with Flutter's built-in state management (`ChangeNotifier`, `ValueNotifier`), `provider` for UI binding, and `get_it` for service location and dependency injection.

**Core Goals:**

- **Rapid Development:** Skip repetitive setup for architecture, navigation, theming, etc.
- **Scalability:** Maintainable structure using MVVM and dependency injection.
- **Clear Separation of Concerns:** Keep UI, state/business logic, and data layers distinct.
- **Leverage Standard Packages:** Use well-regarded packages like `provider` and `get_it`.

## Architecture: MVVM

The template follows the MVVM pattern:

- **Model:** Represents your application's data (e.g., User, Workout, Setting). These are typically plain Dart objects located in `lib/data/models/`. They may include `toJson`/`fromJson` methods for serialization.
- **View:** The Flutter Widgets (Screens/UI). Responsible for displaying data from the ViewModel and forwarding user interactions to it. Located within specific feature directories (e.g., `lib/features/home/view/`). Views should be as "dumb" as possible.
- **ViewModel:** Acts as the bridge between the View and the Model/Services.
  - Extends `ChangeNotifier` to notify the View of state changes.
  - Holds UI state (e.g., loading status, error messages, data lists).
  - Contains presentation logic and handles user input.
  - Interacts with Services and Repositories (fetched via `GetIt`) to get/manipulate data.
  - Located within specific feature directories (e.g., `lib/features/home/viewmodel/`).

## State Management

This template uses a combination approach:

1.  **`ChangeNotifier` / `ValueNotifier`:** Used within ViewModels to hold and expose state that the UI needs to react to. `ChangeNotifier` is primary for ViewModels; `ValueNotifier` can be used for simpler, individual reactive values.
2.  **`provider` Package:** The standard way to connect `ChangeNotifier` ViewModels (and other services/values) to the Flutter widget tree.
    - `ChangeNotifierProvider`: Used to create/provide ViewModel instances to specific subtrees (often at the screen level).
    - `Consumer` / `context.watch<T>()`: Used within Views to listen to ViewModel changes and rebuild the UI accordingly.
    - `context.read<T>()`: Used to access a ViewModel/Service for calling methods without listening to changes.
    - `MultiProvider`: Used in `main.dart` to provide app-wide services (like `ThemeService`).
3.  **`get_it` Package (Service Locator):** Used for dependency injection _outside_ the widget tree, primarily for:
    - Registering and retrieving singleton or factory instances of Services (e.g., `ApiService`, `PreferencesService`, `WorkoutPlanService`) and Repositories.
    - Injecting these services/repositories into ViewModels or other services without needing `BuildContext`.
    - Setup is done in `lib/locator.dart` and initialized in `main.dart`. Instances are accessed via `locator<MyService>()`.

## Folder Structure

lib/  
├── app.dart # Root MaterialApp widget, theme setup from service  
├── main.dart # App entry point, initializes locator, sets up global Providers  
├── locator.dart # GetIt service locator setup and registration  
├── core/ # Shared utilities, constants, base classes  
│ ├── constants/ # Route names, keys, shared constants  
│ ├── navigation/ # Routing setup (AppRouter)  
│ └── theme/ # Theme definitions (AppTheme)  
├── data/ # Data layer  
│ ├── models/ # Data model classes (plain Dart objects)  
│ ├── repositories/ # Abstract repository interfaces (optional structure)  
│ └── sources/ # Data source implementations (e.g., local, remote)  
│ └── local/ # Example: PreferencesService using shared_preferences  
├── features/ # Feature modules (e.g., home, settings, progress, workout)  
│ ├── app_shell/ # Widget managing Bottom Nav Bar and pages display  
│ │ ├── view/ # AppShellScreen UI  
│ │ └── viewmodel/ # AppShellViewModel (manages selected index)  
│ ├── feature_name/ # Example feature directory  
│ │ ├── view/ # Screen(s) for the feature  
│ │ └── viewmodel/ # ViewModel(s) for the feature  
│ # ... other features ...  
├── services/ # Cross-cutting application services (e.g., ThemeService)  
└── widgets/ # Common reusable widgets shared across features

## Included Features

- **Consistent UI Design System:** A comprehensive set of reusable UI components with consistent styling across light and dark modes.
- **Theme Management:** Light/Dark mode switching via `ThemeService` (extends `ChangeNotifier`), persisted using `PreferencesService`. The `
