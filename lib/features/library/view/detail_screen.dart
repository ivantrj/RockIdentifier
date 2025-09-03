import 'dart:io';
import 'dart:ui';
import 'package:coin_id/data/models/identified_item.dart';
import 'package:coin_id/features/chat/view/chat_screen.dart';
import 'package:coin_id/services/haptic_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:coin_id/core/theme/app_theme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailScreen extends StatefulWidget {
  final IdentifiedItem item;
  final VoidCallback onDelete;

  const ItemDetailScreen({required this.item, required this.onDelete, super.key});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nearBlack,
      // Add a Floating Action Button for the Chat feature
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(
            builder: (_) => ChatScreen(item: widget.item),
          ));
        },
        child: const Icon(HugeIcons.strokeRoundedChatBot, color: AppTheme.darkCharcoal),
      ),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildCustomSegmentedControl(context),
                // Use an IndexedStack to preserve the state of each tab's content
                IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    _buildDetailsTab(context),
                    _buildHistoryTab(context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSegmentedControl(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: AppTheme.darkCharcoal,
        borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
      ),
      child: Row(
        children: [
          _buildSegment(context, 'Details', 0),
          _buildSegment(context, 'History', 1),
        ],
      ),
    );
  }

  Widget _buildSegment(BuildContext context, String title, int index) {
    final theme = Theme.of(context);
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected ? AppTheme.darkCharcoal : AppTheme.secondaryTextColor,
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.darkCharcoal,
      leading: _buildAppBarButton(context, HugeIcons.strokeRoundedArrowLeft01, () => Navigator.pop(context)),
      actions: [
        _buildAppBarButton(context, HugeIcons.strokeRoundedDelete02, () => _showDeleteDialog(context)),
        const SizedBox(width: 16),
      ],
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        centerTitle: true,
        title: Text(widget.item.result, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        background: Hero(
          tag: 'coin_image_${widget.item.id}',
          child: _buildCoinImage(widget.item.imagePath),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Value & Investment Section - Prominently displayed
          _buildValueCard(context),
          const SizedBox(height: 16),

          _buildDetailCard(context, 'Identification', {
            'Coin Name': widget.item.result,
            'Type': widget.item.details['coinType'] ?? 'N/A',
            'Denomination': widget.item.details['denomination'] ?? 'N/A',
            'Origin': widget.item.subtitle,
            'Country': widget.item.details['country'] ?? 'N/A',
            'Mint Year': widget.item.details['mintYear'] ?? 'N/A',
            'Mint Mark': widget.item.details['mintMark'] ?? 'N/A',
            'Confidence': '${(widget.item.confidence * 100).toStringAsFixed(0)}%',
          }),
          const SizedBox(height: 16),

          _buildDetailCard(context, 'Specifications', {
            'Designer': widget.item.details['designer'] ?? widget.item.details['Designer'] ?? 'N/A',
            'Composition': widget.item.details['metalComposition'] ?? widget.item.details['Composition'] ?? 'N/A',
            'Edge': widget.item.details['edgeType'] ?? widget.item.details['Edge'] ?? 'N/A',
            'Diameter': widget.item.details['diameter'] ?? widget.item.details['Diameter'] ?? 'N/A',
            'Weight': widget.item.details['weight'] ?? widget.item.details['Weight'] ?? 'N/A',
          }),
          const SizedBox(height: 16),

          _buildDetailCard(context, 'Market & Investment', {
            'Grade': widget.item.details['condition'] ?? widget.item.details['Grade'] ?? 'N/A',
            'Rarity': widget.item.details['rarity'] ?? 'N/A',
            'Mintage': widget.item.details['mintage'] ?? widget.item.details['Mintage'] ?? 'N/A',
            'Market Demand': widget.item.details['marketDemand'] ?? 'N/A',
            'Investment Potential': widget.item.details['investmentPotential'] ?? 'N/A',
            'Authenticity': widget.item.details['authenticity'] ?? 'N/A',
          }),
          const SizedBox(height: 16),

          _buildDetailCard(context, 'Additional Details', {
            'Storage Recommendations': widget.item.details['storageRecommendations'] ?? 'N/A',
            'Cleaning Instructions': widget.item.details['cleaningInstructions'] ?? 'N/A',
            'Similar Coins': widget.item.details['similarCoins'] ?? 'N/A',
          }),

          // Wiki Link Button
          if (widget.item.details['wikiLink'] != null) ...[
            const SizedBox(height: 16),
            _buildWikiButton(context, widget.item.details['wikiLink']!),
          ],
        ],
      ),
    );
  }

  Widget _buildValueCard(BuildContext context) {
    final theme = Theme.of(context);
    final estimatedValue = widget.item.details['estimatedValue'];
    final rarity = widget.item.details['rarity'];
    final condition = widget.item.details['condition'];
    final mintage = widget.item.details['mintage'];

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2D2D2D),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estimated Value - Large and prominent
          if (estimatedValue != null) ...[
            Text(
              'Estimated Value',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              estimatedValue,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Rarity with visual indicator
          if (rarity != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rarity Level',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRarityColor(rarity).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getRarityColor(rarity).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    rarity,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _getRarityColor(rarity),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rarity slider with clear labels
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  // Background bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Colored progress bar
                  Container(
                    height: 8,
                    width: MediaQuery.of(context).size.width * 0.6 * (_getRarityValue(rarity) / 100),
                    decoration: BoxDecoration(
                      color: _getRarityColor(rarity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Rarity indicator dot
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.6 * (_getRarityValue(rarity) / 100) - 4,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getRarityColor(rarity),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Clear rarity explanation
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _getRarityExplanation(rarity),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 12,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Condition and Mintage
          Row(
            children: [
              if (condition != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Condition',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        condition,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (mintage != null) ...[
                if (condition != null) const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mintage',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mintage,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String? rarity) {
    if (rarity == null) return Colors.grey;
    switch (rarity.toLowerCase()) {
      case 'very rare':
      case 'ultra rare':
        return Colors.red;
      case 'rare':
        return Colors.orange;
      case 'scarce':
        return Colors.amber;
      case 'common':
      case 'very common':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  int _getRarityValue(String? rarity) {
    if (rarity == null) return 0;
    switch (rarity.toLowerCase()) {
      case 'very rare':
      case 'ultra rare':
        return 90;
      case 'rare':
        return 70;
      case 'scarce':
        return 50;
      case 'common':
        return 30;
      case 'very common':
        return 20;
      default:
        return 0;
    }
  }

  String _getRarityExplanation(String? rarity) {
    if (rarity == null) return 'Rarity information not available';
    switch (rarity.toLowerCase()) {
      case 'very rare':
      case 'ultra rare':
        return 'Extremely difficult to find. These coins are highly sought after by collectors.';
      case 'rare':
        return 'Hard to find. These coins have significant collector value.';
      case 'scarce':
        return 'Limited availability. These coins are moderately valuable.';
      case 'common':
        return 'Readily available. These coins are easily found in circulation.';
      case 'very common':
        return 'Widely available. These coins are frequently encountered.';
      default:
        return 'Rarity level information not available.';
    }
  }

  Widget _buildWikiButton(BuildContext context, String wikiUrl) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _openWikiLink(wikiUrl),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D2D2D),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: const Color(0xFF3D3D3D),
              width: 1,
            ),
          ),
        ),
        icon: Icon(
          Icons.open_in_new,
          size: 20,
          color: AppTheme.metallicGold,
        ),
        label: Text(
          'View on Wikipedia',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _openWikiLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Wikipedia link'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening Wikipedia link'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildCoinImage(String imagePath) {
    // Debug logging
    print('Building coin image with path: $imagePath');
    print('Path type: ${imagePath.startsWith('/') ? 'File' : 'Asset'}');

    // Check if it's a file path (starts with /) or an asset path
    if (imagePath.startsWith('/')) {
      // It's a file path - use Image.file
      final file = File(imagePath);
      final exists = file.existsSync();
      print('File exists: $exists');

      if (!exists) {
        print('File does not exist: $imagePath');
        return Container(
          color: AppTheme.darkCharcoal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                color: AppTheme.secondaryTextColor,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'Image not found',
                style: TextStyle(color: AppTheme.secondaryTextColor),
              ),
              const SizedBox(height: 4),
              Text(
                'Path: ${imagePath.split('/').last}',
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }

      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading file image: $error');
          return Container(
            color: AppTheme.darkCharcoal,
            child: Icon(
              Icons.image_not_supported,
              color: AppTheme.secondaryTextColor,
              size: 48,
            ),
          );
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          return Stack(
            fit: StackFit.expand,
            children: [
              child,
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.black.withOpacity(0.8)],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // It's an asset path - use Image.asset
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading asset image: $error');
          return Container(
            color: AppTheme.darkCharcoal,
            child: Icon(
              Icons.image_not_supported,
              color: AppTheme.secondaryTextColor,
              size: 48,
            ),
          );
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          return Stack(
            fit: StackFit.expand,
            children: [
              child,
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.black.withOpacity(0.8)],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildHistoryTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppTheme.darkCharcoal,
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        ),
        child: Text(
          widget.item.details['historicalContext'] ?? widget.item.details['Description'] ?? 'No history available.',
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, color: AppTheme.secondaryTextColor),
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String title, Map<String, String> details) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.darkCharcoal,
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          ...details.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryTextColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.value,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAppBarButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.glassColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
              border: Border.all(color: AppTheme.subtleBorderColor.withOpacity(0.5)),
            ),
            child: IconButton(
              icon: Icon(icon, size: 22, color: AppTheme.primaryTextColor),
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    HapticService.instance.vibrate();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Coin'),
        content:
            const Text('Are you sure you want to delete this coin from your collection? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
