import 'package:flutter/material.dart';
import 'package:coin_id/core/theme/app_theme.dart';
import 'package:coin_id/core/widgets/primary_button.dart';
import 'package:coin_id/services/haptic_service.dart';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({required this.onFinish, super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  int _step = 0;
  int _animatedStep = 0;
  double _onboardingOpacity = 1.0;

  late AnimationController _testimonialController;
  late AnimationController _photoAnimationController;
  late AnimationController _aiAnimationController;

  late Animation<double> _testimonialOpacity;
  late Animation<double> _testimonialScale;
  late Animation<double> _testimonialBlur;
  late Animation<double> _testimonialRotation;

  late Animation<double> _photoHandOpacity;
  late Animation<double> _photoFlashOpacity;
  late Animation<double> _photoIdentifiedOpacity;
  late Animation<double> _photoAllOpacity;

  late Animation<double> _aiOpacity;
  late Animation<Offset> _aiFirstRowPosition;
  late Animation<Offset> _aiSecondRowPosition;
  late Animation<Offset> _aiThirdRowPosition;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Testimonial animations
    _testimonialController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _testimonialOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _testimonialController, curve: Curves.easeInOut),
    );

    _testimonialScale = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(parent: _testimonialController, curve: Curves.easeInOut),
    );

    _testimonialBlur = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _testimonialController, curve: Curves.easeInOut),
    );

    _testimonialRotation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _testimonialController, curve: Curves.easeInOut),
    );

    // Photo animation
    _photoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _photoHandOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _photoAnimationController, curve: Curves.easeInOut),
    );

    _photoFlashOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _photoAnimationController, curve: Curves.easeInOut),
    );

    _photoIdentifiedOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _photoAnimationController, curve: Curves.easeInOut),
    );

    _photoAllOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _photoAnimationController, curve: Curves.easeInOut),
    );

    // AI animation
    _aiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _aiOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _aiAnimationController, curve: Curves.easeInOut),
    );

    _aiFirstRowPosition = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-4, 0),
    ).animate(CurvedAnimation(
      parent: _aiAnimationController,
      curve: const Interval(0.0, 1.0, curve: Curves.linear),
    ));

    _aiSecondRowPosition = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-10, 0),
    ).animate(CurvedAnimation(
      parent: _aiAnimationController,
      curve: const Interval(0.0, 1.0, curve: Curves.linear),
    ));

    _aiThirdRowPosition = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-8, 0),
    ).animate(CurvedAnimation(
      parent: _aiAnimationController,
      curve: const Interval(0.0, 1.0, curve: Curves.linear),
    ));

    // Start testimonial animation
    _startTestimonialAnimation();
  }

  void _startTestimonialAnimation() {
    _testimonialController.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _testimonialController.reverse();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _startTestimonialAnimation();
        });
      }
    });
  }

  void _startPhotoAnimation() {
    // Reset and start the sequence
    _photoAnimationController.reset();

    // Start the sequence
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        // Fade in
        _photoAnimationController.forward();

        // Hand moves in
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            // Flash effect
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                // Show identification result
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (mounted) {
                    // Fade out and restart
                    Future.delayed(const Duration(milliseconds: 2300), () {
                      if (mounted) {
                        _photoAnimationController.reverse();
                        Future.delayed(const Duration(milliseconds: 400), () {
                          if (mounted) _startPhotoAnimation();
                        });
                      }
                    });
                  }
                });
              }
            });
          }
        });
      }
    });
  }

  void _startAIAnimation() {
    _aiAnimationController.reset();
    _aiAnimationController.forward();
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _aiAnimationController.reverse();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _startAIAnimation();
        });
      }
    });
  }

  @override
  void dispose() {
    _testimonialController.dispose();
    _photoAnimationController.dispose();
    _aiAnimationController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    await HapticService.instance.vibrate();

    if (_step == 2) {
      Future.delayed(const Duration(seconds: 1), () {
        widget.onFinish();
      });
    } else {
      setState(() {
        _onboardingOpacity = 0.0;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _step++;
          _animatedStep = _step;
        });

        // Start animations for specific steps
        if (_step == 1) {
          _startPhotoAnimation();
        } else if (_step == 2) {
          _startAIAnimation();
        }

        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _onboardingOpacity = 1.0;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nearBlack,
      body: Stack(
        children: [
          // Header and footer background
          _buildHeaderFooter(),

          // Main content
          Column(
            children: [
              const SizedBox(height: 40),

              // Progress indicator
              _buildProgressIndicator(),

              const SizedBox(height: 20),

              // Content area
              Expanded(
                child: AnimatedOpacity(
                  opacity: _onboardingOpacity,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedSlide(
                    offset: _onboardingOpacity == 1.0 ? Offset.zero : const Offset(0, 0.1),
                    duration: const Duration(milliseconds: 500),
                    child: _buildContent(),
                  ),
                ),
              ),

              // Bottom section
              _buildBottomSection(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderFooter() {
    return Positioned.fill(
      child: Column(
        children: [
          // Header decoration
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.red.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.auto_awesome,
                size: 60,
                color: Colors.red.withValues(alpha: 0.4),
              ),
            ),
          ),

          const Spacer(),

          // Footer decoration
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.red.withValues(alpha: 0.15),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.auto_awesome,
                size: 60,
                color: Colors.red.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        children: [
          _buildProgressStep(
            icon: Icons.bug_report,
            isActive: _animatedStep >= 0,
            isCompleted: _animatedStep > 0,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _animatedStep > 0 ? Colors.red : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          _buildProgressStep(
            icon: Icons.camera_alt,
            isActive: _animatedStep >= 1,
            isCompleted: _animatedStep > 1,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _animatedStep > 1 ? Colors.red : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          _buildProgressStep(
            icon: Icons.auto_awesome,
            isActive: _animatedStep >= 2,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep({required IconData icon, required bool isActive, required bool isCompleted}) {
    return AnimatedScale(
      scale: isActive ? 1.2 : 0.8,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.red : Colors.white.withValues(alpha: 0.3),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_step) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildPhotoStep();
      case 2:
        return _buildAIStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  spacing: 20,
                  children: [
                    Text(
                      'Welcome to Coin Identifier',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'The most accurate and efficient way to identify coins & currency',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildTestimonial(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPhotoStep() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  spacing: 20,
                  children: [
                    Text(
                      'Snap a Photo to Identify Coins & Currency',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Quickly and accurately discover coin details with a single photo. Simply snap and identify!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildPhotoAnimation(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAIStep() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  spacing: 20,
                  children: [
                    Text(
                      'Powered by AI',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Experience the power of AI for instant and accurate coin identification, with detailed historical information',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildAIAnimation(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTestimonial() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: AnimatedBuilder(
          animation: _testimonialController,
          builder: (context, child) {
            return Transform.scale(
              scale: _testimonialScale.value,
              child: Transform.rotate(
                angle: _testimonialRotation.value * math.pi / 180,
                child: Opacity(
                  opacity: _testimonialOpacity.value,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          Icon(
                            Icons.emoji_events,
                            color: Colors.red,
                            size: 45,
                          ),
                          const SizedBox(width: 20),
                          Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withValues(alpha: 0.2),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Such a good app',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Transform.scale(
                            scaleX: -1,
                            child: Icon(
                              Icons.emoji_events,
                              color: Colors.red,
                              size: 45,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhotoAnimation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Coin wireframe
            AnimatedBuilder(
              animation: _photoHandOpacity,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_photoHandOpacity.value * 0.1),
                  child: Opacity(
                    opacity: 1.0 - (_photoHandOpacity.value * 0.6),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/coin.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Hand animation
            AnimatedBuilder(
              animation: _photoHandOpacity,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.5 - (_photoHandOpacity.value * 0.5),
                  child: Opacity(
                    opacity: _photoHandOpacity.value,
                    child: Icon(
                      Icons.touch_app,
                      size: 100,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),

            // Flash effect
            AnimatedBuilder(
              animation: _photoFlashOpacity,
              builder: (context, child) {
                return AnimatedOpacity(
                  opacity: _photoFlashOpacity.value,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                );
              },
            ),

            // Identification result
            AnimatedBuilder(
              animation: _photoIdentifiedOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _photoIdentifiedOpacity.value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Identified!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnimation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Binary code animation
            AnimatedBuilder(
              animation: _aiAnimationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _aiOpacity.value,
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: _aiFirstRowPosition.value * 100,
                        child: Text(
                          '0101010101110000011001110111001001100001011001000110010100100000011101000110111100100000011101000110100001100101001000000111000001110010011001010110110101101001011101010110110100100000011101100110010101110010011100110110100101101111011011100010000001100001011011100110010000100000011101000110',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Transform.translate(
                        offset: _aiSecondRowPosition.value * 100,
                        child: Text(
                          '0101010101110000011001110111001001100001011001000110010100100000011101000110111100100000011101000110100001100101001000000111000001110010011001010110110101101001011101010110110100100000011101100110010101110010',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Transform.translate(
                        offset: _aiThirdRowPosition.value * 100,
                        child: Text(
                          '0010111010101101101001000000111011001100101011100100111001101101001011011110110111000100000011000010110111001100100001000000111010001100001011010110110010100100000011000010111000001101000011011110111010001101111001000000110111101100110001000000111100101101111011101010111001000100000011001100110100',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // AI icon
            Icon(
              Icons.psychology,
              size: 80,
              color: Colors.red.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _step < 2 ? 'Continue' : 'Get Started',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Trust indicators
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Row(
              key: ValueKey(_step),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getTrustIcon(),
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _getTrustText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTrustIcon() {
    switch (_step) {
      case 0:
        return Icons.search;
      case 1:
        return Icons.photo_camera;
      case 2:
        return Icons.bug_report;
      default:
        return Icons.search;
    }
  }

  String _getTrustText() {
    switch (_step) {
      case 0:
        return 'Trusted by 2,536+ Numismatists';
      case 1:
        return 'Over 7,634+ Coins Identified';
      case 2:
        return 'Trained on 1,427,523+ Coin Species';
      default:
        return 'Trusted by Numismatists Worldwide';
    }
  }
}

// Helper extension for Column spacing
extension ColumnSpacing on Column {
  Column spacing(double spacing) {
    return Column(
      children: children.expand((child) => [child, SizedBox(height: spacing)]).toList()..removeLast(),
    );
  }
}
