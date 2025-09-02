import 'dart:io';
import 'dart:ui';
import 'package:coin_id/data/models/identified_item.dart';
import 'package:coin_id/services/haptic_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:coin_id/core/theme/app_theme.dart';
import 'package:hugeicons/hugeicons.dart';

class ItemDetailScreen extends StatelessWidget {
  final IdentifiedItem item;
  final VoidCallback onDelete;

  const ItemDetailScreen({required this.item, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // Use the nearBlack color for the background to match the library
      backgroundColor: AppTheme.nearBlack,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Title
                  Text(item.result, style: textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(item.subtitle, style: textTheme.bodyLarge?.copyWith(color: AppTheme.secondaryTextColor)),
                  const SizedBox(height: 24),

                  // Key Details Section
                  _buildDetailCard(context, {
                    'Confidence': '${(item.confidence * 100).toStringAsFixed(0)}%',
                    // --- Placeholder Coin Data ---
                    'Country': item.details['Country'] ?? 'N/A',
                    'Year': item.details['Year'] ?? 'N/A',
                    'Denomination': item.details['Denomination'] ?? 'N/A',
                    'Composition': item.details['Composition'] ?? 'N/A',
                    'Mintage': item.details['Mintage'] ?? 'N/A',
                  }),

                  const SizedBox(height: 24),

                  // Description/History Section
                  if (item.details['Description'] != null) _buildDescriptionCard(context, item.details['Description']!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.darkCharcoal, // Collapsed app bar color
      leading: _buildAppBarButton(context, HugeIcons.strokeRoundedArrowLeft01, () => Navigator.pop(context)),
      actions: [
        _buildAppBarButton(context, HugeIcons.strokeRoundedDelete02, () => _showDeleteDialog(context)),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        background: Hero(
          // Ensure the tag matches the one in CoinCard
          tag: 'coin_image_${item.id}',
          child: _buildImage(),
        ),
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

  Widget _buildDetailCard(BuildContext context, Map<String, String> details) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCharcoal,
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        border: Border.all(color: AppTheme.subtleBorderColor),
      ),
      child: Column(
        children: details.entries.map((entry) {
          final isFirst = details.keys.first == entry.key;
          return Column(
            children: [
              if (!isFirst)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(height: 1, color: AppTheme.subtleBorderColor),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryTextColor)),
                    Text(entry.value, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, String description) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.darkCharcoal,
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        border: Border.all(color: AppTheme.subtleBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('History', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
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
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              onDelete();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back from detail screen
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // Check if it's an asset path (starts with 'assets/')
    if (item.imagePath.startsWith('assets/')) {
      return Image.asset(
        item.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image, color: Colors.grey),
          );
        },
      );
    } else {
      // It's a file path
      return Image.file(
        File(item.imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image, color: Colors.grey),
          );
        },
      );
    }
  }
}
