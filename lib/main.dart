// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:template_flutter_mvvm/services/theme_service.dart';
import 'app.dart';
import 'locator.dart'; // Import the locator setup
import 'package:fimber/fimber.dart';

Future<void> main() async {
  Fimber.plantTree(DebugTree());
  WidgetsFlutterBinding.ensureInitialized();

  // Setup GetIt locator
  await setupLocator(); // Call the setup function

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<ThemeService>()),
      ],
      child: const App(),
    ),
  );
}
