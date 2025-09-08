import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snake_id/core/theme/app_theme.dart';

class SnakeCardPlaceholder extends StatelessWidget {
  const SnakeCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppTheme.darkCharcoal : AppTheme.lightCard,
      highlightColor: isDarkMode ? AppTheme.darkCharcoal.withOpacity(0.5) : AppTheme.lightCard.withOpacity(0.7),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          color: isDarkMode ? AppTheme.darkCharcoal : AppTheme.lightCard,
          border: Border.all(
            color: isDarkMode ? AppTheme.subtleBorderColor : AppTheme.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.cardBorderRadius),
                    topRight: Radius.circular(AppTheme.cardBorderRadius),
                  ),
                  color: isDarkMode ? Colors.black : Colors.grey[300], // Placeholder color
                ),
              ),
            ),
            // Text placeholders
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: isDarkMode ? Colors.black : Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: MediaQuery.of(context).size.width * 0.3,
                    color: isDarkMode ? Colors.black : Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
