import 'package:flutter/material.dart';
import 'package:antique_id/core/theme/app_theme.dart';
import 'package:antique_id/core/widgets/primary_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:antique_id/services/haptic_service.dart';

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
    final pages = [
      _buildIdentificationPage(context),
      _buildExpertChatPage(context),
      _buildValueAssessmentPage(context),
    ];
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
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
                          color: _page == i ? AppTheme.primaryColor : Colors.grey[300],
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
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Trusted by 1000+ collectors',
                    style: TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentificationPage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/onboarding/onboarding_1.svg', height: 200),
        const SizedBox(height: 32),
        const Text(
          'Instant Antique Identification',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Take a photo of any antique or artifact and get instant identification with detailed information about its period, style, and origin.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildExpertChatPage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/onboarding/onboarding_2.svg', height: 200),
        const SizedBox(height: 32),
        const Text(
          'Expert Appraisal & History',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Chat with our AI expert to learn about the historical significance, estimated value, and fascinating stories behind your antiques.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildValueAssessmentPage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/onboarding/onboarding_3.svg', height: 200),
        const SizedBox(height: 32),
        const Text(
          'Value Assessment & Care Tips',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Get professional value estimates and expert care instructions to preserve your antiques for future generations.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
