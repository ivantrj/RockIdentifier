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
    _photoAnimationController.reset();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _photoAnimationController.forward();

        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (mounted) {
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
    Future.delayed(const Duration(seconds: 2), () {
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.nearBlack,
              Color(0xFF1A1A1A),
              AppTheme.nearBlack,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background decorative elements
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.metallicGold.withValues(alpha: 0.03),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.metallicGold.withValues(alpha: 0.02),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.metallicGold.withValues(alpha: 0.02),
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  // Top spacing
                  const SizedBox(height: 20),

                  // Progress indicator
                  _buildProgressIndicator(),

                  const SizedBox(height: 20),

                  // Content area - Flexible to prevent overflow
                  Flexible(
                    child: AnimatedOpacity(
                      opacity: _onboardingOpacity,
                      duration: const Duration(milliseconds: 500),
                      child: _buildContent(),
                    ),
                  ),

                  // Bottom section
                  _buildBottomSection(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.metallicGold.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.metallicGold.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProgressStep(
            icon: Icons.bug_report,
            isActive: _animatedStep >= 0,
            isCompleted: _animatedStep > 0,
          ),
          Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _animatedStep > 0 ? AppTheme.metallicGold : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
                boxShadow: _animatedStep > 0
                    ? [
                        BoxShadow(
                          color: AppTheme.metallicGold.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
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
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _animatedStep > 1 ? AppTheme.metallicGold : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
                boxShadow: _animatedStep > 1
                    ? [
                        BoxShadow(
                          color: AppTheme.metallicGold.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppTheme.metallicGold : Colors.white.withValues(alpha: 0.2),
          border: Border.all(
            color: isActive ? AppTheme.metallicGold.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.metallicGold.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
          size: 18,
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
        // Flexible content area
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      'Welcome to Coin Identifier',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'The most accurate way to identify coins and discover their stories. Used by collectors worldwide.',
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

        // Testimonial
        _buildTestimonial(),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPhotoStep() {
    return Column(
      children: [
        // Flexible content area
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      'Snap a Photo to Identify Coins',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Quickly identify coins with detailed information, market values, and historical context.',
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

        // Photo animation
        _buildPhotoAnimation(),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAIStep() {
    return Column(
      children: [
        // Flexible content area
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      'Powered by AI',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Advanced AI technology trained on millions of coins for accurate identification and detailed information.',
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

        // AI animation
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
          color: Colors.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.metallicGold.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.metallicGold.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: AppTheme.metallicGold,
                            size: 35,
                          ),
                          const SizedBox(width: 15),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.metallicGold.withValues(alpha: 0.2),
                              border: Border.all(
                                color: AppTheme.metallicGold.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/testimonial-face.jpeg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Icon(
                            Icons.emoji_events,
                            color: AppTheme.metallicGold,
                            size: 35,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Great app for collectors',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Coin image
            AnimatedBuilder(
              animation: _photoHandOpacity,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_photoHandOpacity.value * 0.1),
                  child: Opacity(
                    opacity: 1.0 - (_photoHandOpacity.value * 0.6),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.metallicGold.withValues(alpha: 0.5),
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
                      size: 70,
                      color: AppTheme.metallicGold,
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
                    width: 140,
                    height: 140,
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
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI brain icon with pulsing effect
            AnimatedBuilder(
              animation: _aiAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (0.1 * _aiOpacity.value),
                  child: Icon(
                    Icons.psychology,
                    size: 60,
                    color: AppTheme.metallicGold,
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // Simple animated dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _aiAnimationController,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final opacity = _aiOpacity.value > delay ? 1.0 : 0.3;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.metallicGold.withValues(alpha: opacity),
                      ),
                    );
                  },
                );
              }),
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
                backgroundColor: AppTheme.metallicGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: AppTheme.metallicGold.withValues(alpha: 0.4),
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
                  color: AppTheme.metallicGold,
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
        return 'Trusted by collectors worldwide';
      case 1:
        return 'Millions of coins identified';
      case 2:
        return 'Trained on extensive coin database';
      default:
        return 'Professional-grade technology';
    }
  }
}
