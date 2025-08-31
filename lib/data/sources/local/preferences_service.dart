// lib/data/sources/local/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // Import material for ThemeMode
import 'package:coin_id/services/logging_service.dart';

class PreferencesService {
  late SharedPreferences _prefs;

  static const String _themeModeKey = 'themeMode';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme Mode Persistence
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name); // Store the enum name as string
  }

  ThemeMode getThemeMode() {
    final String? themeString = _prefs.getString(_themeModeKey);
    if (themeString == null) {
      return ThemeMode.system; // Default to system theme
    }
    try {
      // Find the ThemeMode enum value matching the stored string name
      return ThemeMode.values.firstWhere((e) => e.name == themeString);
    } catch (e) {
      // Handle error or fallback if stored value is invalid
      LoggingService.error('Error reading theme mode preference', error: e);
      return ThemeMode.system;
    }
  }

  // --- Add other preferences methods here (e.g., language, user token) ---
}
