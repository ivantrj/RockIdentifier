import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:PlantMate/data/models/identified_item.dart';
import 'package:PlantMate/core/theme/app_theme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailScreen extends StatelessWidget {
  final IdentifiedItem item;
  final VoidCallback onDelete;

  const ItemDetailScreen({required this.item, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final details = item.details;
    final wikipediaUrl = details['Wikipedia'] as String?;
    final price = details['Estimated Price'];

    // Collapsing hero image logic
    final double minHeroHeight = 80;
    final double maxHeroHeight = 300;
    final ValueNotifier<double> heroHeight = ValueNotifier(maxHeroHeight);

    // List of attribute keys to show as cards
    final attributeKeys = [
      'Type',
      'Material',
      'Gemstones',
      'Brand/Maker',
      'Era/Style',
      'Authenticity',
      'Hallmark/Stamp',
      'Condition',
      'Description',
      'Care Tips',
      'Provenance',
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              HugeIcons.strokeRoundedArrowLeft01,
              size: 20,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.result,
              style: AppTheme.pageTitleStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.black,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.subtitle.isNotEmpty)
              Text(
                item.subtitle,
                style: AppTheme.cardSubtitleStyle.copyWith(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                HugeIcons.strokeRoundedDelete02,
                size: 20,
                color: Colors.red.shade400,
              ),
              onPressed: () => _showDeleteDialog(context),
            ),
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.axis == Axis.vertical) {
            final offset = scrollNotification.metrics.pixels;
            final newHeight = (maxHeroHeight - offset).clamp(minHeroHeight, maxHeroHeight);
            heroHeight.value = newHeight;
          }
          return false;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Collapsing Hero image section
              ValueListenableBuilder<double>(
                valueListenable: heroHeight,
                builder: (context, height, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.ease,
                    height: height,
                    width: double.infinity,
                    child: _buildCleanHeroImage(context),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Price - prominent
              if (price != null) ...[
                _buildEstimatedPriceRow(context, price),
                const SizedBox(height: 24),
              ],

              // Important attributes as styled icon rows/cards
              _buildImportantAttributes(context, details),

              // More Information (modal cards)
              _buildMoreInfoCards(context, details),

              // Wikipedia link
              if (wikipediaUrl != null) ...[
                const SizedBox(height: 24),
                InkWell(
                  onTap: () => _launchUrl(wikipediaUrl),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(HugeIcons.strokeRoundedWikipedia),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Learn more on Wikipedia',
                            style: AppTheme.labelStyle.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(
                          HugeIcons.strokeRoundedSquareArrowUpRight,
                          color: AppTheme.primaryColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // More Information header and modal cards at the bottom
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'More Information', Icons.info_outline),
              const SizedBox(height: 16),
              _buildMoreInfoCards(context, details),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleanHeroImage(BuildContext context) {
    return Hero(
      tag: 'image-${item.id}',
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: item.imagePath.isNotEmpty && File(item.imagePath).existsSync()
              ? Image.file(
                  File(item.imagePath),
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.grey[200],
                  child: Icon(
                    HugeIcons.strokeRoundedAlbum02,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAttributeCard(BuildContext context, String label, dynamic value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final displayValue = value is List ? value.join(', ') : value.toString();
    return GestureDetector(
      onTap: () => _showInfoModal(context, label, displayValue),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_getIconForAttribute(label), color: AppTheme.primaryColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                displayValue,
                style: AppTheme.cardSubtitleStyle.copyWith(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForAttribute(String label) {
    final l = label.toLowerCase();
    if (l.contains('type')) return Icons.diamond;
    if (l.contains('material')) return Icons.military_tech;
    if (l.contains('gemstone')) return Icons.auto_awesome;
    if (l.contains('brand')) return Icons.verified_user;
    if (l.contains('era') || l.contains('style')) return Icons.event;
    if (l.contains('authenticity')) return Icons.verified;
    if (l.contains('hallmark')) return Icons.workspace_premium;
    if (l.contains('condition')) return Icons.favorite;
    if (l.contains('description')) return Icons.description;
    if (l.contains('care')) return Icons.cleaning_services;
    if (l.contains('provenance')) return Icons.history_edu;
    return Icons.info_outline;
  }

  void _showDeleteDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item? This action cannot be undone.'),
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
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildEstimatedPriceRow(BuildContext context, dynamic price) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(HugeIcons.strokeRoundedDollarCircle, color: AppTheme.primaryColor, size: 26),
              const SizedBox(width: 10),
              Text(
                'Estimated Price',
                style: AppTheme.labelStyle
                    .copyWith(fontSize: 20, color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            price.toString(),
            style: AppTheme.cardSubtitleStyle
                .copyWith(fontSize: 24, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Show important attributes as styled icon rows/cards directly
  Widget _buildImportantAttributes(BuildContext context, Map<String, dynamic> details) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final importantKeys = [
      'Type',
      'Material',
      'Gemstones',
      'Brand/Maker',
      'Era/Style',
      'Authenticity',
      'Hallmark/Stamp',
      'Condition',
    ];
    return Column(
      children: importantKeys.where((k) {
        final value = details[k];
        final displayValue = value is List ? value.join(', ') : value?.toString() ?? '';
        return value != null && displayValue.isNotEmpty && displayValue.toLowerCase() != 'unknown';
      }).map((k) {
        final value = details[k];
        final displayValue = value is List ? value.join(', ') : value.toString();
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_getIconForAttribute(k), color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  displayValue,
                  style: AppTheme.cardSubtitleStyle.copyWith(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Only show modal cards for 'More Information' attributes
  Widget _buildMoreInfoCards(BuildContext context, Map<String, dynamic> details) {
    final infoKeys = [
      'Description',
      'Care Tips',
      'Provenance',
    ];
    return Column(
      children: infoKeys
          .where((k) {
            final value = details[k];
            final displayValue = value is List ? value.join(', ') : value?.toString() ?? '';
            return value != null && displayValue.isNotEmpty && displayValue.toLowerCase() != 'unknown';
          })
          .map((k) => _buildAttributeCard(context, k, details[k]))
          .toList(),
    );
  }

  void _showInfoModal(BuildContext context, String label, String value) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.85,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  label,
                  style: AppTheme.cardTitleStyle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  value,
                  style: AppTheme.cardSubtitleStyle.copyWith(
                    fontSize: 16,
                    color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: 16),
        Text(
          title,
          style: AppTheme.cardTitleStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
