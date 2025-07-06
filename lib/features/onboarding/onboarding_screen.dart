import 'package:flutter/material.dart';
import 'package:jewelry_id/core/theme/app_theme.dart';
import 'package:jewelry_id/core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({required this.onFinish, super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;
  String? _experience;

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
      _buildWelcomePage(context),
      _buildHowToPage(context),
      _buildQuestionPage(context),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                  PrimaryButton(
                    text: _page < 2 ? 'Next' : 'Get Started',
                    onPressed: _page == 2 && _experience == null ? null : _next,
                    isFullWidth: false,
                    // Use a visible color for onboarding
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/icon/icon.png', width: 120, height: 120),
        const SizedBox(height: 32),
        const Text(
          'Welcome to JewelMate!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Your AI-powered jewelry expert. Instantly identify, value, and learn about any jewelry piece using just your phone. Discover hidden value, make smarter decisions, and become your own jewelry expert—powered by advanced artificial intelligence.',
            style: TextStyle(fontSize: 18, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildHowToPage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt_rounded, size: 90, color: AppTheme.primaryColor),
        const SizedBox(height: 32),
        const Text(
          'How It Works',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Snap or upload a photo of your jewelry. Our AI analyzes every detail—materials, gemstones, brand, and more—to give you instant identification, value, and expert insights. It\'s like having a personal jeweler in your pocket.',
            style: TextStyle(fontSize: 18, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionPage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.diamond_rounded, size: 90, color: AppTheme.primaryColor),
        const SizedBox(height: 32),
        const Text(
          'Let\'s Get to Know You',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Are you a collector, enthusiast, or just curious? JewelMate adapts to your needs—whether you want to discover, sell, insure, or simply learn more about your jewelry.',
            style: TextStyle(fontSize: 18, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chip('Collector'),
            const SizedBox(width: 12),
            _chip('Enthusiast'),
            const SizedBox(width: 12),
            _chip('Curious'),
          ],
        ),
      ],
    );
  }

  Widget _chip(String label) {
    final isSelected = _experience == label;
    return GestureDetector(
      onTap: () => setState(() => _experience = label),
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? AppTheme.primaryColor : Colors.amber[100],
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.amber[900],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
    );
  }
}
