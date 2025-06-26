import 'package:PlantMate/features/paywall/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:PlantMate/features/library/view/detail_screen.dart';
import '../viewmodel/library_viewmodel.dart';
import 'package:PlantMate/data/models/identified_item.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../../../main.dart' as main;
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter/scheduler.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:PlantMate/app.dart' as app;

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
  }

  void _openFabMenu() => setState(() => _fabMenuOpen = true);
  void _closeFabMenu() => setState(() => _fabMenuOpen = false);

  Future<String> _saveImageToAppDir(String imagePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(imagePath);
    final savedImage =
        await File(imagePath).copy(p.join(appDir.path, '${DateTime.now().millisecondsSinceEpoch}_$fileName'));
    return savedImage.path;
  }

  Future<void> _pickImage(ImageSource source) async {
    final items = context.read<LibraryViewModel>().items;
    final isSubscribed = main.RevenueCatService.isSubscribed;
    if (!isSubscribed && items.isNotEmpty) {
      await RevenueCatUI.presentPaywall();
      return;
    }
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      setState(() => _fabMenuOpen = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _FunLoadingDialog(),
      );
      try {
        final savedPath = await _saveImageToAppDir(pickedFile.path);
        final aiResult = await _identifyPlantWithAI(File(savedPath));
        if (aiResult != null) {
          final details = <String, dynamic>{
            if (aiResult['characteristics'] != null) 'Characteristics': aiResult['characteristics'],
            if (aiResult['careGuide'] != null) 'Care Guide': aiResult['careGuide'],
            if (aiResult['toxicity'] != null) 'Toxicity': aiResult['toxicity'],
            if (aiResult['uses'] != null) 'Uses': aiResult['uses'],
            if (aiResult['difficultyLevel'] != null) 'Difficulty Level': aiResult['difficultyLevel'],
            if (aiResult['propagation'] != null) 'Propagation': aiResult['propagation'],
            if (aiResult['commonProblems'] != null) 'Common Problems': aiResult['commonProblems'],
            if (aiResult['additionalInfo'] != null) 'Additional Info': aiResult['additionalInfo'],
            if (aiResult['wikiLink'] != null) 'Wikipedia': aiResult['wikiLink'],
            if (aiResult['estimatedPrice'] != null) 'Estimated Price': aiResult['estimatedPrice'],
          };
          final item = IdentifiedItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            imagePath: savedPath,
            result: aiResult['commonName'] ?? aiResult['name'] ?? 'Unknown',
            subtitle: aiResult['name'] ?? '',
            confidence: _parseConfidence(aiResult['confidence']),
            details: details,
            dateTime: DateTime.now(),
          );
          if (mounted) {
            context.read<LibraryViewModel>().addItem(item);
          }
        } else {
          _showError('AI did not return a valid result.');
        }
      } catch (e) {
        _showError('Failed to identify image: $e');
      } finally {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
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

  Future<Map<String, dynamic>?> _identifyPlantWithAI(File imageFile) async {
    final uri = Uri.parse('https://own-ai-backend-dev.fly.dev/identify-plant');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['result'] != null) {
        return Map<String, dynamic>.from(data['result']);
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
          'My Library',
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
                  tooltip: isSubscribed ? 'Thank you for subscribing!' : 'Unlock Premium',
                  onPressed: () async {
                    if (!isSubscribed) {
                      if (!app.App.paywallOpen) {
                        app.App.paywallOpen = true;
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const PaywallScreen(),
                        );
                        app.App.paywallOpen = false;
                      }
                    } else {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => _PremiumThankYouModal(),
                      );
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
                          color: isDarkMode ? const Color(0xFF2A2A36).withOpacity(0.7) : const Color(0xFFF5F5F8),
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
                    return GestureDetector(
                      onTap: () => _onOpenDetail(item),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: item.imagePath.isNotEmpty && File(item.imagePath).existsSync()
                                ? Image.file(
                                    File(item.imagePath),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Image not found', style: TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                          ),
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
                                        Colors.black.withOpacity(0.1),
                                        Colors.black.withOpacity(0.6),
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
                                              color: Colors.white.withOpacity(0.25),
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
                                      const SizedBox(height: 4),
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
                  color: Colors.black.withOpacity(0.3),
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
              onPressed: _openFabMenu,
              child: const Icon(HugeIcons.strokeRoundedCameraAi, size: 32),
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
  static const List<String> funTexts = [
    'Talking to the plants...',
    'Analyzing leaves...',
    'Looking for green clues...',
    'Consulting the garden gnomes...',
    'Photosynthesizing...',
    'Sniffing the soil...',
    'Counting petals...',
    'Checking for root rot...',
    'Asking the bees...',
    'Comparing chlorophyll...',
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
                HugeIcons.strokeRoundedPlant02,
                color: Colors.green[600],
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
            const CircularProgressIndicator(color: Colors.green, strokeWidth: 3),
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
            theme.colorScheme.primary.withOpacity(0.95),
            theme.colorScheme.secondary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
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
            'Thank you for subscribing to PlantMate Premium!',
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
