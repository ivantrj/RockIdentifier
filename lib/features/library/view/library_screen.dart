import 'package:flutter/services.dart';
import 'package:snake_id/core/widgets/coin_card.dart';
import 'package:snake_id/core/widgets/coin_card_placeholder.dart';
import 'package:snake_id/features/library/view/widgets/not_antique_dialog.dart';
import 'package:snake_id/features/paywall/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:snake_id/features/library/view/detail_screen.dart';
import '../viewmodel/library_viewmodel.dart';
import 'package:snake_id/data/models/identified_item.dart';
import 'package:image_picker/image_picker.dart';
import '../../../main.dart' as main;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:snake_id/app.dart' as app;
import 'package:snake_id/services/image_processing_service.dart';
import 'package:snake_id/services/logging_service.dart';
import 'package:snake_id/locator.dart';
import 'widgets/fab_menu.dart';
import 'widgets/loading_dialog.dart';
import 'package:snake_id/services/haptic_service.dart';
import 'package:snake_id/core/theme/app_theme.dart';

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

class _LibraryScreenBodyState extends State<_LibraryScreenBody> with TickerProviderStateMixin {
  bool _fabMenuOpen = false;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  String? _justAddedId;
  final ValueNotifier<bool> isSubscribedNotifier = ValueNotifier(main.RevenueCatService.isSubscribed);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    _listenForSubscriptionChanges();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.95,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCharcoal : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: PaywallScreen(),
        ),
      ),
    );
  }

  Future<void> _processImage(String imagePath) async {
    LoggingService.debug('Starting image processing - path: $imagePath', tag: 'LibraryScreen');
    setState(() {
      _fabMenuOpen = false;
      _isProcessing = true;
    });

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
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          LoggingService.warning('Error closing loading dialog in catch block', tag: 'LibraryScreen');
        }

        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('not_snake') ||
            errorMessage.contains('does not contain snake') ||
            errorMessage.contains('not snake') ||
            errorMessage.contains('no snake') ||
            errorMessage.contains('not a snake') ||
            errorMessage.contains('not reptile')) {
          LoggingService.info('Image identified as not a snake - showing dialog', tag: 'LibraryScreen');
          showDialog(
            context: context,
            barrierDismissible: true,
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
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
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
      backgroundColor: isDarkMode ? AppTheme.nearBlack : AppTheme.lightBackground,
      appBar: _buildModernAppBar(context, isDarkMode),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
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
                  elevation: 0,
                  highlightElevation: 0,
                  backgroundColor: isDarkMode ? AppTheme.forestGreen : AppTheme.emeraldGreen,
                  onPressed: _isProcessing
                      ? null
                      : () async {
                          await HapticService.instance.vibrate();
                          setState(() {}); // trigger animation
                          _openFabMenu();
                        },
                  child: _isProcessing
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          HugeIcons.strokeRoundedCameraAi,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
              ),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle:
          Theme.of(context).brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      title: Text(
        'My Collection',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      centerTitle: false,
      actions: [
        // Subscription icon
        ValueListenableBuilder<bool>(
          valueListenable: isSubscribedNotifier,
          builder: (context, isSubscribed, _) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isSubscribed ? Icons.emoji_events_rounded : Icons.card_giftcard,
                    size: 22,
                    color: isSubscribed
                        ? (isDarkMode ? AppTheme.forestGreen : AppTheme.emeraldGreen)
                        : (isDarkMode ? Colors.amber : Colors.amber.shade700),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                HugeIcons.strokeRoundedSettings01,
                size: 22,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
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
    final libraryViewModel = context.watch<LibraryViewModel>();

    // Show shimmering placeholders only when loading
    if (libraryViewModel.isLoading) {
      return MasonryGridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: 6,
        itemBuilder: (context, index) => const SnakeCardPlaceholder(),
      );
    }

    // Show empty state when not loading and no items
    if (items.isEmpty) {
      return _buildModernEmptyState(context, isDarkMode);
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return SnakeCard(
          item: item,
          onTap: () => _onOpenDetail(item),
        );
      },
    );
  }

  Widget _buildModernEmptyState(BuildContext context, bool isDarkMode) {
    return _ModernEmptyState(isDarkMode: isDarkMode);
  }
}

class _ModernEmptyState extends StatefulWidget {
  final bool isDarkMode;
  const _ModernEmptyState({required this.isDarkMode});

  @override
  State<_ModernEmptyState> createState() => _ModernEmptyStateState();
}

class _ModernEmptyStateState extends State<_ModernEmptyState> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _floatController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    _bounceController.forward();
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated floating Snake icon
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 8 * _floatAnimation.value),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isDarkMode
                            ? [
                                AppTheme.forestGreen,
                                AppTheme.darkCharcoal,
                              ]
                            : [
                                AppTheme.emeraldGreen,
                                AppTheme.forestGreen,
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.isDarkMode
                              ? AppTheme.forestGreen.withValues(alpha: 0.3)
                              : AppTheme.emeraldGreen.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedAbacus,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Animated title
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: Text(
                    'Discover Snakes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Subtitle with better typography
            Text(
              'Capture photos of snakes to learn about their species, habitat, and safety information. Build your knowledge of these fascinating reptiles!',
              style: TextStyle(
                fontSize: 16,
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Decorative elements
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDecorativeDot(widget.isDarkMode, 0),
                const SizedBox(width: 8),
                _buildDecorativeDot(widget.isDarkMode, 1),
                const SizedBox(width: 8),
                _buildDecorativeDot(widget.isDarkMode, 2),
              ],
            ),
            const SizedBox(height: 40),
            // Call to action hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? AppTheme.darkCharcoal : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isDarkMode ? Colors.white24 : Colors.black12,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(widget.isDarkMode ? 0.3 : 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? AppTheme.forestGreen.withOpacity(0.2)
                          : AppTheme.emeraldGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedCameraAi,
                      size: 20,
                      color: widget.isDarkMode ? AppTheme.forestGreen : AppTheme.emeraldGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tap the camera to identify snakes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeDot(bool isDarkMode, int index) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final delay = index * 0.2;
        final animationValue = (_floatController.value + delay) % 1.0;
        return Transform.scale(
          scale: 0.8 + 0.2 * animationValue,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode
                  ? AppTheme.forestGreen.withValues(alpha: 0.3 + 0.4 * animationValue)
                  : AppTheme.emeraldGreen.withValues(alpha: 0.2 + 0.3 * animationValue),
            ),
          ),
        );
      },
    );
  }
}
