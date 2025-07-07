// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bug_id/services/theme_service.dart';
import 'app.dart';
import 'locator.dart'; // Import the locator setup
import 'package:fimber/fimber.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> main() async {
  Fimber.plantTree(DebugTree());
  WidgetsFlutterBinding.ensureInitialized();

  // Setup GetIt locator
  await setupLocator(); // Call the setup function

  // Initialize RevenueCat
  await RevenueCatService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<ThemeService>()),
      ],
      child: const App(),
    ),
  );
}

// RevenueCatService singleton
class RevenueCatService {
  static bool isSubscribed = false;

  static Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration('appl_uCCWdgJkaJVjrfkqFidqKTTnqwQ'));
    try {
      final purchaserInfo = await Purchases.getCustomerInfo();
      isSubscribed = purchaserInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      isSubscribed = false;
    }
  }
}
