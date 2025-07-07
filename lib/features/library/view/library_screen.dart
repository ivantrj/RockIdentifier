import 'package:bug_id/features/paywall/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:bug_id/features/library/view/detail_screen.dart';
import '../viewmodel/library_viewmodel.dart';
import 'package:bug_id/data/models/identified_item.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../../../main.dart' as main;
import 'package:flutter/scheduler.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:bug_id/app.dart' as app;
import 'package:bug_id/core/theme/app_theme.dart';
import 'package:bug_id/services/cache_service.dart';
import 'package:bug_id/services/connectivity_service.dart';
import 'package:bug_id/locator.dart';
import 'package:bug_id/services/logging_service.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LibraryViewModel(),
      child: const _LibraryScreenBody(),
    );
  }
}

class _LibraryScreenBody extends StatefulWidget {
  const _LibraryScreenBody();

  @override
  State<_LibraryScreenBody> createState() => _LibraryScreenBodyState();
}

class _LibraryScreenBodyState extends State<_LibraryScreenBody> {
  bool _fabMenuOpen = false;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  // ValueNotifier for subscription state
  final ValueNotifier<bool> isSubscribedNotifier = ValueNotifier(main.RevenueCatService.isSubscribed);

  // Listen for subscription changes from RevenueCat
  void listenForSubscriptionChanges() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      final isSubscribed = customerInfo.entitlements.active.isNotEmpty;
      isSubscribedNotifier.value = isSubscribed;
      main.RevenueCatService.isSubscribed = isSubscribed; // keep singleton in sync
    });
  }

  @override
  void initState() {
    super.initState();
    listenForSubscriptionChanges();

    // Verify saved images after a short delay to allow the library to load
    Future.delayed(const Duration(seconds: 2), () {
      _verifySavedImages();
      _fixIncorrectlyMigratedItems();
    });
  }

  void _openFabMenu() => setState(() => _fabMenuOpen = true);
  void _closeFabMenu() => setState(() => _fabMenuOpen = false);

  Future<String> _saveImageToAppDir(String imagePath) async {
    try {
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

      return savedImage.path;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    LoggingService.userAction('Image picker opened', details: 'source: ${source.name}', tag: 'LibraryScreen');

    final items = context.read<LibraryViewModel>().items;
    final isSubscribed = main.RevenueCatService.isSubscribed;
    if (!isSubscribed && items.isNotEmpty) {
      LoggingService.userAction('Paywall shown', details: 'reason: subscription required', tag: 'LibraryScreen');
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.95, // % of the screen height, adjust as needed
          child: PaywallScreen(),
        ),
      );
      return;
    }
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      LoggingService.userAction('Image selected', details: 'path: ${pickedFile.path}', tag: 'LibraryScreen');
      setState(() {
        _fabMenuOpen = false;
        _isProcessing = true;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _FunLoadingDialog(),
      );
      try {
        LoggingService.debug('Processing selected image', tag: 'LibraryScreen');
        final savedPath = await _saveImageToAppDir(pickedFile.path);
        LoggingService.debug('Image saved to app directory - path: $savedPath', tag: 'LibraryScreen');

        // Check cache first
        final cacheService = locator<CacheService>();
        Map<String, dynamic>? aiResult = await cacheService.getCachedAnalysisResult(savedPath);

        if (aiResult == null) {
          LoggingService.debug('Cache miss, calling AI API', tag: 'LibraryScreen');
          // Check connectivity before making API call
          final connectivityService = locator<ConnectivityService>();
          final hasInternet = await connectivityService.hasInternetConnection();

          if (!hasInternet) {
            LoggingService.warning('No internet connection detected', tag: 'LibraryScreen');
            throw Exception('No internet connection. Please check your connection and try again.');
          }

          // If not in cache, call AI API
          LoggingService.apiOperation('Calling AI identification API', tag: 'LibraryScreen');
          aiResult = await _identifyBugWithAI(File(savedPath));
          if (aiResult != null) {
            LoggingService.apiOperation('AI identification successful', tag: 'LibraryScreen');
            // Cache the result for future use
            await cacheService.cacheAnalysisResult(savedPath, aiResult);
          }
        } else {
          LoggingService.debug('Cache hit, using cached result', tag: 'LibraryScreen');
        }

        if (aiResult != null) {
          LoggingService.debug('Creating identified item from AI result', tag: 'LibraryScreen');
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
          final item = IdentifiedItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            imagePath: savedPath,
            result: aiResult['commonName'] ?? aiResult['scientificName'] ?? 'Unknown',
            subtitle: aiResult['order'] ?? aiResult['family'] ?? '',
            confidence: _parseConfidence(aiResult['confidence']),
            details: details,
            dateTime: DateTime.now(),
          );
          if (mounted) {
            LoggingService.userAction('Item added to library', details: 'result: ${item.result}', tag: 'LibraryScreen');
            context.read<LibraryViewModel>().addItem(item);
            Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
            setState(() {
              _isProcessing = false;
            });
          }
        } else {
          LoggingService.warning('AI did not return a valid result', tag: 'LibraryScreen');
          _showError('AI did not return a valid result.');
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              _isProcessing = false;
            });
          }
        }
      } catch (e) {
        if (e.toString().contains('NOT_BUG')) {
          LoggingService.info('Image identified as not a bug', tag: 'LibraryScreen');
          // Show the not bug dialog
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
            setState(() {
              _isProcessing = false;
            });
            showDialog(
              context: context,
              builder: (context) => const _NotBugDialog(),
            );
          }
        } else {
          LoggingService.error('Error processing image', error: e, tag: 'LibraryScreen');
          String errorMessage = 'Failed to identify image';
          if (e is Exception) {
            errorMessage = e.toString().replaceAll('Exception: ', '');
          } else {
            errorMessage = 'An unexpected error occurred. Please try again.';
          }
          _showError(errorMessage);
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              _isProcessing = false;
            });
          }
        }
      }
    }
  }

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

  String _extractPriceRange(String priceText) {
    // Extract just the price range from text like "$50-$100 depending on the specific model"
    final priceRegex = RegExp(r'\$[\d,]+(?:-\$[\d,]+)?');
    final match = priceRegex.firstMatch(priceText);
    if (match != null) {
      return match.group(0)!;
    }

    // Try to find USD pattern like "USD 500-1000" and convert to "$500-$1000"
    final usdRegex = RegExp(r'USD\s+([\d,]+(?:-[\d,]+)?)', caseSensitive: false);
    final usdMatch = usdRegex.firstMatch(priceText);
    if (usdMatch != null) {
      final numbers = usdMatch.group(1)!;
      return '\$$numbers';
    }

    // Try to find any price-like pattern
    final anyPriceRegex = RegExp(r'[\d,]+(?:-[\d,]+)?\s*(?:USD|dollars?|bucks?)', caseSensitive: false);
    final anyMatch = anyPriceRegex.firstMatch(priceText);
    if (anyMatch != null) {
      return anyMatch.group(0)!;
    }

    // If no price range found, return first 20 characters
    return priceText.length > 20 ? '${priceText.substring(0, 20)}...' : priceText;
  }

  /// Verify that all saved images still exist and log any missing ones
  Future<void> _verifySavedImages() async {
    try {
      final items = context.read<LibraryViewModel>().items;
      final appDir = await getApplicationDocumentsDirectory();

      for (final item in items) {
        if (item.imagePath.isNotEmpty) {
          final file = File(item.imagePath);
          final exists = await file.exists();

          if (!exists) {
            // Check if the file might be in the documents directory with a different name
            final fileName = p.basename(item.imagePath);
            final possibleFiles = appDir
                .listSync()
                .where((entity) => entity is File && p.basename(entity.path).contains('bug_'))
                .toList();

            for (final file in possibleFiles) {}

            // Try to migrate old image format
            await _migrateOldImage(item);
          } else {}
        }
      }
    } catch (e) {}
  }

  /// Migrate old image format to new format
  Future<void> _migrateOldImage(IdentifiedItem item) async {
    try {
      // Check if the original image still exists in the documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final oldFileName = p.basename(item.imagePath);

      // Look for any file that might be the original image
      final possibleFiles = appDir
          .listSync()
          .where((entity) =>
              entity is File &&
              (p.basename(entity.path).contains('image_picker') || p.basename(entity.path).contains('bug_')))
          .toList();

      // Also check if the original file path still exists (might be in temp directory)
      File? sourceFile;
      if (File(item.imagePath).existsSync()) {
        sourceFile = File(item.imagePath);
      } else {
        // Look for the exact bug file that should match this item
        final expectedFileName = p.basename(item.imagePath);
        final exactMatch =
            possibleFiles.where((entity) => entity is File && p.basename(entity.path) == expectedFileName).toList();

        if (exactMatch.isNotEmpty) {
          sourceFile = exactMatch.first as File;
        } else if (possibleFiles.isNotEmpty) {
          // If no exact match, look for bug files first (prefer new format)
          final bugFiles =
              possibleFiles.where((entity) => entity is File && p.basename(entity.path).contains('bug_')).toList();

          if (bugFiles.isNotEmpty) {
            sourceFile = bugFiles.first as File;
          } else {
            // Fall back to any available file
            sourceFile = possibleFiles.first as File;
          }
        } else {
          // Check temp directory as last resort
          try {
            final tempDir = await getTemporaryDirectory();
            final tempFiles = tempDir
                .listSync()
                .where((entity) => entity is File && p.basename(entity.path).contains('image_picker'))
                .toList();

            if (tempFiles.isNotEmpty) {
              sourceFile = tempFiles.first as File;
            }
          } catch (e) {}
        }
      }

      if (sourceFile != null && await sourceFile.exists()) {
        // Save with new format
        final newPath = await _saveImageToAppDir(sourceFile.path);

        // Update the item with the new path
        final updatedItem = item.copyWith(imagePath: newPath);
        await context.read<LibraryViewModel>().updateItem(updatedItem);

        // Delete the old file if it's different from the new one
        if (sourceFile.path != newPath) {
          try {
            await sourceFile.delete();
          } catch (e) {}
        }
      } else {}
    } catch (e) {}
  }

  /// Fix items that were incorrectly migrated with the wrong image
  Future<void> _fixIncorrectlyMigratedItems() async {
    try {
      final items = context.read<LibraryViewModel>().items;
      final appDir = await getApplicationDocumentsDirectory();

      for (final item in items) {
        if (item.imagePath.isNotEmpty && item.imagePath.contains('bug_')) {
          final currentFile = File(item.imagePath);
          if (await currentFile.exists()) {
            // Check if this is the correct image by looking for the original expected filename
            final expectedFileName = p.basename(item.imagePath);

            // Look for other bug files that might be the correct one
            final allBugFiles = appDir
                .listSync()
                .where((entity) => entity is File && p.basename(entity.path).contains('bug_'))
                .toList();

            if (allBugFiles.length > 1) {
              // Check if there's a bug file that matches the original timestamp
              final itemTimestamp = item.id; // The item ID is the timestamp
              final correctFile = allBugFiles
                  .where((entity) => entity is File && p.basename(entity.path).contains('bug_$itemTimestamp'))
                  .toList();

              if (correctFile.isNotEmpty && p.basename(correctFile.first.path) != expectedFileName) {
                final correctPath = correctFile.first.path;

                final updatedItem = item.copyWith(imagePath: correctPath);
                await context.read<LibraryViewModel>().updateItem(updatedItem);

                // Delete the incorrect file
                try {
                  await currentFile.delete();
                } catch (e) {}
              }
            }
          }
        }
      }
    } catch (e) {}
  }

  Future<Map<String, dynamic>?> _identifyBugWithAI(File imageFile) async {
    try {
      LoggingService.apiOperation('Starting AI identification',
          details: 'image: ${imageFile.path}', tag: 'LibraryScreen');
      final uri = Uri.parse('https://own-ai-backend-dev.fly.dev/identify-bug');
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
              details: 'response type: ${result.runtimeType}', tag: 'LibraryScreen');

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
          if (error.contains('does not contain bug') ||
              error.contains('not bug') ||
              error.contains('no bug') ||
              error.contains('insect') ||
              error.contains('not insect')) {
            LoggingService.info('AI determined image is not a bug', tag: 'LibraryScreen');
            throw Exception('NOT_BUG');
          }
          // For other errors, throw the actual error message
          LoggingService.error('AI identification failed',
              error: Exception(data['error'].toString()), tag: 'LibraryScreen');
          throw Exception(data['error'].toString());
        } else {
          LoggingService.error('Invalid response from AI server', tag: 'LibraryScreen');
          throw Exception('Invalid response from server');
        }
      } else if (response.statusCode == 429) {
        LoggingService.warning('Rate limit exceeded', tag: 'LibraryScreen');
        throw Exception('Too many requests. Please wait a moment and try again.');
      } else if (response.statusCode >= 500) {
        LoggingService.error('Server error', error: Exception('Status: ${response.statusCode}'), tag: 'LibraryScreen');
        throw Exception('Server error. Please try again later.');
      } else {
        LoggingService.error('Unexpected response status',
            error: Exception('Status: ${response.statusCode}'), tag: 'LibraryScreen');
        throw Exception('Failed to identify bug. Please try again.');
      }
    } on FormatException {
      LoggingService.error('Format exception in AI response', tag: 'LibraryScreen');
      throw Exception('Invalid response from server. Please try again.');
    } on SocketException {
      LoggingService.error('Socket exception - no internet connection', tag: 'LibraryScreen');
      throw Exception('No internet connection. Please check your connection and try again.');
    } on TimeoutException catch (e) {
      LoggingService.error('Request timeout', error: e, tag: 'LibraryScreen');
      throw Exception(e.message);
    } catch (e) {
      LoggingService.error('Unexpected error in AI identification', error: e, tag: 'LibraryScreen');
      // Provide more specific error messages based on the error type
      if (e.toString().contains('List<Map')) {
        throw Exception('Server returned unexpected data format. Please try again.');
      } else if (e.toString().contains('type')) {
        throw Exception('Invalid data format received. Please try again.');
      } else {
        throw Exception('An unexpected error occurred. Please try again.');
      }
    }
    return null;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onDeleteItem(String id) async {
    await context.read<LibraryViewModel>().deleteItem(id);
  }

  void _onOpenDetail(IdentifiedItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(
          item: item,
          onDelete: () => _onDeleteItem(item.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final items = context.watch<LibraryViewModel>().items;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recents',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        actions: [
          // Subscription icon
          ValueListenableBuilder<bool>(
            valueListenable: isSubscribedNotifier,
            builder: (context, isSubscribed, _) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF2A2A36) : const Color(0xFFF5F5F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isSubscribed ? Icons.emoji_events_rounded : Icons.star_border_rounded,
                      size: 22,
                      color: isSubscribed ? Theme.of(context).colorScheme.primary : Colors.amber,
                    ),
                  ),
                  tooltip: isSubscribed ? 'Thank you for subscribing!' : 'Unlock Pro',
                  onPressed: () async {
                    if (!app.paywallOpen) {
                      app.paywallOpen = true;
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) => FractionallySizedBox(
                          heightFactor: 0.95, // % of the screen height, adjust as needed
                          child: PaywallScreen(),
                        ),
                      );
                      app.paywallOpen = false;

                      // Refresh subscription status after paywall is closed
                      try {
                        final purchaserInfo = await Purchases.getCustomerInfo();
                        final updatedSubscriptionStatus = purchaserInfo.entitlements.active.isNotEmpty;
                        if (updatedSubscriptionStatus != isSubscribedNotifier.value) {
                          isSubscribedNotifier.value = updatedSubscriptionStatus;
                          main.RevenueCatService.isSubscribed = updatedSubscriptionStatus;
                        }
                      } catch (e) {
                        // If we can't get the latest info, just use the cached value
                        final updatedSubscriptionStatus = main.RevenueCatService.isSubscribed;
                        if (updatedSubscriptionStatus != isSubscribedNotifier.value) {
                          isSubscribedNotifier.value = updatedSubscriptionStatus;
                        }
                      }
                    }
                  },
                ),
              );
            },
          ),
          // Settings icon
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2A2A36) : const Color(0xFFF5F5F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(HugeIcons.strokeRoundedSettings01, size: 22),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF2A2A36).withValues(alpha: 0.7) : const Color(0xFFF5F5F8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          HugeIcons.strokeRoundedImage01,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Your library is empty',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tap the + button to identify something!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final exists = item.imagePath.isNotEmpty && File(item.imagePath).existsSync();

                    if (!exists && item.imagePath.isNotEmpty) {}

                    return GestureDetector(
                      onTap: () => _onOpenDetail(item),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: exists
                                ? Image.file(
                                    File(item.imagePath),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                            SizedBox(height: 8),
                                            Text('Image error', style: TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Image not found', style: TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                          ),
                          // Price in top-right corner - minimal style
                          if (item.details['Estimated Price'] != null &&
                              item.details['Estimated Price'].toString().isNotEmpty &&
                              item.details['Estimated Price'].toString().toLowerCase() != 'unknown')
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _extractPriceRange(item.details['Estimated Price'].toString()),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          // Bottom overlay with item details
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.1),
                                        Colors.black.withValues(alpha: 0.6),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.result,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${(item.confidence * 100).toStringAsFixed(0)}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item.subtitle,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          // FAB menu overlay
          if (_fabMenuOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeFabMenu,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),
            // Floating action menu
            Positioned(
              right: 24,
              bottom: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ActionButton(
                    icon: HugeIcons.strokeRoundedCamera01,
                    label: 'Take Photo',
                    onTap: () async {
                      _closeFabMenu();
                      await _pickImage(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    icon: HugeIcons.strokeRoundedImage02,
                    label: 'Upload Photo',
                    onTap: () async {
                      _closeFabMenu();
                      await _pickImage(ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 16),
                  _CloseFabButton(onTap: _closeFabMenu),
                ],
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: !_fabMenuOpen
          ? FloatingActionButton(
              onPressed: _isProcessing ? null : _openFabMenu,
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(HugeIcons.strokeRoundedCameraAi, size: 32),
            )
          : null,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDarkMode ? const Color(0xFF23232B) : Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isDarkMode ? Colors.white : const Color(0xFF6C3CE9), size: 28),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseFabButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseFabButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.redAccent,
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.close, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _FunLoadingDialog extends StatefulWidget {
  const _FunLoadingDialog();

  @override
  State<_FunLoadingDialog> createState() => _FunLoadingDialogState();
}

class _FunLoadingDialogState extends State<_FunLoadingDialog> with SingleTickerProviderStateMixin {
  static final List<String> funTexts = [
    'Examining the specimen...',
    'Analyzing features...',
    'Checking identification markers...',
    'Consulting the field guide...',
    'Measuring dimensions...',
    'Comparing with known species...',
    'Looking for distinctive patterns...',
    'Examining the anatomy...',
    'Verifying classification...',
    'Studying the habitat...',
    'Matching characteristics...',
    'Evaluating taxonomy...'
  ];
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late String _currentText;
  late int _textIndex;

  @override
  void initState() {
    super.initState();
    _textIndex = Random().nextInt(funTexts.length);
    _currentText = funTexts[_textIndex];
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _animation =
        Tween<double>(begin: 0.85, end: 1.15).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    // Change text every 2 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      setState(() {
        _textIndex = (_textIndex + 1) % funTexts.length;
        _currentText = funTexts[_textIndex];
      });
      return true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDarkMode ? const Color(0xFF23232B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Icon(
                Icons.bug_report,
                color: AppTheme.primaryColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _currentText,
                key: ValueKey(_currentText),
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}

class _PremiumThankYouModal extends StatefulWidget {
  @override
  State<_PremiumThankYouModal> createState() => _PremiumThankYouModalState();
}

class _PremiumThankYouModalState extends State<_PremiumThankYouModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    SchedulerBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.95),
            theme.colorScheme.secondary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.emoji_events_rounded, color: Colors.amber[400], size: 70),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Text('🎉',
                      style: TextStyle(fontSize: 32, shadows: [Shadow(color: Colors.black26, blurRadius: 8)])),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Thank you for subscribing to bug_id Pro!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 14),
          const Text(
            "You're helping us grow and keep the app ad-free. Enjoy unlimited scans and library! 🌱",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Close', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _NotBugDialog extends StatelessWidget {
  const _NotBugDialog();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDarkMode ? const Color(0xFF2A2A36) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'No Bug Found',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'This image doesn\'t appear to contain a bug. Please try taking a photo of a bug.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
