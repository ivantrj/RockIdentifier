# Logging System Documentation

This app uses Fimber for comprehensive logging throughout the application. The logging system is centralized through the `LoggingService` class.

## Setup

Fimber is already configured in `main.dart`:

```dart
import 'package:fimber/fimber.dart';
import 'package:coin_id/services/logging_service.dart';

Future<void> main() async {
  // Initialize logging
  Fimber.plantTree(DebugTree());
  LoggingService.info('App starting up');
  // ... rest of initialization
}
```

## Usage

### Basic Logging Methods

```dart
import 'package:coin_id/services/logging_service.dart';

// Debug logging
LoggingService.debug('Debug message');

// Info logging
LoggingService.info('Info message');

// Warning logging
LoggingService.warning('Warning message');

// Error logging
LoggingService.error('Error message', error: exception);

// Verbose logging
LoggingService.verbose('Verbose message');
```

### Tagged Logging

You can add tags to organize logs by component:

```dart
LoggingService.debug('Message', tag: 'ComponentName');
LoggingService.error('Error occurred', error: e, tag: 'ServiceName');
```

### Specialized Logging Methods

The `LoggingService` provides specialized methods for common scenarios:

#### URL Launch Errors

```dart
LoggingService.urlLaunchError('https://example.com', tag: 'ScreenName');
```

#### Image Loading

```dart
LoggingService.imageLoad('/path/to/image.jpg', true, tag: 'DetailScreen');
```

#### Cache Operations

```dart
LoggingService.cacheOperation('Cache hit', details: 'key: abc123');
LoggingService.cacheOperation('Cache miss', details: 'key: def456');
LoggingService.cacheOperation('Cache cleared');
```

#### API Operations

```dart
LoggingService.apiOperation('API call started', details: 'endpoint: /chat');
LoggingService.apiOperation('API call successful', details: 'response time: 1.2s');
```

#### User Actions

```dart
LoggingService.userAction('Button pressed', details: 'button: delete', tag: 'DetailScreen');
LoggingService.userAction('Navigation', details: 'from: home, to: detail');
```

#### Purchase Operations

```dart
LoggingService.purchaseOperation('Purchase initiated', details: 'package: premium');
LoggingService.purchaseOperation('Purchase completed', details: 'transaction: abc123');
```

## Best Practices

1. **Use appropriate log levels:**

   - `debug`: For detailed debugging information
   - `info`: For general information about app flow
   - `warning`: For potential issues that don't break functionality
   - `error`: For actual errors that need attention

2. **Include relevant context:**

   ```dart
   // Good
   LoggingService.error('Failed to load image', error: e, tag: 'ImageService');

   // Better
   LoggingService.error('Failed to load image', error: e, tag: 'ImageService');
   LoggingService.debug('Image path: $imagePath, size: ${imageSize}bytes');
   ```

3. **Use tags consistently:**

   - Use the same tag for related operations
   - Use descriptive tag names (e.g., 'DetailScreen', 'ChatService', 'CacheService')

4. **Don't log sensitive information:**
   - Never log passwords, API keys, or personal data
   - Be careful with user input that might contain sensitive information

## Migration from print/debugPrint

Replace print statements with appropriate logging:

```dart
// Before
print('Could not launch $urlString');
debugPrint('Image loaded: $imagePath');

// After
LoggingService.urlLaunchError(urlString, tag: 'ScreenName');
LoggingService.imageLoad(imagePath, true, tag: 'ScreenName');
```

## Viewing Logs

In debug mode, logs will appear in the console. For production builds, you can configure different logging trees or disable logging entirely by modifying the Fimber configuration in `main.dart`.

## Performance Considerations

- Logging is disabled in release builds by default
- Use appropriate log levels to avoid performance impact
- Don't log in tight loops or performance-critical sections
