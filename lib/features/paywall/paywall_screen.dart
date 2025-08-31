import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:coin_id/core/theme/app_theme.dart';
import 'package:coin_id/main.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl, LaunchMode;
import 'package:coin_id/services/logging_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Offerings? _offerings;
  Package? _selectedPackage;
  bool _loading = true;
  bool _purchasing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        setState(() {
          _offerings = offerings;
          _selectedPackage = offerings.current!.availablePackages.first;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'No available packages.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load paywall.';
        _loading = false;
      });
    }
  }

  Future<void> _purchase() async {
    if (_selectedPackage == null) return;
    setState(() => _purchasing = true);
    try {
      await Purchases.purchasePackage(_selectedPackage!);

      // Update subscription status in singleton
      try {
        final purchaserInfo = await Purchases.getCustomerInfo();
        RevenueCatService.isSubscribed = purchaserInfo.entitlements.active.isNotEmpty;
      } catch (e) {
        RevenueCatService.isSubscribed = false;
      }

      if (mounted) Navigator.of(context).pop(true); // Close paywall on success
    } catch (e) {
      // Optionally show error
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Error is silently ignored as it's not critical
      LoggingService.urlLaunchError(urlString, tag: 'PaywallScreen');
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await Purchases.restorePurchases();

      // Update subscription status after restore
      try {
        final purchaserInfo = await Purchases.getCustomerInfo();
        RevenueCatService.isSubscribed = purchaserInfo.entitlements.active.isNotEmpty;
      } catch (e) {
        RevenueCatService.isSubscribed = false;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to restore purchases')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = AppTheme.primaryColor;
    final lightPrimary = primaryColor.withValues(alpha: 0.1);

    // Check real-time subscription status
    final isSubscribed = RevenueCatService.isSubscribed;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: isSubscribed
            ? _buildThankYouScreen(primaryColor, lightPrimary)
            : _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)))
                    : Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 120),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 24),
                                  // Pro image from assets
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    // decoration: BoxDecoration(
                                    //   color: lightPrimary,
                                    //   shape: BoxShape.circle,
                                    // ),
                                    child: Image.asset(
                                      'assets/images/pro.png',
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text('Unlimited Access',
                                      style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: theme.textTheme.headlineMedium?.color)),
                                  const SizedBox(height: 18),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32),
                                    child: Column(
                                      children: [
                                        _featureRow(
                                            Icons.camera_alt_rounded, 'Identify unlimited antiques', primaryColor),
                                        _featureRow(Icons.search_rounded, 'Get detailed analysis', primaryColor),
                                        _featureRow(
                                            Icons.menu_book_rounded, 'Access historical information', primaryColor),
                                        _featureRow(Icons.lock_open_rounded, 'Remove usage limits', primaryColor),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  _buildPackages(theme, primaryColor, lightPrimary),
                                  _buildTrialToggle(primaryColor),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: _purchasing ? null : _purchase,
                                      child: _purchasing
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                            )
                                          : Text(_selectedPackage != null &&
                                                  _selectedPackage!.identifier.toLowerCase().contains('week')
                                              ? 'Try for Free'
                                              : 'Subscribe'),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () => _restorePurchases(),
                                      child: Text('Restore', style: TextStyle(color: theme.colorScheme.primary)),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () => _launchUrl(
                                          'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
                                      child: Text('Terms', style: TextStyle(color: theme.colorScheme.primary)),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () => _launchUrl('https://www.ivantrj.com/app-privacy-policy'),
                                      child: Text('Privacy Policy', style: TextStyle(color: theme.colorScheme.primary)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close_rounded, size: 32),
                              color: theme.iconTheme.color?.withValues(alpha: 0.6),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildThankYouScreen(Color primaryColor, Color lightPrimary) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // Pro image from assets
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightPrimary,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/pro.png',
                width: 88,
                height: 88,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Thank You!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.textTheme.headlineLarge?.color),
            ),
            const SizedBox(height: 16),
            Text(
              'You\'re now subscribed to Coin Identifier Pro',
              style: TextStyle(fontSize: 18, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _featureRow(Icons.camera_alt_rounded, 'Unlimited artifact identification', primaryColor),
                  _featureRow(Icons.search_rounded, 'Comprehensive AI analysis', primaryColor),
                  _featureRow(Icons.menu_book_rounded, 'Detailed historical context', primaryColor),
                  _featureRow(Icons.lock_open_rounded, 'Unrestricted access', primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Start Using Pro'),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close_rounded, size: 32),
            color: theme.iconTheme.color?.withValues(alpha: 0.6),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }

  Widget _featureRow(IconData icon, String text, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialToggle(Color primaryColor) {
    final theme = Theme.of(context);
    final packages = _offerings!.current!.availablePackages;
    final yearlyList = packages.where(
      (p) => p.identifier.toLowerCase().contains('annual') || p.storeProduct.title.toLowerCase().contains('annual'),
    );
    final trialWeeklyList = packages.where(
      (p) =>
          p.identifier.toLowerCase().contains('week') ||
          p.storeProduct.title.toLowerCase().contains('week') ||
          (p.storeProduct.introductoryPrice != null),
    );
    final yearly = yearlyList.isNotEmpty ? yearlyList.first : null;
    final trialWeekly = trialWeeklyList.isNotEmpty ? trialWeeklyList.first : null;
    final isTrial = _selectedPackage == trialWeekly;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('Free Trial Enabled',
            style: TextStyle(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
        CupertinoSwitch(
          value: isTrial,
          onChanged: (val) {
            setState(() {
              if (val && trialWeekly != null) {
                _selectedPackage = trialWeekly;
              } else if (!val && yearly != null) {
                _selectedPackage = yearly;
              }
            });
          },
          activeTrackColor: primaryColor,
          inactiveTrackColor: theme.colorScheme.outline.withValues(alpha: 0.5),
          thumbColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildPackages(ThemeData theme, Color primaryColor, Color lightPrimary) {
    final packages = _offerings!.current!.availablePackages;
    final yearlyList = packages.where(
      (p) => p.identifier.toLowerCase().contains('annual') || p.storeProduct.title.toLowerCase().contains('annual'),
    );
    final trialWeeklyList = packages.where(
      (p) =>
          p.identifier.toLowerCase().contains('week') ||
          p.storeProduct.title.toLowerCase().contains('week') ||
          (p.storeProduct.introductoryPrice != null),
    );
    final yearly = yearlyList.isNotEmpty ? yearlyList.first : null;
    final trialWeekly = trialWeeklyList.isNotEmpty ? trialWeeklyList.first : null;
    return Column(
      children: [
        if (yearly != null)
          _packageTile(
            yearly,
            primaryColor,
            lightPrimary,
            selected: _selectedPackage == yearly,
            badge: 'SAVE 80%',
            badgeColor: Colors.red,
            onTap: () => setState(() => _selectedPackage = yearly),
            customTitle: 'Yearly Pro',
            customSubtitle: '${yearly.storeProduct.priceString} per year',
          ),
        if (trialWeekly != null)
          _packageTile(
            trialWeekly,
            primaryColor,
            lightPrimary,
            selected: _selectedPackage == trialWeekly,
            badge: 'FREE',
            badgeColor: primaryColor,
            onTap: () => setState(() => _selectedPackage = trialWeekly),
            customTitle: '3-Day Trial',
            customSubtitle: 'then ${trialWeekly.storeProduct.priceString} per week',
          ),
      ],
    );
  }

  Widget _packageTile(
    Package pkg,
    Color primaryColor,
    Color lightPrimary, {
    required bool selected,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
    String? customTitle,
    String? customSubtitle,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? lightPrimary : theme.cardColor,
          border: Border.all(
              color: selected ? primaryColor : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Radio<Package>(
              value: pkg,
              groupValue: _selectedPackage,
              onChanged: (_) => onTap(),
              activeColor: primaryColor,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        customTitle ?? pkg.storeProduct.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17, color: theme.textTheme.titleLarge?.color),
                      ),
                      const SizedBox(width: 8),
                      if (badge.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: badgeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if ((customSubtitle ?? '').isNotEmpty)
                    Text(
                      customSubtitle!,
                      style: TextStyle(fontSize: 15, color: theme.textTheme.bodyMedium?.color),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
