import 'package:antique_id/features/paywall/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:antique_id/features/library/view/detail_screen.dart';
import '../viewmodel/library_viewmodel.dart';
import 'package:antique_id/data/models/identified_item.dart';
import 'package:image_picker/image_picker.dart';
import '../../../main.dart' as main;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:antique_id/app.dart' as app;
import 'package:antique_id/services/image_processing_service.dart';
import 'package:antique_id/services/logging_service.dart';
import 'package:antique_id/locator.dart';
import 'widgets/fab_menu.dart';
import 'widgets/library_item_card.dart';
import 'widgets/loading_dialog.dart';
import 'widgets/not_antique_dialog.dart';
import 'package:antique_id/services/haptic_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  String? _justAddedId; // Track the most recently added item

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

    final items = context.read<LibraryViewModel>().items;
    final isSubscribed = main.RevenueCatService.isSubscribed;

    if (!isSubscribed && items.isNotEmpty) {
      LoggingService.userAction('Paywall shown', details: 'reason: subscription required', tag: 'LibraryScreen');
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
    LoggingService.debug('Starting image processing - path: $imagePath', tag: 'LibraryScreen');

    setState(() {
      _fabMenuOpen = false;
      _isProcessing = true;
    });

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoadingDialog(),
      );
    }

    try {
      LoggingService.debug('Calling ImageProcessingService', tag: 'LibraryScreen');
      final item = await locator<ImageProcessingService>().processImage(imagePath);

      if (mounted) {
        // Close loading dialog first
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          LoggingService.warning('Error closing loading dialog', tag: 'LibraryScreen');
        }

        if (item != null) {
          LoggingService.userAction('Item added to library', details: 'result:  [${item.result}', tag: 'LibraryScreen');
          try {
            await context.read<LibraryViewModel>().addItem(item);
            LoggingService.debug('Item successfully added to viewmodel', tag: 'LibraryScreen');

            // Set just added ID for animation
            if (mounted) {
              setState(() {
                _justAddedId = item.id;
              });
            }
          } catch (e) {
            LoggingService.error('Error adding item to viewmodel', error: e, tag: 'LibraryScreen');
            _showError('Error saving item to library.');
          }
        } else {
          LoggingService.warning('AI did not return a valid result', tag: 'LibraryScreen');
          _showError('AI did not return a valid result.');
        }
      }
    } catch (e) {
      LoggingService.error('Error in _processImage', error: e, tag: 'LibraryScreen');
      LoggingService.debug('Error message: ${e.toString()}', tag: 'LibraryScreen');

      if (mounted) {
        // Close loading dialog first
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          LoggingService.warning('Error closing loading dialog in catch block', tag: 'LibraryScreen');
        }

        // Check for NOT_ANTIQUE error with more robust detection
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('not_antique') ||
            errorMessage.contains('does not contain antique') ||
            errorMessage.contains('not antique') ||
            errorMessage.contains('no antique') ||
            errorMessage.contains('modern item') ||
            errorMessage.contains('not artifact')) {
          LoggingService.info('Image identified as not an antique - showing dialog', tag: 'LibraryScreen');
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => const NotAntiqueDialog(),
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
        setState(() {
          _isProcessing = false;
        });
        LoggingService.debug('Image processing completed', tag: 'LibraryScreen');
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
    Navigator.of(context).push(_fadeSlideRoute(
      ItemDetailScreen(
        item: item,
        onDelete: () => _onDeleteItem(item.id),
      ),
    ));
  }

  Route _fadeSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        final fadeAnimation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
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
          ? AnimatedScale(
              scale: _fabMenuOpen ? 0.8 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: FloatingActionButton(
                  key: ValueKey(_isProcessing),
                  onPressed: _isProcessing
                      ? null
                      : () async {
                          await HapticService.instance.vibrate();
                          setState(() {}); // trigger animation
                          _openFabMenu();
                        },
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
                ),
              ),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      title: const Text(
        'Antique Collection',
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
            onPressed: () async {
              await HapticService.instance.vibrate();
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
          isJustAdded: item.id == _justAddedId,
          onJustAddedAnimationEnd: item.id == _justAddedId ? () => setState(() => _justAddedId = null) : null,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return _BouncyEmptyState(isDarkMode: isDarkMode);
  }
}

class _BouncyEmptyState extends StatefulWidget {
  final bool isDarkMode;
  const _BouncyEmptyState({required this.isDarkMode});

  @override
  State<_BouncyEmptyState> createState() => _BouncyEmptyStateState();
}

class _BouncyEmptyStateState extends State<_BouncyEmptyState> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/onboarding/onboarding_1.svg',
            height: 140,
          ),
          const SizedBox(height: 32),
          Text(
            'No antiques here yet! 🏺',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start identifying antiques by tapping the button below.',
            style: TextStyle(
              fontSize: 16,
              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
