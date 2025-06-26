// lib/app.dart
import 'package:PlantMate/features/paywall/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:PlantMate/features/library/view/library_screen.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/theme_service.dart';
import 'main.dart' as main;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the ThemeService for changes
    final themeService = context.watch<ThemeService>();

    return MaterialApp(
      title: 'PlantMate', // Your app's title
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      // Define the initial route or home widget
      // Using onGenerateRoute is more flexible for passing arguments later
      // initialRoute: AppRoutes.appShell, // Start with the shell
      home: Builder(
        builder: (context) {
          // Show paywall if not subscribed
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!main.RevenueCatService.isSubscribed) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PaywallScreen(),
                ),
              );
            }
          });
          return const LibraryScreen();
        },
      ),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
