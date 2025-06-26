import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({Key? key}) : super(key: key);

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
      if (mounted) Navigator.of(context).pop(true); // Close paywall on success
    } catch (e) {
      // Optionally show error
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final green = const Color(0xFF1DB954);
    final lightGreen = const Color(0xFFE8F5E9);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 120),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              Icon(HugeIcons.strokeRoundedPlant01, color: green, size: 88),
                              const SizedBox(height: 18),
                              const Text('Unlimited Access',
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 18),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Column(
                                  children: [
                                    _featureRow(Icons.qr_code_scanner_rounded, 'Scan unlimited trees & wood', green),
                                    _featureRow(Icons.search_rounded, 'Get unlimited identifications', green),
                                    _featureRow(Icons.menu_book_rounded, 'Explore detailed wood & tree info', green),
                                    _featureRow(Icons.lock_open_rounded, 'Remove annoying paywalls', green),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              _buildPackages(theme, green, lightGreen),
                              _buildTrialToggle(green),
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
                                    backgroundColor: green,
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
                                  onPressed: () => Purchases.restorePurchases(),
                                  child: const Text('Restore'),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('Terms'),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('Privacy Policy'),
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
                          color: Colors.black54,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialToggle(Color green) {
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
        const Text('Free Trial Enabled', style: TextStyle(fontWeight: FontWeight.w600)),
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
          activeTrackColor: green,
          inactiveTrackColor: Colors.grey,
          thumbColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildPackages(ThemeData theme, Color green, Color lightGreen) {
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
            green,
            lightGreen,
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
            green,
            lightGreen,
            selected: _selectedPackage == trialWeekly,
            badge: 'FREE',
            badgeColor: green,
            onTap: () => setState(() => _selectedPackage = trialWeekly),
            customTitle: '3-Day Trial',
            customSubtitle: 'then ${trialWeekly.storeProduct.priceString} per week',
          ),
      ],
    );
  }

  Widget _packageTile(
    Package pkg,
    Color green,
    Color lightGreen, {
    required bool selected,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
    String? customTitle,
    String? customSubtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? lightGreen : Colors.white,
          border: Border.all(color: selected ? green : Colors.grey.shade300, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Radio<Package>(
              value: pkg,
              groupValue: _selectedPackage,
              onChanged: (_) => onTap(),
              activeColor: green,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        customTitle ?? pkg.storeProduct.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      const SizedBox(width: 8),
                      if (badge.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
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
                      style: const TextStyle(fontSize: 15, color: Colors.black),
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
