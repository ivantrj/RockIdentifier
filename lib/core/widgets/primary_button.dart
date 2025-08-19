// lib/widgets/buttons/primary_button.dart
import 'package:flutter/material.dart';
import 'package:antique_id/core/theme/app_theme.dart';
import 'package:antique_id/services/haptic_service.dart';

class PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isFullWidth;
  final bool isLoading;

  const PrimaryButton({
    required this.onPressed,
    required this.text,
    this.icon,
    this.isFullWidth = true,
    this.isLoading = false,
    super.key,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
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
            color: AppTheme.primaryColor,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: AppTheme.surfaceOverlayOpacity * 2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
              onTap: widget.isLoading ? null : _onTap,
              onTapDown: widget.isLoading ? null : (d) => _onTapDown(d),
              onTapUp: widget.isLoading ? null : (d) => _onTapUp(d),
              onTapCancel: widget.isLoading ? null : _onTapCancel,
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 18, color: Colors.white),
                            const SizedBox(width: 8),
                          ],
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              widget.text,
                              style: AppTheme.buttonTextStyle.copyWith(
                                color: Colors.white,
                              ),
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
