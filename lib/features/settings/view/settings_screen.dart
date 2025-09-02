import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:coin_id/core/theme/app_theme.dart';
import 'package:coin_id/core/widgets/section_header.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl, LaunchMode;
import 'package:in_app_review/in_app_review.dart';
import 'package:coin_id/services/cache_service.dart';
import 'package:coin_id/locator.dart';
import 'package:coin_id/services/logging_service.dart';
import 'package:coin_id/services/haptic_service.dart';
import 'package:flutter/cupertino.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          const _HapticFeedbackToggle(),
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
          _buildSettingsItem(
            context: context,
            title: 'Send Feedback',
            icon: Icons.feedback_rounded,
            onTap: () => _launchUrl('mailto:hello.ivantrj@gmail.com?subject=App Feedback'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
            child: SectionHeader(title: 'Storage'),
          ),
          _buildCacheSettingsItem(context),
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCharcoal.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
            ),
            child: Column(
              children: [
                Text(
                  '© ${DateTime.now().year} Coin Identifier',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryTextColor.withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All rights reserved',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.secondaryTextColor,
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
      LoggingService.urlLaunchError(urlString, tag: 'SettingsScreen');
    }
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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Iconsax.arrow_right_3,
                  color: theme.colorScheme.secondary,
                  size: 18.0,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HapticFeedbackToggle extends StatefulWidget {
  const _HapticFeedbackToggle();
  @override
  State<_HapticFeedbackToggle> createState() => _HapticFeedbackToggleState();
}

class _HapticFeedbackToggleState extends State<_HapticFeedbackToggle> {
  bool _enabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await HapticService.instance.loadSetting();
    setState(() {
      _enabled = HapticService.instance.enabled;
      _loading = false;
    });
  }

  Future<void> _toggle(bool value) async {
    await HapticService.instance.setEnabled(value);
    setState(() {
      _enabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkCharcoal,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.subtleBorderColor),
      ),
      child: ListTile(
        leading: Icon(Icons.vibration, size: 28, color: theme.colorScheme.primary),
        title: const Text(
          'Haptic Feedback',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        subtitle: const Text(
          'Vibrate on button taps',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: _loading
            ? const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2))
            : CupertinoSwitch(
                value: _enabled,
                onChanged: _toggle,
                activeColor: theme.colorScheme.primary,
              ),
        onTap: _loading ? null : () => _toggle(!_enabled),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}