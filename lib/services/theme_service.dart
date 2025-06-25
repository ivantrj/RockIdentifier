// lib/services/theme_service.dart
import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  ThemeService() {
    // Always use system theme
    _themeMode = ThemeMode.system;
  }

  late final ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;
}
