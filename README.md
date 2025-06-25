# Flutter MVVM Template with Provider & GetIt

## Overview

This template provides a solid starting point for new Flutter applications, aiming to accelerate development by providing a structured architecture and common boilerplate features. It utilizes the Model-View-ViewModel (MVVM) pattern combined with Flutter's built-in state management (`ChangeNotifier`, `ValueNotifier`), `provider` for UI binding, and `get_it` for service location and dependency injection.

**Core Goals:**

* **Rapid Development:** Skip repetitive setup for architecture, navigation, theming, etc.
* **Scalability:** Maintainable structure using MVVM and dependency injection.
* **Clear Separation of Concerns:** Keep UI, state/business logic, and data layers distinct.
* **Leverage Standard Packages:** Use well-regarded packages like `provider` and `get_it`.

## Architecture: MVVM

The template follows the MVVM pattern:

* **Model:** Represents your application's data (e.g., User, Workout, Setting). These are typically plain Dart objects located in `lib/data/models/`. They may include `toJson`/`fromJson` methods for serialization.
* **View:** The Flutter Widgets (Screens/UI). Responsible for displaying data from the ViewModel and forwarding user interactions to it. Located within specific feature directories (e.g., `lib/features/home/view/`). Views should be as "dumb" as possible.
* **ViewModel:** Acts as the bridge between the View and the Model/Services.
    * Extends `ChangeNotifier` to notify the View of state changes.
    * Holds UI state (e.g., loading status, error messages, data lists).
    * Contains presentation logic and handles user input.
    * Interacts with Services and Repositories (fetched via `GetIt`) to get/manipulate data.
    * Located within specific feature directories (e.g., `lib/features/home/viewmodel/`).

## State Management

This template uses a combination approach:

1.  **`ChangeNotifier` / `ValueNotifier`:** Used within ViewModels to hold and expose state that the UI needs to react to. `ChangeNotifier` is primary for ViewModels; `ValueNotifier` can be used for simpler, individual reactive values.
2.  **`provider` Package:** The standard way to connect `ChangeNotifier` ViewModels (and other services/values) to the Flutter widget tree.
    * `ChangeNotifierProvider`: Used to create/provide ViewModel instances to specific subtrees (often at the screen level).
    * `Consumer` / `context.watch<T>()`: Used within Views to listen to ViewModel changes and rebuild the UI accordingly.
    * `context.read<T>()`: Used to access a ViewModel/Service for calling methods without listening to changes.
    * `MultiProvider`: Used in `main.dart` to provide app-wide services (like `ThemeService`).
3.  **`get_it` Package (Service Locator):** Used for dependency injection *outside* the widget tree, primarily for:
    * Registering and retrieving singleton or factory instances of Services (e.g., `ApiService`, `PreferencesService`, `WorkoutPlanService`) and Repositories.
    * Injecting these services/repositories into ViewModels or other services without needing `BuildContext`.
    * Setup is done in `lib/locator.dart` and initialized in `main.dart`. Instances are accessed via `locator<MyService>()`.

## Folder Structure

lib/  
├── app.dart                # Root MaterialApp widget, theme setup from service  
├── main.dart              # App entry point, initializes locator, sets up global Providers  
├── locator.dart           # GetIt service locator setup and registration  
├── core/                  # Shared utilities, constants, base classes  
│   ├── constants/         # Route names, keys, shared constants  
│   ├── navigation/        # Routing setup (AppRouter)  
│   └── theme/             # Theme definitions (AppTheme)  
├── data/                  # Data layer  
│   ├── models/            # Data model classes (plain Dart objects)  
│   ├── repositories/      # Abstract repository interfaces (optional structure)  
│   └── sources/           # Data source implementations (e.g., local, remote)  
│       └── local/         # Example: PreferencesService using shared_preferences  
├── features/              # Feature modules (e.g., home, settings, progress, workout)  
│   ├── app_shell/         # Widget managing Bottom Nav Bar and pages display  
│   │   ├── view/          # AppShellScreen UI  
│   │   └── viewmodel/     # AppShellViewModel (manages selected index)  
│   ├── feature_name/      # Example feature directory  
│   │   ├── view/          # Screen(s) for the feature  
│   │   └── viewmodel/     # ViewModel(s) for the feature  
│   # ... other features ...  
├── services/              # Cross-cutting application services (e.g., ThemeService)  
└── widgets/               # Common reusable widgets shared across features  

## Included Features

* **Consistent UI Design System:** A comprehensive set of reusable UI components with consistent styling across light and dark modes.
* **Theme Management:** Light/Dark mode switching via `ThemeService` (extends `ChangeNotifier`), persisted using `PreferencesService`. The `App` widget listens to this service.
* **Dependency Injection:** Pre-configured `GetIt` (`locator.dart`) for services and `Provider` setup in `main.dart`.
* **Navigation:**
    * Bottom Navigation Bar structure using `AppShellScreen` and `IndexedStack`.
    * Basic named routing setup (`AppRouter`, `AppRoutes`) although direct `MaterialPageRoute` navigation is also used where appropriate (e.g., passing complex arguments).
