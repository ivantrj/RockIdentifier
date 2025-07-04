import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:JewelryID/core/theme/app_theme.dart';
import 'package:JewelryID/core/widgets/section_header.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl, LaunchMode;
import 'package:in_app_review/in_app_review.dart';
import 'package:JewelryID/services/cache_service.dart';
import 'package:JewelryID/locator.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          // App Settings Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
            child: SectionHeader(title: 'App'),
          ),
          _buildSettingsItem(
            context: context,
            title: 'Rate App',
            icon: Icons.star_rate_rounded,
            onTap: () => _rateApp(context),
          ),
          // _buildSettingsItem(
          //   context: context,
          //   title: 'Share App',
          //   icon: Icons.share_rounded,
          //   onTap: () => _shareApp(context),
          // ),
          _buildSettingsItem(
            context: context,
            title: 'Send Feedback',
            icon: Icons.feedback_rounded,
            onTap: () => _launchUrl('mailto:hello.ivantrj@gmail.com?subject=App Feedback'),
          ),

          // Storage Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
            child: SectionHeader(title: 'Storage'),
          ),
          _buildCacheSettingsItem(context),

          // Support Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
            child: SectionHeader(title: 'Support'),
          ),
          _buildSettingsItem(
            context: context,
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_rounded,
            onTap: () => _launchUrl('https://www.ivantrj.com/app-privacy-policy'),
          ),
          _buildSettingsItem(
            context: context,
            title: 'Terms of Service',
            icon: Icons.description_rounded,
            onTap: () => _launchUrl('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
          ),

          // About Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
            child: SectionHeader(title: 'About'),
          ),
          _buildSettingsItem(
            context: context,
            title: 'Version',
            subtitle: '1.0.0',
            icon: Icons.info_rounded,
          ),
          const SizedBox(height: 24),
          _buildAppInfo(context),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: AppTheme.surfaceOverlayOpacity / 2)
                  : Colors.black.withValues(alpha: AppTheme.surfaceOverlayOpacity / 3),
              borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
            ),
            child: Column(
              children: [
                Text(
                  '© ${DateTime.now().year} AI Jewelry Identifier',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All rights reserved',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Error is silently ignored as it's not critical
      debugPrint('Could not launch $urlString');
    }
  }

  void _shareApp(BuildContext context) {
    // You can implement share functionality here
    // For example, using the share_plus package
    // Share.share('Check out this amazing app! https://example.com/app');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality would open here')),
    );
  }

  Future<void> _rateApp(BuildContext context) async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating is not available yet.')),
      );
    }
  }

  Widget _buildCacheSettingsItem(BuildContext context) {
    return FutureBuilder<int>(
      future: locator<CacheService>().getCacheSize(),
      builder: (context, snapshot) {
        final cacheSize = snapshot.data ?? 0;
        final formattedSize = locator<CacheService>().formatCacheSize(cacheSize);

        return _buildSettingsItem(
          context: context,
          title: 'Clear Cache',
          subtitle: 'Cache size: $formattedSize',
          icon: Icons.cleaning_services_rounded,
          onTap: () => _showClearCacheDialog(context),
        );
      },
    );
  }

  Future<void> _showClearCacheDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached AI analysis results. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await locator<CacheService>().clearCache();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    }
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required String title,
    String? subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
      elevation: AppTheme.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        side: BorderSide(
          color: isDarkMode ? AppTheme.darkBorderColor : AppTheme.lightBorderColor,
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                width: AppTheme.iconContainerSize,
                height: AppTheme.iconContainerSize,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppTheme.primaryColor.withValues(alpha: AppTheme.surfaceOverlayOpacity * 2)
                      : AppTheme.primaryColor.withValues(alpha: AppTheme.surfaceOverlayOpacity),
                  borderRadius: BorderRadius.circular(AppTheme.iconContainerBorderRadius),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: AppTheme.iconSize,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Iconsax.arrow_right_3,
                  color: AppTheme.primaryColor,
                  size: 18.0,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
