import 'dart:math';
import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:snake_id/core/theme/app_theme.dart';

class LoadingDialog extends StatefulWidget {
  const LoadingDialog({super.key});

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  static final List<String> _funTexts = [
    'Scanning Snake surface...',
    'Analyzing mint marks...',
    'Checking for die cracks...',
    'Consulting numismatic databases...',
    'Measuring diameter and weight...',
    'Comparing against catalogs...',
    'Identifying key features...',
    'Analyzing metal composition...',
    'Verifying authenticity...',
    'Cross-referencing dates...',
    'Matching edge lettering...',
    'Evaluating strike quality...',
    'Researching provenance...',
    'Identifying engraver marks...',
    'Analyzing design elements...',
    'Checking overall condition...'
  ];

  late String _currentText;
  late int _textIndex;

  @override
  void initState() {
    super.initState();
    _textIndex = Random().nextInt(_funTexts.length);
    _currentText = _funTexts[_textIndex];

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
  Widget build(BuildContext context) {
    return Dialog(
      // Set the dialog background to transparent to let the blur show through
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            // Use the semi-transparent glass color from our theme
            decoration: BoxDecoration(
              color: AppTheme.glassColor,
              borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
              border: Border.all(color: AppTheme.subtleBorderColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppTheme.emeraldGreen,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    _currentText,
                    key: ValueKey(_currentText),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
