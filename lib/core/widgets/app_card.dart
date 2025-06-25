// lib/widgets/containers/app_card.dart
import 'package:flutter/material.dart';
import 'package:template_flutter_mvvm/core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final String? headerTitle;
  final IconData? headerIcon;
  final Color? cardColor;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final bool useBorder;
  final bool useGradient;

  // Default padding value
  static const EdgeInsetsGeometry defaultPadding = EdgeInsets.all(20.0);

  const AppCard({
    required this.child,
    this.padding,
    this.onTap,
    this.headerTitle,
    this.headerIcon,
    this.cardColor,
    this.margin,
    this.elevation,
    this.useBorder = true,
    this.useGradient = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine if we should show a header
    final bool hasHeader = headerTitle != null;
    
    // Use consistent margin regardless of theme
    final EdgeInsetsGeometry cardMargin = margin ?? AppTheme.cardMargin;
    
    return Container(
      margin: cardMargin,
      decoration: BoxDecoration(
        color: cardColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        border: useBorder
            ? Border.all(
                color: isDarkMode ? AppTheme.darkBorderColor : AppTheme.lightBorderColor,
                width: 1.0,
              )
            : null,
        gradient: useGradient
            ? LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? AppTheme.darkShadowColor : AppTheme.lightShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          highlightColor: AppTheme.primaryColor.withValues(alpha: 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Optional header
              if (hasHeader)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      if (headerIcon != null) ...[
                        Icon(
                          headerIcon,
                          size: 20,
                          color: useGradient ? Colors.white : AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        headerTitle!,
                        style: textTheme.titleMedium?.copyWith(
                          color: useGradient ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Main content
              Padding(
                // Use consistent padding regardless of theme
                padding: hasHeader
                    ? const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        top: 8, // Fixed value instead of conditional
                      )
                    : (padding ?? defaultPadding),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
