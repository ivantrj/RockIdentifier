import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:bug_id/data/models/identified_item.dart';
import 'package:bug_id/services/cache_service.dart';
import 'package:bug_id/services/connectivity_service.dart';
import 'package:bug_id/services/logging_service.dart';
import 'package:bug_id/locator.dart';

class ImageProcessingService {
  static const String _baseUrl = 'https://own-ai-backend-dev.fly.dev';

  /// Save image to app directory with a unique filename
  Future<String> saveImageToAppDir(String imagePath) async {
    try {
      LoggingService.debug('Saving image to app directory', tag: 'ImageProcessingService');
      final appDir = await getApplicationDocumentsDirectory();
      final originalFile = File(imagePath);

      // Create a more reliable filename format
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = p.extension(imagePath);
      final safeFileName = 'bug_$timestamp$extension';
      final savedPath = p.join(appDir.path, safeFileName);

      // Copy the file
      final savedImage = await originalFile.copy(savedPath);

      // Verify the file was actually saved
      if (!await savedImage.exists()) {
        throw Exception('Failed to save image file');
      }

      LoggingService.debug('Image saved successfully - path: $savedPath', tag: 'ImageProcessingService');
      return savedImage.path;
    } catch (e) {
      LoggingService.error('Failed to save image', error: e, tag: 'ImageProcessingService');
      rethrow;
    }
  }

  /// Process image and identify bug using AI
  Future<IdentifiedItem?> processImage(String imagePath) async {
    try {
      LoggingService.debug('Processing image for identification', tag: 'ImageProcessingService');

      // Save image to app directory
      final savedPath = await saveImageToAppDir(imagePath);

      // Check cache first
      final cacheService = locator<CacheService>();
      Map<String, dynamic>? aiResult = await cacheService.getCachedAnalysisResult(savedPath);

      if (aiResult == null) {
        LoggingService.debug('Cache miss, calling AI API', tag: 'ImageProcessingService');

        // Check connectivity before making API call
        final connectivityService = locator<ConnectivityService>();
        final hasInternet = await connectivityService.hasInternetConnection();

        if (!hasInternet) {
          LoggingService.warning('No internet connection detected', tag: 'ImageProcessingService');
          throw Exception('No internet connection. Please check your connection and try again.');
        }

        // Call AI API
        LoggingService.apiOperation('Calling AI identification API', tag: 'ImageProcessingService');
        aiResult = await _identifyBugWithAI(File(savedPath));

        if (aiResult != null) {
          LoggingService.apiOperation('AI identification successful', tag: 'ImageProcessingService');
          // Cache the result for future use
          await cacheService.cacheAnalysisResult(savedPath, aiResult);
        }
      } else {
        LoggingService.debug('Cache hit, using cached result', tag: 'ImageProcessingService');
      }

      if (aiResult != null) {
        LoggingService.debug('Creating identified item from AI result', tag: 'ImageProcessingService');
        final item = _createIdentifiedItem(aiResult, savedPath);
        LoggingService.debug('Identified item created successfully - id: ${item.id}, result: ${item.result}',
            tag: 'ImageProcessingService');
        return item;
      }

      LoggingService.warning('AI result is null, returning null', tag: 'ImageProcessingService');
      return null;
    } catch (e) {
      LoggingService.error('Error processing image', error: e, tag: 'ImageProcessingService');
      rethrow;
    }
  }

