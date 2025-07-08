import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bug_id/data/models/identified_item.dart';
import 'package:bug_id/core/theme/app_theme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bug_id/features/chat/view/chat_screen.dart';
import 'package:bug_id/services/logging_service.dart';

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

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Custom app bar with hero image
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
            leading: Container(
              margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  HugeIcons.strokeRoundedArrowLeft01,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    HugeIcons.strokeRoundedDelete02,
                    size: 20,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    LoggingService.userAction('Delete item button pressed',
                        details: 'itemId: ${item.id}', tag: 'DetailScreen');
                    _showDeleteDialog(context);
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'image-${item.id}',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: Builder(
                    builder: (_) {
                      final exists = item.imagePath.isNotEmpty && File(item.imagePath).existsSync();
                      LoggingService.imageLoad(item.imagePath, exists, tag: 'DetailScreen');
                      return exists
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
                            );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and subtitle section
                    _buildTitleSection(context),
                    const SizedBox(height: 32),

                    // Safety Status - Prominent display
                    _buildSafetyStatus(context, details),
                    const SizedBox(height: 32),

                    // Chat with AI section
                    _buildChatSection(context),
                    const SizedBox(height: 32),

                    // Price section - if available
                    if (price != null) ...[
                      _buildPriceSection(context, price),
                      const SizedBox(height: 32),
                    ],

                    // Key Details section
                    _buildKeyDetailsSection(context, details),
                    const SizedBox(height: 24),

                    // Pest Control section
                    _buildPestControlSection(context, details),
                    const SizedBox(height: 24),

                    // Additional Info section
                    _buildAdditionalInfoSection(context, details),

                    // Wikipedia link
                    if (wikipediaUrl != null) ...[
                      const SizedBox(height: 32),
                      _buildWikipediaLink(context, wikipediaUrl),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.result,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
            height: 1.1,
          ),
        ),
        if (item.subtitle.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            item.subtitle,
            style: TextStyle(
              fontSize: 18,
              color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                HugeIcons.strokeRoundedCheckmarkCircle02,
                color: AppTheme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '${(item.confidence * 100).toStringAsFixed(0)}% Confidence',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyStatus(BuildContext context, Map<String, dynamic> details) {
    final dangerInfo = details['dangerToHumans'];

    if (dangerInfo == null) return const SizedBox.shrink();

    final isDangerous = dangerInfo['dangerous'] == true;
    final symptoms = dangerInfo['symptoms']?.toString() ?? 'No specific symptoms known.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDangerous
              ? [
                  const Color(0xFFFFEBEE),
                  const Color(0xFFFFCDD2),
                ]
              : [
                  const Color(0xFFE8F5E8),
                  const Color(0xFFC8E6C9),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDangerous ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDangerous ? Colors.red : Colors.green).withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDangerous ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isDangerous ? Colors.red : Colors.green).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isDangerous ? Icons.warning_rounded : Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDangerous ? '⚠️ Dangerous to Humans' : '✅ Safe for Humans',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDangerous ? Colors.red[800] : Colors.green[800],
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDangerous ? 'Exercise caution and avoid contact' : 'Generally safe to be around',
                      style: TextStyle(
                        fontSize: 14,
                        color: (isDangerous ? Colors.red[700]! : Colors.green[700]!).withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isDangerous) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.red[700],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Symptoms & Effects',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    symptoms,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[900],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context, dynamic price) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  const Color(0xFF1F1F2E),
                  const Color(0xFF2A2A36),
                ]
              : [
                  const Color(0xFFFAFBFF),
                  const Color(0xFFF0F4FF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700),
                  const Color(0xFFFFA500),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              HugeIcons.strokeRoundedDollarCircle,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Estimated Value',
                      style: TextStyle(
                        fontSize: 14,
                        color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('💎', style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  price.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyDetailsSection(BuildContext context, Map<String, dynamic> details) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final keyDetails = [
      'scientificName',
      'commonName',
      'order',
      'family',
      'characteristics',
      'habitat',
      'behavior',
      'diet',
      'lifeCycle',
      'ecologicalRole',
      'estimatedPrevalence',
    ];

    final validDetails = keyDetails.where((key) {
      final value = details[key];
      final displayValue = value is List ? value.join(', ') : value?.toString() ?? '';
      return value != null && displayValue.isNotEmpty && displayValue.toLowerCase() != 'unknown';
    }).toList();

    if (validDetails.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Key Details', HugeIcons.strokeRoundedDiamond01),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1A24) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: validDetails.asMap().entries.map((entry) {
              final index = entry.key;
              final key = entry.value;
              final isLast = index == validDetails.length - 1;
              return _buildDetailRow(context, key, details[key], isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, dynamic value, bool isLast) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final displayValue = value is List ? value.join(', ') : value.toString();
    final attributeColor = _getColorForAttribute(label);
    final formattedLabel = _formatLabel(label);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: attributeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForAttribute(label),
                  color: attributeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: attributeColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayValue,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 1,
            color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
          ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context, Map<String, dynamic> details) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final infoKeys = ['interestingFacts', 'wikiLink'];

    final validInfo = infoKeys.where((key) {
      final value = details[key];
      final displayValue = value is List ? value.join(', ') : value?.toString() ?? '';
      return value != null && displayValue.isNotEmpty && displayValue.toLowerCase() != 'unknown';
    }).toList();

    if (validInfo.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Additional Information', HugeIcons.strokeRoundedInformationCircle),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1A24) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: validInfo.asMap().entries.map((entry) {
              final index = entry.key;
              final key = entry.value;
              final isLast = index == validInfo.length - 1;
              return _buildInfoCard(context, key, details[key], isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, dynamic value, bool isLast) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final displayValue = value is List ? value.join(', ') : value.toString();
    final attributeColor = _getColorForAttribute(label);
    final formattedLabel = _formatLabel(label);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showInfoModal(context, formattedLabel, displayValue),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: attributeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForAttribute(label),
                      color: attributeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          displayValue.length > 100 ? '${displayValue.substring(0, 100)}...' : displayValue,
                          style: TextStyle(
                            fontSize: 14,
                            color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    HugeIcons.strokeRoundedArrowRight01,
                    color: attributeColor.withValues(alpha: 0.6),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 1,
            color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildWikipediaLink(BuildContext context, String wikipediaUrl) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            LoggingService.userAction('Wikipedia link pressed', details: 'itemId: ${item.id}', tag: 'DetailScreen');
            _launchUrl(wikipediaUrl);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    HugeIcons.strokeRoundedWikipedia,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learn More',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Read more on Wikipedia',
                        style: TextStyle(
                          fontSize: 14,
                          color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.7),
                        ),
                      ),
                    ],
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
      ),
    );
  }

  Widget _buildChatSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(_fadeSlideRoute(
              ChatScreen(item: item),
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chat with AI Expert',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ask questions about identification, behavior, habitat & more',
                        style: TextStyle(
                          fontSize: 14,
                          color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  HugeIcons.strokeRoundedArrowRight01,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildPestControlSection(BuildContext context, Map<String, dynamic> details) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final ecologicalRole = details['ecologicalRole']?.toString().toLowerCase() ?? '';

    // Check if it's a pest
    final isPest =
        ecologicalRole.contains('pest') || ecologicalRole.contains('invasive') || ecologicalRole.contains('harmful');

    if (!isPest) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Pest Control Information', Icons.pest_control_rounded),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1A24) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Control Methods',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 16),
                _buildControlMethod(context, 'Prevention', 'Keep areas clean and sealed'),
                _buildControlMethod(context, 'Natural Methods', 'Use beneficial insects or natural repellents'),
                _buildControlMethod(context, 'Chemical Control', 'Consult with pest control professionals'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.orange[700],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Always consult with pest control professionals for proper identification and treatment methods.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[800],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlMethod(BuildContext context, String title, String description) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String label) {
    // Handle special cases first
    switch (label.toLowerCase()) {
      case 'scientificname':
        return 'Scientific Name';
      case 'commonname':
        return 'Common Name';
      case 'lifecycle':
        return 'Life Cycle';
      case 'ecologicalrole':
        return 'Ecological Role';
      case 'estimatedprevalence':
        return 'Estimated Prevalence';
      case 'interestingfacts':
        return 'Interesting Facts';
      case 'wikilink':
        return 'Wiki Link';
      default:
        // Convert camelCase to Title Case with proper spacing
        String formatted = label.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}');
        if (formatted.isNotEmpty && formatted[0].toLowerCase() == formatted[0]) {
          formatted = formatted[0].toUpperCase() + formatted.substring(1);
        }
        return formatted.trim();
    }
  }

  Color _getColorForAttribute(String label) {
    final l = label.toLowerCase();
    if (l.contains('scientificname')) return const Color(0xFF7C3AED); // Purple - primary color
    if (l.contains('commonname')) return const Color(0xFF059669); // Emerald green
    if (l.contains('order')) return const Color(0xFFDC2626); // Red
    if (l.contains('family')) return const Color(0xFF2563EB); // Blue
    if (l.contains('characteristics')) return const Color(0xFFEA580C); // Orange
    if (l.contains('habitat')) return const Color(0xFF7C2D12); // Brown
    if (l.contains('behavior')) return const Color(0xFF4F46E5); // Indigo
    if (l.contains('diet')) return const Color(0xFF16A34A); // Green
    if (l.contains('lifecycle')) return const Color(0xFF0891B2); // Cyan
    if (l.contains('ecologicalrole')) return const Color(0xFFDB2777); // Pink
    if (l.contains('estimatedprevalence')) return const Color(0xFF9333EA); // Violet
    if (l.contains('interestingfacts')) return const Color(0xFF0891B2); // Cyan
    if (l.contains('wikilink')) return const Color(0xFF2563EB); // Blue
    return const Color(0xFF6B7280); // Gray fallback
  }

  IconData _getIconForAttribute(String label) {
    final l = label.toLowerCase();
    if (l.contains('scientificname')) return Icons.science;
    if (l.contains('commonname')) return Icons.label;
    if (l.contains('order')) return Icons.format_list_numbered;
    if (l.contains('family')) return Icons.family_restroom;
    if (l.contains('characteristics')) return Icons.visibility;
    if (l.contains('habitat')) return Icons.landscape;
    if (l.contains('behavior')) return Icons.psychology;
    if (l.contains('diet')) return Icons.restaurant;
    if (l.contains('lifecycle')) return Icons.repeat;
    if (l.contains('ecologicalrole')) return Icons.eco;
    if (l.contains('estimatedprevalence')) return Icons.trending_up;
    if (l.contains('interestingfacts')) return Icons.lightbulb;
    if (l.contains('wikilink')) return Icons.language;
    return Icons.info;
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
                  color: Colors.black.withValues(alpha: 0.12),
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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.9),
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
}
