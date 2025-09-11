import 'dart:io';
import 'dart:ui';
import 'package:rock_id/data/models/identified_item.dart';
import 'package:rock_id/features/chat/view/chat_screen.dart';
import 'package:rock_id/services/haptic_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rock_id/core/theme/app_theme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailScreen extends StatefulWidget {
  final IdentifiedItem item;
  final VoidCallback onDelete;
  const ItemDetailScreen({required this.item, required this.onDelete, super.key});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final Map<String, bool> _expandedCards = {
    'Identification': false,
    'Physical Characteristics': false,
    'Habitat & Distribution': false,
    'Additional Information': false,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.nearBlack : AppTheme.lightBackground,
      floatingActionButton: _buildModernFAB(context),
      body: CustomScrollView(
        slivers: [
          _buildModernSliverAppBar(context),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildModernSegmentedControl(context),
                  IndexedStack(
                    index: _selectedTabIndex,
                    children: [
                      _buildModernDetailsTab(context),
                      _buildModernFactsTab(context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFAB(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: null, // Disable hero animation to avoid conflicts
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: isDarkMode ? AppTheme.sandstone : AppTheme.sandstone,
        onPressed: () {
          HapticService.instance.vibrate();
          Navigator.of(context).push(CupertinoPageRoute(
            builder: (_) => ChatScreen(item: widget.item),
          ));
        },
        child: Icon(
          HugeIcons.strokeRoundedChatBot,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildModernSegmentedControl(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      height: 48,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildModernSegment(context, 'Details', 0),
          _buildModernSegment(context, 'Facts', 1),
        ],
      ),
    );
  }

  Widget _buildModernSegment(BuildContext context, String title, int index) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticService.instance.vibrate();
          setState(() => _selectedTabIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? (isDarkMode ? Colors.white : Colors.black) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected
                    ? (isDarkMode ? Colors.black : Colors.white)
                    : (isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 15,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      leading: _buildModernAppBarButton(context, HugeIcons.strokeRoundedArrowLeft01, () => Navigator.pop(context)),
      actions: [
        _buildModernAppBarButton(context, HugeIcons.strokeRoundedDelete02, () => _showDeleteDialog(context)),
        const SizedBox(width: 16),
      ],
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Text(
          widget.item.result,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
            height: 1.2,
            shadows: [
              Shadow(
                offset: const Offset(0, 4),
                blurRadius: 12,
                color: Colors.black.withValues(alpha: 0.8),
              ),
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 6,
                color: Colors.black.withValues(alpha: 0.6),
              ),
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 3,
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'Rock_image_${widget.item.id}',
              child: _buildRockImage(widget.item.imagePath),
            ),
            // Gradient overlay for better text readability
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBarButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticService.instance.vibrate();
                  onPressed();
                },
                borderRadius: BorderRadius.circular(12),
                child: Icon(
                  icon,
                  size: 22,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDetailsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
      child: Column(
        children: [
          // Safety Card - More prominent and modern
          _buildModernSafetyCard(context),
          const SizedBox(height: 16),

          // Information Cards with better visual hierarchy
          _buildModernInfoCard(
            context,
            'Identification',
            HugeIcons.strokeRoundedIdentification,
            {
              'Common Name': widget.item.commonName ?? widget.item.result,
              'Scientific Name': widget.item.scientificName ?? widget.item.subtitle,
              'Family': widget.item.rockType ?? 'N/A',
              'Genus': widget.item.scientificName ?? 'N/A',
              'Confidence': '${(widget.item.confidence * 100).toStringAsFixed(0)}%',
            },
          ),

          _buildModernInfoCard(
            context,
            'Physical Characteristics',
            HugeIcons.strokeRoundedRuler,
            {
              'Average Length': widget.item.density ?? 'N/A',
              'Average Weight': widget.item.hardness ?? 'N/A',
              'Behavior': widget.item.usageInformation ?? 'N/A',
              'Diet': widget.item.usageInformation ?? 'N/A',
            },
          ),

          _buildModernInfoCard(
            context,
            'Location & Habitat',
            HugeIcons.strokeRoundedGlobal,
            {
              'Found In': widget.item.geographicLocation ?? 'N/A',
              'Habitat Type': widget.item.formation ?? 'N/A',
              'Elevation': widget.item.details['elevationRange'] ?? 'N/A',
            },
          ),

          _buildModernInfoCard(
            context,
            'Additional Information',
            HugeIcons.strokeRoundedInformationCircle,
            {
              'Safety Information': widget.item.usageInformation ?? 'N/A',
              'Similar Species': widget.item.similarRocks ?? 'N/A',
              'Interesting Facts': widget.item.interestingFacts ?? 'N/A',
            },
          ),

          // Wiki Link Button with modern design
          if (widget.item.details['wikiLink'] != null) ...[
            const SizedBox(height: 16),
            _buildModernWikiButton(context, widget.item.details['wikiLink']!),
          ],
        ],
      ),
    );
  }

  Widget _buildModernSafetyCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mineralComposition = widget.item.mineralComposition;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getSafetyColor(mineralComposition).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getSafetyIcon(mineralComposition),
                        color: _getSafetyColor(mineralComposition),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Safety Status',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Venomous Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _getSafetyColor(mineralComposition).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getSafetyColor(mineralComposition).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getVenomousDisplayText(mineralComposition),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: _getSafetyColor(mineralComposition),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Safety details
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              _getSafetyExplanation(mineralComposition),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                height: 1.5,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSafetyIcon(String? mineralComposition) {
    if (mineralComposition == null) return HugeIcons.strokeRoundedQuestion;
    switch (mineralComposition.toLowerCase()) {
      case 'venomous':
      case 'highly venomous':
      case 'extremely venomous':
        return HugeIcons.strokeRoundedShieldUser;
      case 'mildly venomous':
      case 'weakly venomous':
        return HugeIcons.strokeRoundedAlertCircle;
      case 'non-venomous':
      case 'harmless':
        return HugeIcons.strokeRoundedShieldUser;
      case 'unknown':
        return HugeIcons.strokeRoundedQuestion;
      default:
        return HugeIcons.strokeRoundedQuestion;
    }
  }

  Widget _buildModernInfoCard(
    BuildContext context,
    String title,
    IconData icon,
    Map<String, String> details,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isExpanded = _expandedCards[title] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title - now clickable
          InkWell(
            onTap: () {
              HapticService.instance.vibrate();
              setState(() {
                _expandedCards[title] = !isExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppTheme.sandstone.withValues(alpha: 0.1)
                          : AppTheme.sandstone.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isDarkMode ? AppTheme.sandstone : AppTheme.sandstone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      HugeIcons.strokeRoundedArrowDown01,
                      size: 18,
                      color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content - animated expand/collapse
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: details.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            entry.key,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Text(
                            entry.value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.black,
                              height: 1.4,
                              fontSize: 14,
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
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildModernWikiButton(BuildContext context, String wikiUrl) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _openWikiLink(wikiUrl),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
          foregroundColor: isDarkMode ? Colors.white : Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDarkMode ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              HugeIcons.strokeRoundedWikipedia,
              size: 20,
              color: isDarkMode ? AppTheme.sandstone : AppTheme.sandstone,
            ),
            const SizedBox(width: 12),
            Text(
              'View on Wikipedia',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFactsTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppTheme.sandstone.withValues(alpha: 0.1)
                        : AppTheme.sandstone.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedLighthouse,
                    size: 20,
                    color: isDarkMode ? AppTheme.sandstone : AppTheme.sandstone,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Interesting Facts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.item.interestingFacts ??
                  widget.item.details['Description'] ??
                  'No additional information available.',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.05,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Keep the existing methods for _buildRockImage, _getSafetyColor, _getSafetyValue, etc.
  Widget _buildRockImage(String imagePath) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Debug logging
    print('Building Rock image with path: $imagePath');
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
          color: isDarkMode ? AppTheme.darkStone : AppTheme.lightCard,
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
            color: isDarkMode ? AppTheme.darkStone : AppTheme.lightCard,
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
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8)
                    ],
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
            color: isDarkMode ? AppTheme.darkStone : AppTheme.lightCard,
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
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8)
                    ],
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

  String _getSafetyExplanation(String? venomousStatus) {
    if (venomousStatus == null) return 'Safety information not available';
    switch (venomousStatus.toLowerCase()) {
      case 'venomous':
      case 'highly venomous':
      case 'extremely venomous':
        return 'DANGER: This Rock is venomous and can be life-threatening. Keep distance and seek immediate medical attention if bitten.';
      case 'mildly venomous':
      case 'weakly venomous':
        return 'CAUTION: This Rock has mild venom. While not typically life-threatening, medical attention is recommended if bitten.';
      case 'non-venomous':
      case 'harmless':
        return 'SAFE: This Rock is non-venomous and poses no venom risk to humans.';
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

  void _showDeleteDialog(BuildContext context) {
    HapticService.instance.vibrate();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Rock'),
        content:
            const Text('Are you sure you want to delete this Rock from your collection? This action cannot be undone.'),
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
