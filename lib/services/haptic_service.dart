import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  static const String _prefsKey = 'haptic_feedback_enabled';
  bool _enabled = true;

  bool get enabled => _enabled;

  Future<void> loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefsKey) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }

  Future<void> vibrate() async {
    if (_enabled) {
      await HapticFeedback.lightImpact();
    }
  }

  static HapticService get instance => _instance;
}
