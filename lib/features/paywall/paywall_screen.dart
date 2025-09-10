import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rock_id/main.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl, LaunchMode;
import 'package:rock_id/services/logging_service.dart';

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
      LoggingService.debug('Fetching RevenueCat offerings...', tag: 'PaywallScreen');

      final offerings = await Purchases.getOfferings();
      LoggingService.debug('Offerings received: ${offerings.toString()}', tag: 'PaywallScreen');

      if (offerings.current != null) {
        LoggingService.debug('Current offering: ${offerings.current!.identifier}', tag: 'PaywallScreen');
        LoggingService.debug('Available packages: ${offerings.current!.availablePackages.length}',
            tag: 'PaywallScreen');

        if (offerings.current!.availablePackages.isNotEmpty) {
          // Prioritize package selection: lifetime > yearly > trial/weekly
          final packages = offerings.current!.availablePackages;

          // Look for lifetime package first
          final lifetimeList = packages.where(
            (p) =>
                p.identifier.toLowerCase().contains('lifetime') ||
                p.storeProduct.title.toLowerCase().contains('lifetime') ||
                p.identifier.toLowerCase().contains('forever') ||
                p.storeProduct.title.toLowerCase().contains('forever'),
          );

          // Look for yearly package second
          final yearlyList = packages.where(
            (p) =>
                p.identifier.toLowerCase().contains('annual') || p.storeProduct.title.toLowerCase().contains('annual'),
          );

          // Look for trial/weekly package third
          final trialWeeklyList = packages.where(
            (p) =>
                p.identifier.toLowerCase().contains('week') ||
                p.storeProduct.title.toLowerCase().contains('week') ||
                (p.storeProduct.introductoryPrice != null),
          );

          Package? defaultPackage;
          if (lifetimeList.isNotEmpty) {
            defaultPackage = lifetimeList.first;
          } else if (yearlyList.isNotEmpty) {
            defaultPackage = yearlyList.first;
          } else if (trialWeeklyList.isNotEmpty) {
            defaultPackage = trialWeeklyList.first;
          } else {
            defaultPackage = packages.first; // fallback to first available
          }

          setState(() {
            _offerings = offerings;
            _selectedPackage = defaultPackage;
            _loading = false;
          });
          LoggingService.debug('Paywall loaded successfully with default package: ${defaultPackage.identifier}',
              tag: 'PaywallScreen');
        } else {
          LoggingService.warning('No available packages in current offering', tag: 'PaywallScreen');
          setState(() {
            _error = 'No subscription packages available. Please try again later.';
            _loading = false;
          });
        }
      } else {
        LoggingService.warning('No current offering available', tag: 'PaywallScreen');
        setState(() {
          _error = 'No subscription offerings available. Please try again later.';
          _loading = false;
        });
      }
    } catch (e) {
      LoggingService.error('Failed to fetch RevenueCat offerings', error: e, tag: 'PaywallScreen');
      LoggingService.debug('Error details: ${e.toString()}', tag: 'PaywallScreen');

      String errorMessage = 'Failed to load paywall.';

      // Provide more specific error messages
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('configuration')) {
        errorMessage = 'RevenueCat configuration error. Please contact support.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      }

      setState(() {
        _error = errorMessage;
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

  Widget _buildErrorScreen(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Paywall',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'An unexpected error occurred',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchOfferings,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
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
    final sandstone = theme.colorScheme.primary;
    final lightPrimary = sandstone.withValues(alpha: 0.1);

    // Check real-time subscription status
    final isSubscribed = RevenueCatService.isSubscribed;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: isSubscribed
            ? _buildThankYouScreen(sandstone, lightPrimary)
            : _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorScreen(theme)
                    : Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 200),
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
                                        _featureRow(Icons.camera_alt_rounded, 'Identify unlimited snakes', sandstone),
                                        _featureRow(Icons.search_rounded, 'Get detailed species analysis', sandstone),
                                        _featureRow(
                                            Icons.location_on_rounded, 'Learn habitat & geographic range', sandstone),
                                        _featureRow(Icons.lock_open_rounded, 'Remove usage limits', sandstone),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  _buildPackages(theme, sandstone, lightPrimary),
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
                                        backgroundColor: sandstone,
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
                                _buildTrialToggle(sandstone),
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

  Widget _buildThankYouScreen(Color sandstone, Color lightPrimary) {
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
              'You\'re now subscribed to Snake Identifier Pro',
              style: TextStyle(fontSize: 18, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _featureRow(Icons.camera_alt_rounded, 'Unlimited snake identification', sandstone),
                  _featureRow(Icons.search_rounded, 'Comprehensive species analysis', sandstone),
                  _featureRow(Icons.location_on_rounded, 'Detailed habitat & location info', sandstone),
                  _featureRow(Icons.lock_open_rounded, 'Unrestricted access', sandstone),
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
                    backgroundColor: sandstone,
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

  Widget _buildTrialToggle(Color sandstone) {
    final theme = Theme.of(context);
    final packages = _offerings!.current!.availablePackages;

    // Filter for lifetime packages
    final lifetimeList = packages.where(
      (p) =>
          p.identifier.toLowerCase().contains('lifetime') ||
          p.storeProduct.title.toLowerCase().contains('lifetime') ||
          p.identifier.toLowerCase().contains('forever') ||
          p.storeProduct.title.toLowerCase().contains('forever'),
    );

    // Filter for yearly packages
    final yearlyList = packages.where(
      (p) => p.identifier.toLowerCase().contains('annual') || p.storeProduct.title.toLowerCase().contains('annual'),
    );

    // Filter for trial/weekly packages
    final trialWeeklyList = packages.where(
      (p) =>
          p.identifier.toLowerCase().contains('week') ||
          p.storeProduct.title.toLowerCase().contains('week') ||
          (p.storeProduct.introductoryPrice != null),
    );

    final lifetime = lifetimeList.isNotEmpty ? lifetimeList.first : null;
    final yearly = yearlyList.isNotEmpty ? yearlyList.first : null;
    final trialWeekly = trialWeeklyList.isNotEmpty ? trialWeeklyList.first : null;
    final isTrial = _selectedPackage == trialWeekly;

    // Don't show trial toggle if there's no trial/weekly package available
    if (trialWeekly == null) {
      return const SizedBox.shrink();
    }

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
          activeTrackColor: sandstone,
          inactiveTrackColor: theme.colorScheme.outline.withValues(alpha: 0.5),
          thumbColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildPackages(ThemeData theme, Color sandstone, Color lightPrimary) {
    final packages = _offerings!.current!.availablePackages;

    // Filter for lifetime packages
    final lifetimeList = packages.where(
      (p) =>
          p.identifier.toLowerCase().contains('lifetime') ||
          p.storeProduct.title.toLowerCase().contains('lifetime') ||
          p.identifier.toLowerCase().contains('forever') ||
          p.storeProduct.title.toLowerCase().contains('forever'),
    );

    // Filter for yearly packages
    final yearlyList = packages.where(
      (p) => p.identifier.toLowerCase().contains('annual') || p.storeProduct.title.toLowerCase().contains('annual'),
    );

    // Filter for trial/weekly packages
    final trialWeeklyList = packages.where(
      (p) =>
          p.identifier.toLowerCase().contains('week') ||
          p.storeProduct.title.toLowerCase().contains('week') ||
          (p.storeProduct.introductoryPrice != null),
    );

    final lifetime = lifetimeList.isNotEmpty ? lifetimeList.first : null;
    final yearly = yearlyList.isNotEmpty ? yearlyList.first : null;
    final trialWeekly = trialWeeklyList.isNotEmpty ? trialWeeklyList.first : null;

    return Column(
      children: [
        if (lifetime != null)
          _packageTile(
            lifetime,
            sandstone,
            lightPrimary,
            selected: _selectedPackage == lifetime,
            badge: 'BEST VALUE',
            badgeColor: Colors.green,
            onTap: () => setState(() => _selectedPackage = lifetime),
            customTitle: 'Lifetime Pro',
            customSubtitle: '${lifetime.storeProduct.priceString} one-time payment',
          ),
        if (yearly != null)
          _packageTile(
            yearly,
            sandstone,
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
            sandstone,
            lightPrimary,
            selected: _selectedPackage == trialWeekly,
            badge: 'FREE',
            badgeColor: sandstone,
            onTap: () => setState(() => _selectedPackage = trialWeekly),
            customTitle: '3-Day Trial',
            customSubtitle: 'then ${trialWeekly.storeProduct.priceString} per week',
          ),
      ],
    );
  }

  Widget _packageTile(
    Package pkg,
    Color sandstone,
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
              color: selected ? sandstone : theme.colorScheme.outline.withValues(alpha: 0.3), width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Radio<Package>(
              value: pkg,
              groupValue: _selectedPackage,
              onChanged: (_) => onTap(),
              activeColor: sandstone,
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
