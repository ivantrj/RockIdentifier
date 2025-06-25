// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:template_flutter_mvvm/features/library/view/library_screen.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/theme_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the ThemeService for changes
    final themeService = context.watch<ThemeService>();

    return MaterialApp(
      title: 'Flutter MVVM Template', // Your app's title
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      // Define the initial route or home widget
      // Using onGenerateRoute is more flexible for passing arguments later
      // initialRoute: AppRoutes.appShell, // Start with the shell
      home: const LibraryScreen(), // Set the new LibraryScreen as the home
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
