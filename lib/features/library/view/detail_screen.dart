import 'dart:io';
import 'dart:ui';
import 'package:snake_id/data/models/identified_item.dart';
import 'package:snake_id/features/chat/view/chat_screen.dart';
import 'package:snake_id/services/haptic_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snake_id/core/theme/app_theme.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.nearBlack : AppTheme.lightBackground,
      // Add a Floating Action Button for the Chat feature
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(
            builder: (_) => ChatScreen(item: widget.item),
          ));
        },
        child: Icon(HugeIcons.strokeRoundedChatBot, color: isDarkMode ? AppTheme.darkCharcoal : AppTheme.lightCard),
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
                    _buildFactsTab(context),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCharcoal : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
      ),
      child: Row(
        children: [
          _buildSegment(context, 'Details', 0),
          _buildSegment(context, 'Facts', 1),
        ],
      ),
    );
  }

  Widget _buildSegment(BuildContext context, String title, int index) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
              color: isSelected
                  ? (isDarkMode ? AppTheme.darkCharcoal : AppTheme.lightCard)
                  : (isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary),
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: isDarkMode ? AppTheme.darkCharcoal : AppTheme.lightCard,
      leading: _buildAppBarButton(context, HugeIcons.strokeRoundedArrowLeft01, () => Navigator.pop(context)),
      actions: [
        _buildAppBarButton(context, HugeIcons.strokeRoundedDelete02, () => _showDeleteDialog(context)),
        const SizedBox(width: 16),
      ],
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        centerTitle: true,
        title: Text(widget.item.result,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.8),
                ),
              ],
            ),
            textAlign: TextAlign.center),
        background: Hero(
          tag: 'snake_image_${widget.item.id}',
          child: _buildSnakeImage(widget.item.imagePath),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Safety & Conservation Section - Prominently displayed
          _buildSafetyCard(context),
          const SizedBox(height: 16),

          _buildDetailCard(context, '🐍 Identification', {
            'Common Name': widget.item.commonName ?? widget.item.result,
            'Scientific Name': widget.item.scientificName ?? widget.item.subtitle,
            'Family': widget.item.family ?? 'N/A',
            'Genus': widget.item.genus ?? 'N/A',
            'Confidence': '${(widget.item.confidence * 100).toStringAsFixed(0)}%',
          }),
          const SizedBox(height: 16),

          _buildDetailCard(context, '📏 Physical Characteristics', {
            'Average Length': widget.item.averageLength ?? 'N/A',
            'Average Weight': widget.item.averageWeight ?? 'N/A',
            'Behavior': widget.item.behavior ?? 'N/A',
            'Diet': widget.item.diet ?? 'N/A',
          }),
          const SizedBox(height: 16),

          _buildDetailCard(context, '🌍 Habitat & Distribution', {
            'Habitat': widget.item.habitat ?? 'N/A',
            'Geographic Range': widget.item.geographicRange ?? 'N/A',
            'Conservation Status': widget.item.conservationStatus ?? 'N/A',
          }),
          const SizedBox(height: 16),

          _buildDetailCard(context, 'ℹ️ Additional Information', {
            'Safety Information': widget.item.safetyInformation ?? 'N/A',
            'Similar Species': widget.item.similarSpecies ?? 'N/A',
            'Interesting Facts': widget.item.interestingFacts ?? 'N/A',
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

  Widget _buildSafetyCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final venomousStatus = widget.item.venomousStatus;
    final safetyInfo = widget.item.safetyInformation;
    final conservationStatus = widget.item.conservationStatus;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Venomous Status - Large and prominent
          if (venomousStatus != null) ...[
            Text(
              'Venomous Status',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getSafetyColor(venomousStatus).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getSafetyColor(venomousStatus),
                  width: 2,
                ),
              ),
              child: Text(
                _getVenomousDisplayText(venomousStatus),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: _getSafetyColor(venomousStatus),
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Safety Level with visual indicator
          if (venomousStatus != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Safety Level',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSafetyColor(venomousStatus).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getSafetyColor(venomousStatus).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getSafetyLevel(venomousStatus),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _getSafetyColor(venomousStatus),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Safety slider with clear labels
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  // Background bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Colored progress bar
                  Container(
                    height: 8,
                    width: MediaQuery.of(context).size.width * 0.6 * (_getSafetyValue(venomousStatus) / 100),
                    decoration: BoxDecoration(
                      color: _getSafetyColor(venomousStatus),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Safety indicator dot
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.6 * (_getSafetyValue(venomousStatus) / 100) - 4,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getSafetyColor(venomousStatus),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode ? Colors.white : Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Clear safety explanation
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _getSafetyExplanation(venomousStatus),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Conservation Status and Safety Info
          Row(
            children: [
              if (conservationStatus != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conservation Status',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        conservationStatus,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (safetyInfo != null && safetyInfo.length > 50) ...[
                if (conservationStatus != null) const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Safety Info',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'See details below',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDarkMode ? Colors.white : Colors.black87,
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

  Color _getSafetyColor(String? venomousStatus) {
    if (venomousStatus == null) return Colors.grey;
    switch (venomousStatus.toLowerCase()) {
      case 'venomous':
      case 'highly venomous':
      case 'extremely venomous':
        return Colors.red;
      case 'mildly venomous':
      case 'weakly venomous':
        return Colors.orange;
      case 'non-venomous':
      case 'harmless':
        return Colors.green;
      case 'unknown':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  int _getSafetyValue(String? venomousStatus) {
    if (venomousStatus == null) return 0;
    switch (venomousStatus.toLowerCase()) {
      case 'venomous':
      case 'highly venomous':
      case 'extremely venomous':
        return 90;
      case 'mildly venomous':
      case 'weakly venomous':
        return 60;
      case 'non-venomous':
      case 'harmless':
        return 20;
      case 'unknown':
        return 50;
      default:
        return 0;
    }
  }

  String _getSafetyLevel(String? venomousStatus) {
    if (venomousStatus == null) return 'Unknown';
    switch (venomousStatus.toLowerCase()) {
      case 'venomous':
      case 'highly venomous':
      case 'extremely venomous':
        return 'High Risk';
      case 'mildly venomous':
      case 'weakly venomous':
        return 'Medium Risk';
      case 'non-venomous':
      case 'harmless':
        return 'Low Risk';
      case 'unknown':
        return 'Unknown Risk';
      default:
        return 'Unknown';
    }
  }

  String _getSafetyExplanation(String? venomousStatus) {
    if (venomousStatus == null) return 'Safety information not available';
    switch (venomousStatus.toLowerCase()) {
      case 'venomous':
      case 'highly venomous':
      case 'extremely venomous':
        return 'DANGER: This snake is venomous and can be life-threatening. Keep distance and seek immediate medical attention if bitten.';
      case 'mildly venomous':
      case 'weakly venomous':
        return 'CAUTION: This snake has mild venom. While not typically life-threatening, medical attention is recommended if bitten.';
      case 'non-venomous':
      case 'harmless':
        return 'SAFE: This snake is non-venomous and poses no venom risk to humans.';
      case 'unknown':
        return 'UNKNOWN: Venom status is unclear. Exercise caution and avoid handling.';
      default:
        return 'Safety information not available.';
    }
  }

  String _getVenomousDisplayText(String? venomousStatus) {
    if (venomousStatus == null) return 'Unknown';
    switch (venomousStatus.toLowerCase()) {
      case 'venomous':
        return '⚠️ VENOMOUS';
      case 'highly venomous':
        return '🚨 HIGHLY VENOMOUS';
      case 'extremely venomous':
        return '☠️ EXTREMELY VENOMOUS';
      case 'mildly venomous':
        return '⚡ MILDY VENOMOUS';
      case 'weakly venomous':
        return '⚡ WEAKLY VENOMOUS';
      case 'non-venomous':
        return '✅ NON-VENOMOUS';
      case 'harmless':
        return '✅ HARMLESS';
      case 'unknown':
        return '❓ UNKNOWN';
      default:
        return venomousStatus.toUpperCase();
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
          color: AppTheme.emeraldGreen,
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

  Widget _buildSnakeImage(String imagePath) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Debug logging
    print('Building Snake image with path: $imagePath');
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
          color: isDarkMode ? AppTheme.darkCharcoal : AppTheme.lightCard,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'Image not found',
                style: TextStyle(color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                'Path: ${imagePath.split('/').last}',
                style: TextStyle(
                  color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
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
            color: isDarkMode ? AppTheme.darkCharcoal : AppTheme.lightCard,
            child: Icon(
              Icons.image_not_supported,
              color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
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
            color: isDarkMode ? AppTheme.darkCharcoal : AppTheme.lightCard,
            child: Icon(
              Icons.image_not_supported,
              color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
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

  Widget _buildFactsTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkCharcoal : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        ),
        child: Text(
          widget.item.interestingFacts ?? widget.item.details['Description'] ?? 'No additional information available.',
          style: theme.textTheme.bodyLarge
              ?.copyWith(height: 1.6, color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary),
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String title, Map<String, String> details) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCharcoal : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppTheme.subtleBorderColor : AppTheme.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.forestGreen.withOpacity(0.1) : AppTheme.forestGreen.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: details.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                icon,
                size: 22,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
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
        title: const Text('Delete Snake'),
        content: const Text(
            'Are you sure you want to delete this snake from your collection? This action cannot be undone.'),
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
