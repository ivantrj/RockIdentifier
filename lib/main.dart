// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_id/services/theme_service.dart';
import 'app.dart';
import 'locator.dart'; // Import the locator setup
import 'package:fimber/fimber.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rock_id/services/logging_service.dart';

Future<void> main() async {
  // Initialize logging
  Fimber.plantTree(DebugTree());
  LoggingService.info('Rock Identifier App starting up');

  WidgetsFlutterBinding.ensureInitialized();

  // Setup GetIt locator
  await setupLocator(); // Call the setup function

  // Initialize RevenueCat
  await RevenueCatService.init();
  LoggingService.info('Rock Identifier App initialization completed');

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

    try {
      // Set debug logging
      await Purchases.setLogLevel(LogLevel.debug);
      LoggingService.debug('RevenueCat log level set to debug', tag: 'RevenueCatService');

      // Configure RevenueCat
      await Purchases.configure(PurchasesConfiguration('appl_NLKoYelGSugaNoOdDIZKSUaHRvC'));
      LoggingService.debug('RevenueCat configured successfully', tag: 'RevenueCatService');

      // Test connection by getting customer info
      final purchaserInfo = await Purchases.getCustomerInfo();
      isSubscribed = purchaserInfo.entitlements.active.isNotEmpty;
      LoggingService.purchaseOperation('Subscription status checked', details: 'isSubscribed: $isSubscribed');
      LoggingService.debug('Customer info retrieved successfully', tag: 'RevenueCatService');

      // Test offerings fetch
      try {
        final offerings = await Purchases.getOfferings();
        LoggingService.debug('Offerings test successful: ${offerings.current?.identifier ?? 'No current offering'}',
            tag: 'RevenueCatService');
        if (offerings.current != null) {
          LoggingService.debug('Available packages: ${offerings.current!.availablePackages.length}',
              tag: 'RevenueCatService');
        }
      } catch (e) {
        LoggingService.warning('Offerings test failed: ${e.toString()}', tag: 'RevenueCatService');
      }
    } catch (e) {
      isSubscribed = false;
      LoggingService.error('RevenueCat initialization failed', error: e, tag: 'RevenueCatService');
      LoggingService.debug('Error details: ${e.toString()}', tag: 'RevenueCatService');
    }
  }
}
