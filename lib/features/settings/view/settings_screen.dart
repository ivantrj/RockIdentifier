import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:snake_id/core/theme/app_theme.dart';
import 'package:snake_id/locator.dart';
import 'package:snake_id/services/cache_service.dart';
import 'package:snake_id/services/haptic_service.dart';
import 'package:snake_id/services/logging_service.dart';
import 'package:snake_id/services/theme_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'Loading...';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appVersion = 'Unknown';
          _buildNumber = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        // Reduce overall padding, especially vertical
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _buildSettingsGroup(
            context,
            children: [
              const _HapticFeedbackToggle(),
              const _ThemeToggle(),
            ],
          ),
          const SizedBox(height: 12), // Reduced space between groups
          _buildSettingsGroup(
            context,
            children: [
              _buildSettingsItem(
                context,
                icon: Icons.star_rate_rounded,
                title: 'Rate App',
                onTap: () => _rateApp(context),
              ),
              _buildSettingsItem(
                context,
                icon: Icons.feedback_rounded,
                title: 'Send Feedback',
                onTap: () => _launchUrl('mailto:hello.ivantrj@gmail.com?subject=App Feedback'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSettingsGroup(
            context,
            children: [const _CacheSettingsItem()],
          ),
          const SizedBox(height: 12),
          _buildSettingsGroup(
            context,
            children: [
              _buildSettingsItem(
                context,
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                onTap: () => _launchUrl('https://www.ivantrj.com/app-privacy-policy'),
              ),
              _buildSettingsItem(
                context,
                icon: Icons.description_rounded,
                title: 'Terms of Service',
                onTap: () => _launchUrl('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSettingsGroup(
            context,
            children: [
              _buildSettingsItem(
                context,
                icon: Icons.info_rounded,
                title: 'Version',
                subtitle: _buildNumber.isNotEmpty ? '$_appVersion+$_buildNumber' : _appVersion,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    return Container(
      clipBehavior: Clip.antiAlias, // Ensures children conform to rounded corners
      decoration: BoxDecoration(
        color: AppTheme.darkCharcoal,
        borderRadius: BorderRadius.circular(12), // Slightly less rounded for a tighter look
      ),
      // Using a Column with manually interspersed dividers for precise control
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isEven) {
            return children[index ~/ 2];
          } else {
            return Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.subtleBorderColor,
              indent: 56,
            );
          }
        }),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context,
      {required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true, // Makes the ListTile more compact
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Reduced vertical padding
      leading: Icon(icon, color: theme.colorScheme.secondary, size: 22), // Slightly smaller icon
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: subtitle != null ? Text(subtitle, style: theme.textTheme.bodyMedium) : null,
      trailing:
          onTap != null ? const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.secondaryTextColor) : null,
      onTap: onTap,
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
    }
  }
}

// --- Helper Widgets ---

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
    if (mounted) {
      setState(() {
        _enabled = HapticService.instance.enabled;
        _loading = false;
      });
    }
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
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: Icon(Icons.vibration, color: theme.colorScheme.secondary, size: 22),
      title: Text('Haptic Feedback', style: theme.textTheme.bodyLarge),
      trailing: _loading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : CupertinoSwitch(
              value: _enabled,
              onChanged: _toggle,
              activeColor: theme.colorScheme.primary,
            ),
      onTap: _loading ? null : () => _toggle(!_enabled),
    );
  }
}

class _CacheSettingsItem extends StatefulWidget {
  const _CacheSettingsItem();

  @override
  State<_CacheSettingsItem> createState() => _CacheSettingsItemState();
}

class _CacheSettingsItemState extends State<_CacheSettingsItem> {
  String _cacheSize = 'Loading...';

  @override
  void initState() {
    super.initState();
    _getCacheSize();
  }

  Future<void> _getCacheSize() async {
    final size = await locator<CacheService>().getCacheSize();
    if (mounted) {
      setState(() {
        _cacheSize = locator<CacheService>().formatCacheSize(size);
      });
    }
  }

  Future<void> _showClearCacheDialog(BuildContext context) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached AI analysis results. This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await locator<CacheService>().clearCache();
      _getCacheSize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: Icon(Icons.cleaning_services_rounded, color: theme.colorScheme.secondary, size: 22),
      title: Text('Clear Cache', style: theme.textTheme.bodyLarge),
      subtitle: Text(_cacheSize, style: theme.textTheme.bodyMedium),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.secondaryTextColor),
      onTap: () => _showClearCacheDialog(context),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final theme = Theme.of(context);
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          leading: Icon(
            themeService.isLightMode
                ? Icons.light_mode_rounded
                : themeService.isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.brightness_auto_rounded,
            color: theme.colorScheme.secondary,
            size: 22,
          ),
          title: Text('Theme', style: theme.textTheme.bodyLarge),
          subtitle: Text(
            themeService.isLightMode
                ? 'Light'
                : themeService.isDarkMode
                    ? 'Dark'
                    : 'System',
            style: theme.textTheme.bodyMedium,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.secondaryTextColor),
          onTap: () {
            HapticService.instance.vibrate();
            themeService.toggleTheme();
          },
        );
      },
    );
  }
}
