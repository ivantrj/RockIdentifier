import 'dart:io';
import 'dart:ui';
import 'package:coin_id/data/models/identified_item.dart';
import 'package:coin_id/features/chat/view/chat_screen.dart';
import 'package:coin_id/services/haptic_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:coin_id/core/theme/app_theme.dart';
import 'package:hugeicons/hugeicons.dart';

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
          child: Image.asset(
            widget.item.imagePath,
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
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
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
          _buildDetailCard(context, 'Numismatic Info', {
            'Grade': widget.item.details['condition'] ?? widget.item.details['Grade'] ?? 'N/A',
            'Mintage': widget.item.details['mintage'] ?? widget.item.details['Mintage'] ?? 'N/A',
            'Rarity': widget.item.details['rarity'] ?? 'N/A',
            'Estimated Value': widget.item.details['estimatedValue'] ?? 'N/A',
          }),
          const SizedBox(height: 16),
          _buildDetailCard(context, 'Additional Details', {
            'Authenticity': widget.item.details['authenticity'] ?? 'N/A',
            'Market Demand': widget.item.details['marketDemand'] ?? 'N/A',
            'Investment Potential': widget.item.details['investmentPotential'] ?? 'N/A',
            'Insurance Value': widget.item.details['insuranceValue'] ?? 'N/A',
          }),
        ],
      ),
    );
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
