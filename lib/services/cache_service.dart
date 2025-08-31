import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';
import 'package:coin_id/services/logging_service.dart';

class CacheService {
  static const String _cacheDirName = 'bug_cache';
  static const String _resultsDirName = 'ai_results';
  static const Duration _cacheExpiry = Duration(days: 7);

  late Directory _cacheDir;
  late Directory _resultsDir;
  bool _initialized = false;

  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  Future<void> init() async {
    if (_initialized) return;

    LoggingService.cacheOperation('Initializing cache service');
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory(p.join(appDir.path, _cacheDirName));
    _resultsDir = Directory(p.join(_cacheDir.path, _resultsDirName));

    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
      LoggingService.cacheOperation('Created cache directory', details: _cacheDir.path);
    }
    if (!await _resultsDir.exists()) {
      await _resultsDir.create(recursive: true);
      LoggingService.cacheOperation('Created results directory', details: _resultsDir.path);
    }

    _initialized = true;
    LoggingService.cacheOperation('Cache service initialized');
  }

  /// Generate a cache key for an image file
  String _generateCacheKey(String imagePath) {
    final file = File(imagePath);
    final lastModified = file.lastModifiedSync().millisecondsSinceEpoch;
    final fileSize = file.lengthSync();
    final key = '${fileSize}_$lastModified';
    return md5.convert(utf8.encode(key)).toString();
  }

  /// Cache AI analysis results
  Future<void> cacheAnalysisResult(String imagePath, Map<String, dynamic> result) async {
    await init();
    final cacheKey = _generateCacheKey(imagePath);
    final cacheFile = File(p.join(_resultsDir.path, '$cacheKey.json'));

    final cacheData = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'result': result,
    };

    await cacheFile.writeAsString(json.encode(cacheData));
    LoggingService.cacheOperation('Cached analysis result', details: 'key: $cacheKey');
  }

  /// Get cached AI analysis result
  Future<Map<String, dynamic>?> getCachedAnalysisResult(String imagePath) async {
    await init();
    final cacheKey = _generateCacheKey(imagePath);
    final cacheFile = File(p.join(_resultsDir.path, '$cacheKey.json'));

    if (!await cacheFile.exists()) {
      LoggingService.cacheOperation('Cache miss', details: 'key: $cacheKey');
      return null;
    }

    try {
      final cacheData = json.decode(await cacheFile.readAsString());
      final timestamp = cacheData['timestamp'] as int;
      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

      // Check if cache is expired
      if (DateTime.now().difference(cachedTime) > _cacheExpiry) {
        await cacheFile.delete();
        LoggingService.cacheOperation('Cache expired', details: 'key: $cacheKey');
        return null;
      }

      LoggingService.cacheOperation('Cache hit', details: 'key: $cacheKey');
      return Map<String, dynamic>.from(cacheData['result']);
    } catch (e) {
      // If cache file is corrupted, delete it
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
      LoggingService.error('Cache file corrupted', error: e, tag: 'CacheService');
      return null;
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await init();
    if (await _cacheDir.exists()) {
      await _cacheDir.delete(recursive: true);
      await _cacheDir.create(recursive: true);
      await _resultsDir.create(recursive: true);
      LoggingService.cacheOperation('Cache cleared');
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    await init();
    if (!await _cacheDir.exists()) return 0;

    int totalSize = 0;
    await for (final entity in _cacheDir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  /// Format cache size for display
  String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
