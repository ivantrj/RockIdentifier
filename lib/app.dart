// lib/app.dart
library app;

import 'package:PlantMate/features/paywall/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:PlantMate/features/library/view/library_screen.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/theme_service.dart';
import 'main.dart' as main;
import 'package:shared_preferences/shared_preferences.dart';
import 'features/onboarding/onboarding_screen.dart';

bool paywallOpen = false;
final GlobalKey<NavigatorState> rootNavKey = GlobalKey<NavigatorState>();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _showOnboarding = false;
  bool _checkedPrefs = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_complete') ?? false;
    setState(() {
      _showOnboarding = !seen;
      _checkedPrefs = true;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    if (!_checkedPrefs) {
      return const MaterialApp(home: Scaffold(body: SizedBox()));
    }
    return MaterialApp(
      navigatorKey: rootNavKey,
      title: 'PlantMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      home: _showOnboarding
          ? OnboardingScreen(
              onFinish: () async {
                await _completeOnboarding();
                setState(() {});
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!main.RevenueCatService.isSubscribed && !paywallOpen) {
                    paywallOpen = true;
                    await showModalBottomSheet(
                      context: rootNavKey.currentContext!,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => FractionallySizedBox(
                        heightFactor: 0.95,
                        child: PaywallScreen(),
                      ),
                    );
                    paywallOpen = false;
                  }
                });
              },
            )
          : const LibraryScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
