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

  static bool paywallOpen = false;

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
      home: Builder(
        builder: (context) {
          // Show paywall if not subscribed
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!main.RevenueCatService.isSubscribed && !paywallOpen) {
              paywallOpen = true;
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) => FractionallySizedBox(
                  heightFactor: 0.95, // % of the screen height, adjust as needed
                  child: PaywallScreen(),
                ),
              );
              paywallOpen = false;
            }
          });
          return const LibraryScreen();
        },
      ),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
