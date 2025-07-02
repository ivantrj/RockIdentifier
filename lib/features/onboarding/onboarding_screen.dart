import 'package:flutter/material.dart';
import 'package:PlantMate/core/theme/app_theme.dart';
import 'package:PlantMate/core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({required this.onFinish, Key? key}) : super(key: key);

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
            'Your AI-powered jewelry companion. Identify, learn, and discover the value of your jewelry with ease.',
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
          'How to Use',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Tap the + button to take or upload a photo of a jewelry item. Get instant identification, details, and price estimates!',
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
            'Are you a jewelry collector, enthusiast, or professional?',
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
            _chip('Professional'),
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
