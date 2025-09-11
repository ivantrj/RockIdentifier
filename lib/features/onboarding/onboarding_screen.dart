import 'package:flutter/material.dart';
import 'package:rock_id/core/theme/app_theme.dart';
import 'package:rock_id/services/haptic_service.dart';
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

  // Testimonial data
  final List<Map<String, dynamic>> _testimonials = [
    {
      'image': 'assets/images/testimonial1.jpeg',
      'quote': 'Perfect for geologists',
      'author': 'Geology Professor',
      'rating': 5,
    },
    {
      'image': 'assets/images/testimonial2.jpeg',
      'quote': 'Accurate rock identification',
      'author': 'Mining Engineer',
      'rating': 5,
    },
    {
      'image': 'assets/images/testimonial3.jpeg',
      'quote': 'Essential for field research',
      'author': 'Petrologist',
      'rating': 5,
    },
    {
      'image': 'assets/images/testimonial4.jpeg',
      'quote': 'Best rock app available',
      'author': 'Geology Guide',
      'rating': 5,
    },
    {
      'image': 'assets/images/testimonial5.jpeg',
      'quote': 'Incredible AI technology',
      'author': 'Rock Collector',
      'rating': 5,
    },
  ];

  int _currentTestimonialIndex = 0;

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
          if (mounted) {
            // Move to next testimonial
            setState(() {
              _currentTestimonialIndex = (_currentTestimonialIndex + 1) % _testimonials.length;
            });
            _startTestimonialAnimation();
          }
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
                    color: AppTheme.sandstone.withValues(alpha: 0.03),
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
                    color: AppTheme.sandstone.withValues(alpha: 0.02),
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
                    color: AppTheme.sandstone.withValues(alpha: 0.02),
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
          color: AppTheme.granite.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.granite.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProgressStep(
            icon: Icons.science,
            isActive: _animatedStep >= 0,
            isCompleted: _animatedStep > 0,
          ),
          Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _animatedStep > 0 ? AppTheme.granite : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
                boxShadow: _animatedStep > 0
                    ? [
                        BoxShadow(
                          color: AppTheme.granite.withValues(alpha: 0.3),
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
                color: _animatedStep > 1 ? AppTheme.granite : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
                boxShadow: _animatedStep > 1
                    ? [
                        BoxShadow(
                          color: AppTheme.granite.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
          _buildProgressStep(
            icon: Icons.psychology,
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
          color: isActive ? AppTheme.granite : Colors.white.withValues(alpha: 0.2),
          border: Border.all(
            color: isActive ? AppTheme.granite.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.granite.withValues(alpha: 0.4),
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
                      'Welcome to Rock Identifier',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'The most accurate way to identify rocks and learn about their geological formations, mineral composition, and historical significance. Used by geologists worldwide.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
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
                    // Enhanced title with icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.sandstone.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: AppTheme.granite,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Snap a Photo to Identify Rocks',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Point your camera at any rock and get instant identification with detailed information about mineral composition, geological formation, age, and properties.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Feature highlights
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFeatureChip('Mineral ID', Icons.science_rounded),
                        _buildFeatureChip('Properties', Icons.build_rounded),
                        _buildFeatureChip('Formation', Icons.terrain_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Enhanced photo animation
        _buildEnhancedPhotoAnimation(),

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
                    // Enhanced title with AI icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.sandstone.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.psychology_rounded,
                            color: AppTheme.granite,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Powered by Advanced AI',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Our cutting-edge AI has been trained on millions of rock images to provide the most accurate identification and comprehensive geological information available.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // AI capabilities
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFeatureChip('99.8% Accuracy', Icons.verified_rounded),
                        _buildFeatureChip('Instant Results', Icons.flash_on_rounded),
                        _buildFeatureChip('Geological Database', Icons.explore_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Enhanced AI animation
        _buildEnhancedAIAnimation(),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTestimonial() {
    final currentTestimonial = _testimonials[_currentTestimonialIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.granite.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.granite.withValues(alpha: 0.1),
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
                            color: AppTheme.granite,
                            size: 35,
                          ),
                          const SizedBox(width: 15),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.granite.withValues(alpha: 0.2),
                              border: Border.all(
                                color: AppTheme.granite.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                currentTestimonial['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Icon(
                            Icons.emoji_events,
                            color: AppTheme.granite,
                            size: 35,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentTestimonial['quote'],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '- ${currentTestimonial['author']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          currentTestimonial['rating'],
                          (index) => Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Testimonial indicator dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _testimonials.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentTestimonialIndex
                                  ? AppTheme.granite
                                  : Colors.white.withValues(alpha: 0.3),
                            ),
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

  Widget _buildEnhancedPhotoAnimation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Camera frame
            Container(
              width: 200,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.granite.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: AppTheme.darkStone.withValues(alpha: 0.5),
              ),
            ),

            // Rock image with enhanced styling
            AnimatedBuilder(
              animation: _photoHandOpacity,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_photoHandOpacity.value * 0.1),
                  child: Opacity(
                    opacity: 1.0 - (_photoHandOpacity.value * 0.6),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.granite.withValues(alpha: 0.8),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.granite.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/Rock.jpg', // TODO: Replace with rock image
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Enhanced hand animation
            AnimatedBuilder(
              animation: _photoHandOpacity,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.5 - (_photoHandOpacity.value * 0.5),
                  child: Opacity(
                    opacity: _photoHandOpacity.value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.sandstone.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.touch_app,
                        size: 60,
                        color: AppTheme.granite,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Enhanced flash effect
            AnimatedBuilder(
              animation: _photoFlashOpacity,
              builder: (context, child) {
                return AnimatedOpacity(
                  opacity: _photoFlashOpacity.value,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Enhanced identification result
            AnimatedBuilder(
              animation: _photoIdentifiedOpacity,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -20),
                  child: Opacity(
                    opacity: _photoIdentifiedOpacity.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.sandstone,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.sandstone.withValues(alpha: 0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Rock Identified!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
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

  Widget _buildEnhancedAIAnimation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Neural network background
            Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.granite.withValues(alpha: 0.2),
                  width: 1,
                ),
                color: AppTheme.darkStone.withValues(alpha: 0.3),
              ),
            ),

            // AI brain icon with enhanced pulsing effect
            AnimatedBuilder(
              animation: _aiAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (0.15 * _aiOpacity.value),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.sandstone.withValues(alpha: 0.2),
                      border: Border.all(
                        color: AppTheme.granite.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.granite.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      size: 40,
                      color: AppTheme.granite,
                    ),
                  ),
                );
              },
            ),

            // Enhanced animated dots with connecting lines
            Positioned(
              bottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return AnimatedBuilder(
                    animation: _aiAnimationController,
                    builder: (context, child) {
                      final delay = index * 0.15;
                      final opacity = _aiOpacity.value > delay ? 1.0 : 0.2;
                      final scale = _aiOpacity.value > delay ? 1.0 : 0.5;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.granite.withValues(alpha: opacity),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.granite.withValues(alpha: opacity * 0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),

            // Processing text
            Positioned(
              top: 20,
              child: AnimatedBuilder(
                animation: _aiAnimationController,
                builder: (context, child) {
                  final opacity = _aiOpacity.value > 0.5 ? 1.0 : 0.0;
                  return Opacity(
                    opacity: opacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.sandstone.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Processing...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
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
                backgroundColor: AppTheme.granite,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: AppTheme.granite.withValues(alpha: 0.4),
              ),
              child: Text(
                _step < 2 ? 'Continue' : 'Get Started',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                  color: AppTheme.granite,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _getTrustText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
        return Icons.explore;
      default:
        return Icons.search;
    }
  }

  String _getTrustText() {
    switch (_step) {
      case 0:
        return 'Trusted by geologists worldwide';
      case 1:
        return 'Millions of rocks identified';
      case 2:
        return 'Trained on extensive geological database';
      default:
        return 'Professional-grade technology';
    }
  }

  Widget _buildFeatureChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.sandstone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.granite.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.granite,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: AppTheme.granite,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
