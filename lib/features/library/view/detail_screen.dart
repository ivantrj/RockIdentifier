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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.nearBlack,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [_buildSliverAppBar(context)];
          },
          body: TabBarView(
            children: [
              _buildDetailsTab(context),
              _buildHistoryTab(context),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.darkCharcoal,
      leading: _buildAppBarButton(context, HugeIcons.strokeRoundedArrowLeft01, () => Navigator.pop(context)),
      actions: [
        _buildAppBarButton(context, HugeIcons.strokeRoundedDelete02, () => _showDeleteDialog(context)),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        titlePadding: const EdgeInsets.only(bottom: 50, left: 16, right: 16),
        centerTitle: true,
        title: Text(item.result, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        background: Hero(
          tag: 'coin_image_${item.id}',
          child: Image.asset(
            item.imagePath,
            fit: BoxFit.cover,
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
          ),
        ),
      ),
      bottom: TabBar(
        indicatorColor: theme.colorScheme.primary,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.secondary,
        tabs: const [
          Tab(text: 'Details'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildDetailCard(context, 'Identification', {
            'Coin Name': item.result,
            'Origin': item.subtitle,
            'Confidence': '${(item.confidence * 100).toStringAsFixed(0)}%',
          }),
          const SizedBox(height: 16),
          _buildDetailCard(context, 'Specifications', {
            'Designer': item.details['Designer'] ?? 'N/A',
            'Composition': item.details['Composition'] ?? 'N/A',
            'Edge': item.details['Edge'] ?? 'N/A',
            'Diameter': item.details['Diameter'] ?? 'N/A',
            'Weight': item.details['Weight'] ?? 'N/A',
          }),
          const SizedBox(height: 16),
          _buildDetailCard(context, 'Numismatic Info', {
            'Grade': item.details['Grade'] ?? 'N/A',
            'Mintage': item.details['Mintage'] ?? 'N/A',
          }),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppTheme.darkCharcoal,
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        ),
        child: Text(
          item.details['Description'] ?? 'No history available.',
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryTextColor)),
                  Text(entry.value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
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
        content: const Text('Are you sure you want to delete this coin from your collection? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              onDelete();
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}