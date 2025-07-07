import 'package:fimber/fimber.dart';

class LoggingService {
  static const String _tag = 'BugIdentifier';

  // Debug logging
  static void debug(String message, {String? tag}) {
    Fimber.d('${tag ?? _tag}: $message');
  }

  // Info logging
  static void info(String message, {String? tag}) {
    Fimber.i('${tag ?? _tag}: $message');
  }

  // Warning logging
  static void warning(String message, {String? tag}) {
    Fimber.w('${tag ?? _tag}: $message');
  }

  // Error logging
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (error != null && stackTrace != null) {
      Fimber.e('${tag ?? _tag}: $message', ex: error, stacktrace: stackTrace);
    } else if (error != null) {
      Fimber.e('${tag ?? _tag}: $message', ex: error);
    } else {
      Fimber.e('${tag ?? _tag}: $message');
    }
  }

  // Verbose logging
  static void verbose(String message, {String? tag}) {
    Fimber.v('${tag ?? _tag}: $message');
  }

  // URL launch error logging
  static void urlLaunchError(String url, {String? tag}) {
    Fimber.w('${tag ?? _tag}: Could not launch URL: $url');
  }

  // Image loading logging
  static void imageLoad(String imagePath, bool exists, {String? tag}) {
    Fimber.d('${tag ?? _tag}: Image load - path: $imagePath, exists: $exists');
  }

  // Cache operations logging
  static void cacheOperation(String operation, {String? details, String? tag}) {
    Fimber.d('${tag ?? _tag}: Cache $operation${details != null ? ' - $details' : ''}');
  }

  // API operations logging
  static void apiOperation(String operation, {String? details, String? tag}) {
    Fimber.d('${tag ?? _tag}: API $operation${details != null ? ' - $details' : ''}');
  }

  // User action logging
  static void userAction(String action, {String? details, String? tag}) {
    Fimber.i('${tag ?? _tag}: User action - $action${details != null ? ' - $details' : ''}');
  }

  // Purchase operations logging
  static void purchaseOperation(String operation, {String? details, String? tag}) {
    Fimber.i('${tag ?? _tag}: Purchase $operation${details != null ? ' - $details' : ''}');
  }
}
