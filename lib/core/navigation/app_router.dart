// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:PlantMate/features/library/view/library_screen.dart';
import 'package:PlantMate/features/settings/view/settings_screen.dart';
import '../constants/app_constants.dart';
// Import other screens as needed

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.appShell:
        // The AppShellScreen is usually handled by the MaterialApp's 'home' property,
        // but you might navigate to it explicitly in some cases.
        return MaterialPageRoute(builder: (_) => const LibraryScreen());

      case AppRoutes.settings:
        // Example of navigating to the settings screen directly (perhaps from somewhere else)
        // Normally, SettingsScreen will be displayed *within* the AppShellScreen.
        // This route might be useful if you want to push it modally or without the bottom bar.
        return MaterialPageRoute(builder: (_) => const SettingsScreen()); // Placeholder

      // Add cases for other routes here
      // case AppRoutes.profile:
      //   return MaterialPageRoute(builder: (_) => const ProfileScreen());

      default:
        // If the route name is unknown, show an error screen or a default screen
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
