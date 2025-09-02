import 'package:flutter/material.dart';
import 'package:coin_id/core/theme/app_theme.dart';
import 'package:coin_id/core/widgets/primary_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:coin_id/services/haptic_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({required this.onFinish, super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  void _next() {
    if (_page < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease);
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = [
      _buildPage(
        context,
        imageAsset: 'assets/onboarding/onboarding_1.svg',
        title: 'Instant Coin Identification',
        subtitle: 'Snap a photo of any coin to get detailed information, including its origin, history, and mintage.',
      ),
      _buildPage(
        context,
        imageAsset: 'assets/onboarding/onboarding_2.svg',
        title: 'Build Your Digital Collection',
        subtitle: 'Automatically save every identified coin to your personal collection. Track and manage your discoveries with ease.',
      ),
      _buildPage(
        context,
        imageAsset: 'assets/onboarding/onboarding_3.svg',
        title: 'Valuation & Expert Insights',
        subtitle: 'Receive up-to-date value assessments and learn fascinating details about your coins from our AI expert.',
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.nearBlack,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _page == i ? theme.colorScheme.primary : AppTheme.subtleBorderColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: _page < 2 ? 'Continue' : 'Get Started',
                    onPressed: () async {
                      await HapticService.instance.vibrate();
                      _next();
                    },
                    fullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Trusted by numismatists worldwide',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, {required String imageAsset, required String title, required String subtitle}) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(imageAsset, height: 200),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            title,
            style: theme.textTheme.headlineLarge?.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            subtitle,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}