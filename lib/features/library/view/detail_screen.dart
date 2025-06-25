import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ai_plant_identifier/data/models/identified_item.dart';
import 'package:ai_plant_identifier/core/theme/app_theme.dart';
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, isDarkMode),
      body: Stack(
        children: [
          // Enhanced background with stronger blur and gradient
          _buildBlurredBackground(context, isDarkMode),
          // Main content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 8),
                // Hero image with improved styling
                _buildHeroImage(context),
                const SizedBox(height: 24),
                // Plant info card with glassmorphism
                _buildPlantInfoCard(context, isDarkMode, wikipediaUrl),
                const SizedBox(height: 20),
                // Care guide section
                if (careGuide != null) _buildCareGuideSection(context, careGuide),
                // Toxicity section
                if (toxicity != null) _buildToxicitySection(context, toxicity),
                const SizedBox(height: 16),
                // Other details with improved cards
                ...details.entries
                    .where((e) => !['Care Guide', 'Toxicity', 'Wikipedia'].contains(e.key))
                    .map((entry) => _buildDetailCard(context, entry.key, entry.value)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: IconButton(
              icon: const Icon(CupertinoIcons.back, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: IconButton(
                icon: const Icon(CupertinoIcons.trash, size: 20),
                onPressed: () => _showDeleteDialog(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlurredBackground(BuildContext context, bool isDarkMode) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Background image
          if (item.imagePath.isNotEmpty && File(item.imagePath).existsSync())
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Image.file(
                  File(item.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          // Enhanced gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode
                      ? [
                          AppTheme.darkBackgroundColor.withOpacity(0.3),
                          AppTheme.darkBackgroundColor.withOpacity(0.7),
                          AppTheme.darkBackgroundColor.withOpacity(0.95),
                        ]
                      : [
                          AppTheme.lightBackgroundColor.withOpacity(0.3),
                          AppTheme.lightBackgroundColor.withOpacity(0.7),
                          AppTheme.lightBackgroundColor.withOpacity(0.95),
                        ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Subtle overlay pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return Hero(
      tag: 'image-${item.id}',
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Main image
              item.imagePath.isNotEmpty && File(item.imagePath).existsSync()
                  ? Image.file(
                      File(item.imagePath),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(CupertinoIcons.photo, size: 48, color: Colors.white70),
                      ),
                    ),
              // Subtle overlay for better text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantInfoCard(BuildContext context, bool isDarkMode, String? wikipediaUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkCardColor.withOpacity(0.8) : AppTheme.lightCardColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Plant name and confidence
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.result,
                            style: AppTheme.pageTitleStyle.copyWith(
                              fontSize: 24,
                              color: Theme.of(context).textTheme.headlineLarge?.color,
                            ),
                          ),
                          if (item.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: AppTheme.cardSubtitleStyle.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).textTheme.titleSmall?.color,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Confidence badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '${(item.confidence * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Wikipedia link
                if (wikipediaUrl != null) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _launchUrl(wikipediaUrl),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
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
                            child: const Text('W',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14,
                                )),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Learn more on Wikipedia',
                            style: AppTheme.labelStyle.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            CupertinoIcons.arrow_up_right,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCareGuideSection(BuildContext context, Map<String, dynamic> careGuide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accentColor, AppTheme.accentColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🌱', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                'Care Guide',
                style: AppTheme.cardTitleStyle.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _CareGuideGrid(careGuide: careGuide),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildToxicitySection(BuildContext context, Map<String, dynamic> toxicity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('⚠️', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                'Safety Information',
                style: AppTheme.cardTitleStyle.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _ToxicityGrid(toxicity: toxicity),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailCard(BuildContext context, String title, dynamic content) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkCardColor.withOpacity(0.7) : AppTheme.lightCardColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getIconForTitle(title),
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTheme.cardTitleStyle.copyWith(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (content is List)
                  ...content.map<Widget>((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                e.toString(),
                                style: AppTheme.cardSubtitleStyle.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                else
                  Text(
                    content.toString(),
                    style: AppTheme.cardSubtitleStyle.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),
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
    if (titleLower.contains('characteristic')) return CupertinoIcons.leaf_arrow_circlepath;
    if (titleLower.contains('habitat')) return CupertinoIcons.map;
    if (titleLower.contains('size')) return CupertinoIcons.resize;
    if (titleLower.contains('family')) return CupertinoIcons.tree;
    if (titleLower.contains('description')) return CupertinoIcons.doc_text;
    return CupertinoIcons.info_circle;
  }
}

class _CareGuideGrid extends StatelessWidget {
  final Map<String, dynamic> careGuide;
  const _CareGuideGrid({required this.careGuide});

  @override
  Widget build(BuildContext context) {
    final items = <_CareItem>[];

    if (careGuide['light'] != null) items.add(_CareItem('☀️', 'Light', careGuide['light']));
    if (careGuide['water'] != null) items.add(_CareItem('💧', 'Water', careGuide['water']));
    if (careGuide['soil'] != null) items.add(_CareItem('🌱', 'Soil', careGuide['soil']));
    if (careGuide['temperature'] != null) items.add(_CareItem('🌡️', 'Temperature', careGuide['temperature']));
    if (careGuide['humidity'] != null) items.add(_CareItem('💦', 'Humidity', careGuide['humidity']));
    if (careGuide['fertilizer'] != null) items.add(_CareItem('🧪', 'Fertilizer', careGuide['fertilizer']));
    if (careGuide['pruning'] != null) items.add(_CareItem('✂️', 'Pruning', careGuide['pruning']));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}

class _CareItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  const _CareItem(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkCardColor.withOpacity(0.7) : AppTheme.lightCardColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: AppTheme.labelStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.labelLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.labelStyle.copyWith(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToxicityGrid extends StatelessWidget {
  final Map<String, dynamic> toxicity;
  const _ToxicityGrid({required this.toxicity});

  @override
  Widget build(BuildContext context) {
    final items = <_ToxicityItem>[];

    // General toxicity
    if (toxicity['toxic'] != null) {
      items.add(_ToxicityItem(
        toxicity['toxic'] ? '☠️' : '✅',
        toxicity['toxic'] ? 'Toxic' : 'Safe',
        toxicity['toxic'] ? Colors.red : Colors.green,
      ));
    }

    // Pet-specific toxicity
    if (toxicity['toxicToCats'] != null) {
      items.add(_ToxicityItem(
        toxicity['toxicToCats'] ? '🐱❌' : '🐱✅',
        toxicity['toxicToCats'] ? 'Toxic to Cats' : 'Safe for Cats',
        toxicity['toxicToCats'] ? Colors.red : Colors.green,
      ));
    }

    if (toxicity['toxicToDogs'] != null) {
      items.add(_ToxicityItem(
        toxicity['toxicToDogs'] ? '🐶❌' : '🐶✅',
        toxicity['toxicToDogs'] ? 'Toxic to Dogs' : 'Safe for Dogs',
        toxicity['toxicToDogs'] ? Colors.red : Colors.green,
      ));
    }

    if (toxicity['toxicToHumans'] != null) {
      items.add(_ToxicityItem(
        toxicity['toxicToHumans'] ? '👤❌' : '👤✅',
        toxicity['toxicToHumans'] ? 'Toxic to Humans' : 'Safe for Humans',
        toxicity['toxicToHumans'] ? Colors.red : Colors.green,
      ));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}

class _ToxicityItem extends StatelessWidget {
  final String emoji;
  final String label;
  final Color statusColor;
  const _ToxicityItem(this.emoji, this.label, this.statusColor);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkCardColor.withOpacity(0.7) : AppTheme.lightCardColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: statusColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTheme.labelStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.labelMedium?.color,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
