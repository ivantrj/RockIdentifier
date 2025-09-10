import 'package:rock_id/features/library/view/widgets/not_antique_dialog.dart';
import 'package:rock_id/features/paywall/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:rock_id/features/library/view/detail_screen.dart';
import '../viewmodel/library_viewmodel.dart';
import 'package:rock_id/data/models/identified_item.dart';
import 'package:image_picker/image_picker.dart';
import '../../../main.dart' as main;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rock_id/app.dart' as app;
import 'package:rock_id/services/image_processing_service.dart';
import 'package:rock_id/services/logging_service.dart';
import 'widgets/fab_menu.dart';
import 'widgets/library_item_card.dart';
import 'widgets/loading_dialog.dart';
import 'package:rock_id/services/scan_tracking_service.dart';

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
  final ImageProcessingService _imageProcessingService = ImageProcessingService();

  // ValueNotifier for subscription state
  final ValueNotifier<bool> isSubscribedNotifier = ValueNotifier(main.RevenueCatService.isSubscribed);

  @override
  void initState() {
    super.initState();
    _listenForSubscriptionChanges();
  }

  void _listenForSubscriptionChanges() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      final isSubscribed = customerInfo.entitlements.active.isNotEmpty;
      isSubscribedNotifier.value = isSubscribed;
      main.RevenueCatService.isSubscribed = isSubscribed;
    });
  }

  void _openFabMenu() => setState(() => _fabMenuOpen = true);
  void _closeFabMenu() => setState(() => _fabMenuOpen = false);

  Future<void> _pickImage(ImageSource source) async {
    LoggingService.userAction('Image picker opened', details: 'source: ${source.name}', tag: 'LibraryScreen');

    final isSubscribed = main.RevenueCatService.isSubscribed;

    if (!isSubscribed && await ScanTrackingService.hasExceededFreeLimit()) {
      LoggingService.userAction('Paywall shown', details: 'reason: free scan limit exceeded', tag: 'LibraryScreen');
      await _showPaywall();
      return;
    }

    final pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      LoggingService.userAction('Image selected', details: 'path: ${pickedFile.path}', tag: 'LibraryScreen');
      await _processImage(pickedFile.path);
    }
  }

  Future<void> _showPaywall() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.95,
        child: PaywallScreen(),
      ),
    );
  }

  Future<void> _processImage(String imagePath) async {
    setState(() {
      _fabMenuOpen = false;
      _isProcessing = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(),
    );

    try {
      final item = await _imageProcessingService.processImage(imagePath);

      if (mounted) {
        if (item != null) {
          LoggingService.userAction('Item added to library', details: 'result: ${item.result}', tag: 'LibraryScreen');
          context.read<LibraryViewModel>().addItem(item);
          // Increment scan count after successful identification
          await ScanTrackingService.incrementScanCount();
          Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
        } else {
          LoggingService.warning('AI did not return a valid result', tag: 'LibraryScreen');
          _showError('AI did not return a valid result.');
        }
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('NOT_BUG')) {
          LoggingService.info('Image identified as not a bug', tag: 'LibraryScreen');
          Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
          showDialog(
            context: context,
            builder: (context) => const NotSnakeDialog(),
          );
        } else {
          LoggingService.error('Error processing image', error: e, tag: 'LibraryScreen');
          String errorMessage = 'Failed to identify image';
          if (e is Exception) {
            errorMessage = e.toString().replaceAll('Exception: ', '');
          } else {
            errorMessage = 'An unexpected error occurred. Please try again.';
          }
          _showError(errorMessage);
        }
      }
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
        setState(() {
          _isProcessing = false;
        });
      }
    }
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
      appBar: _buildAppBar(context, isDarkMode),
      body: Stack(
        children: [
          // Main content
          _buildBody(context, items, isDarkMode),
          // FAB menu overlay
          FabMenu(
            isOpen: _fabMenuOpen,
            isProcessing: _isProcessing,
            onOpen: _openFabMenu,
            onClose: _closeFabMenu,
            onImagePicked: _pickImage,
          ),
        ],
      ),
      floatingActionButton: !_fabMenuOpen
          ? FloatingActionButton(
              heroTag: null, // Disable hero animation to avoid conflicts
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

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
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
                onPressed: () => _handleSubscriptionTap(context, isSubscribed),
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
    );
  }

  Future<void> _handleSubscriptionTap(BuildContext context, bool isSubscribed) async {
    if (!isSubscribed && !app.paywallOpen) {
      app.paywallOpen = true;
      await _showPaywall();
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
  }

  Widget _buildBody(BuildContext context, List<IdentifiedItem> items, bool isDarkMode) {
    if (items.isEmpty) {
      return _buildEmptyState(context, isDarkMode);
    }

    return GridView.builder(
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
        return LibraryItemCard(
          item: item,
          onTap: () => _onOpenDetail(item),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
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
              color: Theme.of(context).colorScheme.primary,
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
    );
  }
}
