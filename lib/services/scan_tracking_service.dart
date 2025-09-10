import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_id/services/logging_service.dart';

class ScanTrackingService {
  static const String _scanCountKey = 'total_scan_count';
  static const int _freeScansLimit = 1;

  /// Get the total number of scans performed by the user
  static Future<int> getTotalScanCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_scanCountKey) ?? 0;
    } catch (e) {
      LoggingService.error('Failed to get scan count', error: e, tag: 'ScanTrackingService');
      return 0;
    }
  }

  /// Increment the total scan count
  static Future<void> incrementScanCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = await getTotalScanCount();
      await prefs.setInt(_scanCountKey, currentCount + 1);
      LoggingService.debug('Scan count incremented to ${currentCount + 1}', tag: 'ScanTrackingService');
    } catch (e) {
      LoggingService.error('Failed to increment scan count', error: e, tag: 'ScanTrackingService');
    }
  }

  /// Check if the user has exceeded the free scan limit
  static Future<bool> hasExceededFreeLimit() async {
    final totalScans = await getTotalScanCount();
    return totalScans >= _freeScansLimit;
  }

  /// Get the number of remaining free scans
  static Future<int> getRemainingFreeScans() async {
    final totalScans = await getTotalScanCount();
    return (_freeScansLimit - totalScans).clamp(0, _freeScansLimit);
  }

  /// Reset scan count (for testing or admin purposes)
  static Future<void> resetScanCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scanCountKey);
      LoggingService.debug('Scan count reset', tag: 'ScanTrackingService');
    } catch (e) {
      LoggingService.error('Failed to reset scan count', error: e, tag: 'ScanTrackingService');
    }
  }
}
