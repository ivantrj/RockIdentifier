// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bug_id/services/theme_service.dart';
import 'app.dart';
import 'locator.dart'; // Import the locator setup
import 'package:fimber/fimber.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:bug_id/services/logging_service.dart';

Future<void> main() async {
  // Initialize logging
  Fimber.plantTree(DebugTree());
  LoggingService.info('App starting up');

  WidgetsFlutterBinding.ensureInitialized();

  // Setup GetIt locator
  await setupLocator(); // Call the setup function

  // Initialize RevenueCat
  await RevenueCatService.init();
  LoggingService.info('App initialization completed');

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
    LoggingService.purchaseOperation('Initializing RevenueCat');
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration('appl_uCCWdgJkaJVjrfkqFidqKTTnqwQ'));
    try {
      final purchaserInfo = await Purchases.getCustomerInfo();
      isSubscribed = purchaserInfo.entitlements.active.isNotEmpty;
      LoggingService.purchaseOperation('Subscription status checked', details: 'isSubscribed: $isSubscribed');
    } catch (e) {
      isSubscribed = false;
      LoggingService.error('Failed to get customer info', error: e);
    }
  }
}
