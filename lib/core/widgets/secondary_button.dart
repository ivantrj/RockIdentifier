// lib/widgets/buttons/secondary_button.dart
import 'package:flutter/material.dart';
import 'package:coin_id/core/theme/app_theme.dart';
import 'package:coin_id/services/haptic_service.dart';

class SecondaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isFullWidth;
  final bool isLoading;

  const SecondaryButton({
    required this.onPressed,
    required this.text,
    this.icon,
    this.isFullWidth = true,
    this.isLoading = false,
    super.key,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.93);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  Future<void> _onTap() async {
    await HapticService.instance.vibrate();
    if (widget.onPressed != null) widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          height: AppTheme.buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
            color: isDarkMode ? AppTheme.darkSurfaceColor : AppTheme.lightSurfaceColor,
            border: Border.all(
              color: isDarkMode ? AppTheme.darkBorderColor : AppTheme.lightBorderColor,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? AppTheme.darkShadowColor : AppTheme.lightShadowColor,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
              splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              highlightColor: AppTheme.primaryColor.withValues(alpha: 0.05),
              onTap: widget.isLoading ? null : _onTap,
              onTapDown: widget.isLoading ? null : (d) => _onTapDown(d),
              onTapUp: widget.isLoading ? null : (d) => _onTapUp(d),
              onTapCancel: widget.isLoading ? null : _onTapCancel,
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 18, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: AppTheme.buttonTextStyle.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
