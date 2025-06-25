// lib/widgets/buttons/secondary_button.dart
import 'package:flutter/material.dart';
import 'package:ai_plant_identifier/core/theme/app_theme.dart';

class SecondaryButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: isFullWidth ? double.infinity : null,
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
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
            splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            highlightColor: AppTheme.primaryColor.withValues(alpha: 0.05),
            child: Center(
              child: isLoading
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
                        if (icon != null) ...[
                          Icon(icon, size: 18, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
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
    );
  }
}
