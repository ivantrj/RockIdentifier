import 'dart:math';
import 'package:flutter/material.dart';
import 'package:antique_id/core/theme/app_theme.dart';

class LoadingDialog extends StatefulWidget {
  const LoadingDialog({super.key});

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> with SingleTickerProviderStateMixin {
  static final List<String> _funTexts = [
    'Examining the antique...',
    'Analyzing craftsmanship...',
    'Checking historical markers...',
    'Consulting antique databases...',
    'Measuring dimensions...',
    'Comparing with known pieces...',
    'Looking for distinctive features...',
    'Examining materials...',
    'Verifying authenticity...',
    'Studying the period...',
    'Matching characteristics...',
    'Evaluating value...',
    'Researching provenance...',
    'Identifying maker marks...',
    'Analyzing style elements...',
    'Checking condition...'
  ];

  late final AnimationController _controller;
  late final Animation<double> _animation;
  late String _currentText;
  late int _textIndex;

  @override
  void initState() {
    super.initState();
    _textIndex = Random().nextInt(_funTexts.length);
    _currentText = _funTexts[_textIndex];
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _animation =
        Tween<double>(begin: 0.85, end: 1.15).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Change text every 2 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      setState(() {
        _textIndex = (_textIndex + 1) % _funTexts.length;
        _currentText = _funTexts[_textIndex];
      });
      return true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDarkMode ? const Color(0xFF23232B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Icon(
                Icons.history_edu,
                color: AppTheme.primaryColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _currentText,
                key: ValueKey(_currentText),
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}