* **Data Persistence Example:** `PreferencesService` wrapping `shared_preferences` for basic key-value storage (theme, onboarding status, etc.). Easily extendable.

## UI Design System

The template features a modern, cohesive UI design system with the following characteristics:

* **Consistent Styling:** All components maintain consistent padding, border radius, and elevation across the app.
* **Dark Mode Support:** Every component is designed to adapt beautifully to both light and dark themes.
* **Reusable Components:** UI elements are extracted into reusable widgets to reduce code duplication and ensure consistency.
* **Centralized Theme Constants:** Colors, spacing, and styling values are defined in `AppTheme` for easy customization.

### Key UI Components

* **Cards:** Various card styles (AppCard, CategoryCard, ListItemCard) for different content types.
* **Buttons:** Primary and secondary button styles with consistent appearance.
* **Section Headers:** Standardized headers for content sections with optional action buttons.
* **List Items:** Consistent styling for list entries with icons and optional details.

## Using the Design System

This template includes custom UI components and styles defined in `lib/core/theme/app_theme.dart`.

**Core UI Components:**

* **`AppCard`**: Versatile card component with consistent styling. (`lib/core/widgets/app_card.dart`)
    ```dart
    AppCard(
      useBorder: true,
      child: YourContent(),
    )
    ```

* **`CategoryCard`**: Compact card for category display with icon. (`lib/core/widgets/category_card.dart`)
    ```dart
    CategoryCard(
      title: 'Category',
      icon: Icons.star,
      backgroundColor: AppTheme.primaryColor,
      onTap: () {},
    )
    ```

* **`ListItemCard`**: Card optimized for list items with icon and optional subtitle. (`lib/core/widgets/list_item_card.dart`)
    ```dart
    ListItemCard(
      title: 'List Item',
      subtitle: 'Description',
      icon: Icons.note,
      iconBackgroundColor: AppTheme.secondaryColor,
      onTap: () {},
    )
    ```

* **`SectionHeader`**: Consistent section header with optional action button. (`lib/core/widgets/section_header.dart`)
    ```dart
    SectionHeader(
      title: 'Section Title',
      actionText: 'See All',
      onActionPressed: () {},
    )
    ```

* **`PrimaryButton`**: Solid background button. (`lib/core/widgets/primary_button.dart`)
    ```dart
    PrimaryButton(onPressed: (){}, text: 'Submit')
    ```

* **`SecondaryButton`**: Transparent background, primary text color button. (`lib/core/widgets/secondary_button.dart`)
    ```dart
    SecondaryButton(onPressed: (){}, text: 'Cancel')
    ```

* **`CustomBackButton`**: Styled back button for AppBars. (`lib/widgets/navigation/custom_back_button.dart`)
    ```dart
    AppBar(leading: const CustomBackButton(), automaticallyImplyLeading: false, ...)
    ```

**Themed Standard Widgets:**

Standard Flutter widgets like `Card`, `NavigationBar`, and `FilterChip`/`ChoiceChip` are styled via their respective themes (`CardTheme`, `NavigationBarTheme`, `ChipTheme`) within `AppTheme`. Use them directly as you normally would.

**Modal Bottom Sheets:**

Uses the `showModalBottomSheet` function via a helper function for consistent styling.

```dart
showAppModalSheet(
  context: context,
  title: 'Title',
  content: content,
  buttonText: 'Button Text',
  onButtonPressed: () {},
);
```

**Customization:**

Adjust colors, fonts, radii, padding constants, and theme settings primarily in `lib/core/theme/app_theme.dart`.

## Getting Started

1.  **Clone/Copy:** Clone this repository or copy the files into your new project.
2.  **Get Dependencies:** Run `flutter pub get` in your terminal.
3.  **Customize:**
    * Change the app name in `pubspec.yaml`, `App` widget, etc.
    * Modify themes in `lib/core/theme/app_theme.dart`.
    * Adjust `BottomNavigationBar` items and `_screens` in `lib/features/app_shell/view/app_shell_screen.dart`.
4.  **Build:** Start creating your features inside the `lib/features/` directory, following the MVVM pattern:
    * Define Models (`data/models/`).
    * Create Services/Repositories if needed, register in `locator.dart`.
    * Create ViewModel (`features/my_feature/viewmodel/`), inject dependencies via `locator`.
    * Create View (`features/my_feature/view/`), use `ChangeNotifierProvider` (or access global providers) and `Consumer`/`context.watch` to interact with the ViewModel.
    * Add navigation routes if needed.

## Core Dependencies

* `flutter`
* `provider`: For connecting ViewModels/state to the UI.
* `get_it`: For service location / dependency injection.
* `shared_preferences`: For basic local data persistence example.
* `intl`: (Used in example app) Useful for date/number formatting.
