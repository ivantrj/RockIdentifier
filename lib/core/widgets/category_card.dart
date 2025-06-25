// lib/core/widgets/category_card.dart
import 'package:flutter/material.dart';
import 'package:template_flutter_mvvm/core/theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const CategoryCard({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Adjust background color opacity for dark mode
    final adjustedBackgroundColor = isDarkMode
        ? backgroundColor.withValues(alpha: 0.3) // More subtle in dark mode
        : backgroundColor;
    
    // Icon container colors
    final iconContainerColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.15) // Subtle container in dark mode
        : Colors.white.withValues(alpha: 0.8);
    
    // Icon color
    final iconColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.9) // Bright icon in dark mode
        : const Color(0xFF4A6572); // Original color in light mode
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: adjustedBackgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius / 1.5),
          // Add a subtle border in dark mode
          border: isDarkMode
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1.0,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconContainerColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
