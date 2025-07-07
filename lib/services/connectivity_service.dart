import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bug_id/services/logging_service.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        LoggingService.debug('No connectivity detected', tag: 'ConnectivityService');
        return false;
      }

      // Additional check to ensure actual internet connectivity
      final result = await InternetAddress.lookup('google.com');
      final hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      LoggingService.debug('Internet connectivity check - hasInternet: $hasInternet', tag: 'ConnectivityService');
      return hasInternet;
    } on SocketException catch (e) {
      LoggingService.warning('Socket exception during connectivity check', tag: 'ConnectivityService');
      return false;
    } catch (e) {
      LoggingService.error('Error checking internet connectivity', error: e, tag: 'ConnectivityService');
      return false;
    }
  }

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;

  /// Get current connectivity status
  Future<List<ConnectivityResult>> getConnectivityStatus() async {
    return await _connectivity.checkConnectivity();
  }

  /// Check if connected to WiFi
  Future<bool> isConnectedToWifi() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  /// Check if connected to mobile data
  Future<bool> isConnectedToMobile() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile;
  }
}