  /// Create IdentifiedItem from AI result
  IdentifiedItem _createIdentifiedItem(Map<String, dynamic> aiResult, String imagePath) {
    LoggingService.debug('Creating identified item from AI result', tag: 'ImageProcessingService');

    final details = <String, dynamic>{
      if (aiResult['scientificName'] != null) 'scientificName': aiResult['scientificName'],
      if (aiResult['commonName'] != null) 'commonName': aiResult['commonName'],
      if (aiResult['order'] != null) 'order': aiResult['order'],
      if (aiResult['family'] != null) 'family': aiResult['family'],
      if (aiResult['characteristics'] != null) 'characteristics': aiResult['characteristics'],
      if (aiResult['habitat'] != null) 'habitat': aiResult['habitat'],
      if (aiResult['behavior'] != null) 'behavior': aiResult['behavior'],
      if (aiResult['diet'] != null) 'diet': aiResult['diet'],
      if (aiResult['lifeCycle'] != null) 'lifeCycle': aiResult['lifeCycle'],
      if (aiResult['ecologicalRole'] != null) 'ecologicalRole': aiResult['ecologicalRole'],
      if (aiResult['estimatedPrevalence'] != null) 'estimatedPrevalence': aiResult['estimatedPrevalence'],
      if (aiResult['interestingFacts'] != null) 'interestingFacts': aiResult['interestingFacts'],
      if (aiResult['wikiLink'] != null) 'wikiLink': aiResult['wikiLink'],
      if (aiResult['dangerToHumans'] != null) 'dangerToHumans': aiResult['dangerToHumans'],
    };

    return IdentifiedItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      result: aiResult['commonName'] ?? aiResult['scientificName'] ?? 'Unknown',
      subtitle: aiResult['order'] ?? aiResult['family'] ?? '',
      confidence: _parseConfidence(aiResult['confidence']),
      details: details,
      dateTime: DateTime.now(),
    );
  }

  /// Parse confidence value from various formats
  double _parseConfidence(dynamic confidence) {
    if (confidence == null) return 0.0;
    if (confidence is num) return confidence.toDouble();
    if (confidence is String) {
      switch (confidence.toLowerCase()) {
        case 'high':
          return 0.95;
        case 'medium':
          return 0.7;
        case 'low':
          return 0.4;
        default:
          final parsed = double.tryParse(confidence);
          return parsed ?? 0.0;
      }
    }
    return 0.0;
  }

  /// Identify bug using AI API
  Future<Map<String, dynamic>?> _identifyBugWithAI(File imageFile) async {
    try {
      LoggingService.apiOperation('Starting AI identification',
          details: 'image: ${imageFile.path}', tag: 'ImageProcessingService');

      final uri = Uri.parse('$_baseUrl/identify-bug');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      // Add timeout to prevent hanging requests
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out. Please try again.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['result'] != null) {
          final result = data['result'];
          LoggingService.apiOperation('AI identification successful',
              details: 'response type: ${result.runtimeType}', tag: 'ImageProcessingService');

          // Handle different response types
          if (result is Map<String, dynamic>) {
            return result;
          } else if (result is List) {
            // If result is a list, take the first item if it's a map
            if (result.isNotEmpty && result.first is Map<String, dynamic>) {
              return Map<String, dynamic>.from(result.first);
            } else {
              throw Exception('Invalid response format: expected object but got list');
            }
          } else {
            throw Exception('Invalid response format: unexpected data type');
          }
        } else if (data['success'] == false && data['error'] != null) {
          // Check if the error indicates it's not a bug
          final error = data['error'].toString().toLowerCase();
          LoggingService.debug('AI error message: $error', tag: 'ImageProcessingService');

          if (error.contains('does not contain bug') ||
              error.contains('not bug') ||
              error.contains('no bug') ||
              error.contains('insect') ||
              error.contains('not insect')) {
            LoggingService.info('AI determined image is not a bug - throwing NOT_BUG exception',
                tag: 'ImageProcessingService');
            throw Exception('NOT_BUG');
          }
          // For other errors, throw the actual error message
          LoggingService.error('AI identification failed',
              error: Exception(data['error'].toString()), tag: 'ImageProcessingService');
          throw Exception(data['error'].toString());
        } else {
          LoggingService.error('Invalid response from AI server', tag: 'ImageProcessingService');
          throw Exception('Invalid response from server');
        }
      } else if (response.statusCode == 429) {
        LoggingService.warning('Rate limit exceeded', tag: 'ImageProcessingService');
        throw Exception('Too many requests. Please wait a moment and try again.');
      } else if (response.statusCode >= 500) {
        LoggingService.error('Server error',
            error: Exception('Status: ${response.statusCode}'), tag: 'ImageProcessingService');
        throw Exception('Server error. Please try again later.');
      } else {
        LoggingService.error('Unexpected response status',
            error: Exception('Status: ${response.statusCode}'), tag: 'ImageProcessingService');
        throw Exception('Failed to identify bug. Please try again.');
      }
    } on FormatException {
      LoggingService.error('Format exception in AI response', tag: 'ImageProcessingService');
      throw Exception('Invalid response from server. Please try again.');
    } on SocketException {
      LoggingService.error('Socket exception - no internet connection', tag: 'ImageProcessingService');
      throw Exception('No internet connection. Please check your connection and try again.');
    } on TimeoutException catch (e) {
      LoggingService.error('Request timeout', error: e, tag: 'ImageProcessingService');
      throw Exception(e.message);
    } catch (e) {
      // Check if this is a NOT_BUG exception and rethrow it directly
      if (e is Exception && e.toString().contains('NOT_BUG')) {
        LoggingService.debug('Re-throwing NOT_BUG exception', tag: 'ImageProcessingService');
        rethrow;
      }

      LoggingService.error('Unexpected error in AI identification', error: e, tag: 'ImageProcessingService');
      // Provide more specific error messages based on the error type
      if (e.toString().contains('List<Map')) {
        throw Exception('Server returned unexpected data format. Please try again.');
      } else if (e.toString().contains('type')) {
        throw Exception('Invalid data format received. Please try again.');
      } else {
        throw Exception('An unexpected error occurred. Please try again.');
      }
    }
  }
}
