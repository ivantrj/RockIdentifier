import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:rock_id/locator.dart';
import 'package:rock_id/services/cache_service.dart';
import 'package:rock_id/services/haptic_service.dart';
import 'package:rock_id/services/logging_service.dart';
import 'package:rock_id/services/theme_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          _buildSettingsGroup(
            context,
            title: 'Account',
            children: [
              const _HapticFeedbackToggle(),
              const _ThemeToggle(),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsGroup(
            context,
            title: 'Your Account',
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
          const SizedBox(height: 24),
          _buildSettingsGroup(
            context,
            title: 'Support and Legal',
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
          const SizedBox(height: 24),
          _buildSettingsGroup(
            context,
            children: [
              _buildSettingsItem(
                context,
                icon: Icons.cleaning_services_rounded,
                title: 'Clear Cache',
                onTap: () => _showClearCacheDialog(context),
              ),
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

  Widget _buildSettingsGroup(BuildContext context, {String? title, required List<Widget> children}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ),
          Column(
            children: List.generate(children.length * 2 - 1, (index) {
              if (index.isEven) {
                return children[index ~/ 2];
              } else {
                return Divider(
                  height: 1,
                  thickness: 0.5,
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                  indent: title != null ? 56 : 16,
                  endIndent: 16,
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context,
      {required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.secondary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            )
          : null,
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              size: 22,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
            )
          : null,
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
      // Refresh cache size display
      if (mounted) {
        setState(() {});
      }
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
    final isDarkMode = theme.brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.vibration, color: theme.colorScheme.secondary, size: 20),
      ),
      title: Text(
        'Haptic Feedback',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
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

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              themeService.isLightMode
                  ? Icons.light_mode_rounded
                  : themeService.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.brightness_auto_rounded,
              color: theme.colorScheme.secondary,
              size: 20,
            ),
          ),
          title: Text(
            'Theme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            themeService.isLightMode
                ? 'Light'
                : themeService.isDarkMode
                    ? 'Dark'
                    : 'System',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            size: 22,
            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
          ),
          onTap: () {
            HapticService.instance.vibrate();
            themeService.toggleTheme();
          },
        );
      },
    );
  }
}
