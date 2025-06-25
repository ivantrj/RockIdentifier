import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ai_plant_identifier/data/models/identified_item.dart';
import 'package:ai_plant_identifier/core/theme/app_theme.dart';
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
    final careGuide = details['Care Guide'] as Map<String, dynamic>?;
    final toxicity = details['Toxicity'] as Map<String, dynamic>?;
    final wikipediaUrl = details['Wikipedia'] as String?;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
      appBar: _buildMinimalAppBar(context, isDarkMode),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image section
            _buildCleanHeroImage(context),
            const SizedBox(height: 32),

            // Plant identification card
            _buildIdentificationCard(context, isDarkMode, wikipediaUrl),
            const SizedBox(height: 32),

            // Care guide section
            if (careGuide != null) ...[
              _buildSectionHeader(context, 'Plant Care', HugeIcons.strokeRoundedPlant02),
              const SizedBox(height: 16),
              _buildCareGuideCards(context, careGuide),
              const SizedBox(height: 32),
            ],

            // Safety information
            if (toxicity != null) ...[
              _buildSectionHeader(context, 'Safety Information', HugeIcons.strokeRoundedPlant02),
              const SizedBox(height: 16),
              _buildToxicityCards(context, toxicity),
              const SizedBox(height: 24),
            ],

            // Estimated Price (smaller, less intrusive)
            if (details['Estimated Price'] != null) ...[
              _buildEstimatedPriceRow(context, details['Estimated Price']),
              const SizedBox(height: 24),
            ],

            // Grouped Info Section
            _buildGroupedInfoSection(context, details),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildMinimalAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
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

  Widget _buildIdentificationCard(BuildContext context, bool isDarkMode, String? wikipediaUrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plant name and subtitle
          Text(
            item.result,
            style: AppTheme.pageTitleStyle.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : Colors.black,
              height: 1.2,
            ),
          ),
          if (item.subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.subtitle,
              style: AppTheme.cardSubtitleStyle.copyWith(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.7),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Confidence indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  HugeIcons.strokeRoundedSearchFocus,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confidence Level',
                    style: AppTheme.labelStyle.copyWith(
                      fontSize: 14,
                      color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(item.confidence * 100).toStringAsFixed(0)}%',
                    style: AppTheme.cardTitleStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

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
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: AppTheme.cardTitleStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCareGuideCards(BuildContext context, Map<String, dynamic> careGuide) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final careItems = [
      if (careGuide['light'] != null) _CareInfo('☀️', 'Light', careGuide['light']),
      if (careGuide['water'] != null) _CareInfo('💧', 'Water', careGuide['water']),
      if (careGuide['soil'] != null) _CareInfo('🌱', 'Soil', careGuide['soil']),
      if (careGuide['temperature'] != null) _CareInfo('🌡️', 'Temperature', careGuide['temperature']),
      if (careGuide['humidity'] != null) _CareInfo('💦', 'Humidity', careGuide['humidity']),
      if (careGuide['fertilizer'] != null) _CareInfo('🧪', 'Fertilizer', careGuide['fertilizer']),
      if (careGuide['pruning'] != null) _CareInfo('✂️', 'Pruning', careGuide['pruning']),
    ];

    return Column(
      children: careItems
          .map((care) => Container(
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(care.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            care.label,
                            style: AppTheme.cardTitleStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            care.value,
                            style: AppTheme.cardSubtitleStyle.copyWith(
                              fontSize: 14,
                              color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildToxicityCards(BuildContext context, Map<String, dynamic> toxicity) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final toxicityItems = <_ToxicityInfo>[];

    if (toxicity['toxic'] != null) {
      toxicityItems.add(_ToxicityInfo(
        toxicity['toxic'] ? '⚠️' : '✅',
        toxicity['toxic'] ? 'Toxic Plant' : 'Non-Toxic Plant',
        toxicity['toxic'] ? Colors.red : Colors.green,
      ));
    }

    if (toxicity['toxicToCats'] != null) {
      toxicityItems.add(_ToxicityInfo(
        '🐱',
        toxicity['toxicToCats'] ? 'Toxic to Cats' : 'Safe for Cats',
        toxicity['toxicToCats'] ? Colors.red : Colors.green,
      ));
    }

    if (toxicity['toxicToDogs'] != null) {
      toxicityItems.add(_ToxicityInfo(
        '🐶',
        toxicity['toxicToDogs'] ? 'Toxic to Dogs' : 'Safe for Dogs',
        toxicity['toxicToDogs'] ? Colors.red : Colors.green,
      ));
    }

    if (toxicity['toxicToHumans'] != null) {
      toxicityItems.add(_ToxicityInfo(
        '👤',
        toxicity['toxicToHumans'] ? 'Toxic to Humans' : 'Safe for Humans',
        toxicity['toxicToHumans'] ? Colors.red : Colors.green,
      ));
    }

    return Column(
      children: toxicityItems
          .map((item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: item.statusColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.statusColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item.statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(item.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        item.label,
                        style: AppTheme.cardTitleStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: item.statusColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: item.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.label.contains('Toxic') && !item.label.contains('Non-') ? 'AVOID' : 'SAFE',
                        style: TextStyle(
                          color: item.statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDetailCard(BuildContext context, dynamic content) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: content is List
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content
                  .map<Widget>((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.toString(),
                                style: AppTheme.cardSubtitleStyle.copyWith(
                                  fontSize: 15,
                                  color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.8),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            )
          : Text(
              content.toString(),
              style: AppTheme.cardSubtitleStyle.copyWith(
                fontSize: 15,
                color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.8),
                height: 1.5,
              ),
            ),
    );
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

  IconData _getIconForTitle(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('characteristic')) return HugeIcons.strokeRoundedFile01;
    if (titleLower.contains('habitat')) return HugeIcons.strokeRoundedMapsSearch;
    if (titleLower.contains('size')) return CupertinoIcons.resize;
    if (titleLower.contains('family')) return CupertinoIcons.tree;
    if (titleLower.contains('description')) return CupertinoIcons.doc_text;
    return CupertinoIcons.info_circle;
  }

  Widget _buildEstimatedPriceRow(BuildContext context, dynamic price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(HugeIcons.strokeRoundedDollarCircle, color: Colors.green[700], size: 18),
        const SizedBox(width: 8),
        Text(
          'Estimated Price:',
          style: AppTheme.labelStyle.copyWith(fontSize: 20, color: Colors.green[800], fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 6),
        Text(
          price.toString(),
          style:
              AppTheme.cardSubtitleStyle.copyWith(fontSize: 22, color: Colors.green[900], fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGroupedInfoSection(BuildContext context, Map<String, dynamic> details) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final groupedKeys = [
      'Characteristics',
      'Uses',
      'Care Difficulty',
      'Common Problems',
      'Propagation',
      'Additional Info',
    ];
    final items = groupedKeys.where((k) => details[k] != null).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Other Information', CupertinoIcons.info),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.7,
          children: items.map((k) => _buildGroupedInfoCard(context, k, details[k])).toList(),
        ),
      ],
    );
  }

  Widget _buildGroupedInfoCard(BuildContext context, String label, dynamic value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.08 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTheme.labelStyle
                .copyWith(fontSize: 13, color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.7)),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              value is List ? value.join(', ') : value.toString(),
              style: AppTheme.cardSubtitleStyle
                  .copyWith(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CareInfo {
  final String emoji;
  final String label;
  final String value;

  _CareInfo(this.emoji, this.label, this.value);
}

class _ToxicityInfo {
  final String emoji;
  final String label;
  final Color statusColor;

  _ToxicityInfo(this.emoji, this.label, this.statusColor);
}
