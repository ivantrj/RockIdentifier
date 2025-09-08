import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snake_id/core/theme/app_theme.dart';

class CoinCardPlaceholder extends StatelessWidget {
  const CoinCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.darkCharcoal,
      highlightColor: AppTheme.darkCharcoal.withOpacity(0.5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          color: AppTheme.darkCharcoal, // Shimmer needs a color to draw on
          border: Border.all(color: AppTheme.subtleBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.cardBorderRadius),
                    topRight: Radius.circular(AppTheme.cardBorderRadius),
                  ),
                  color: Colors.black, // Placeholder color
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
                    color: Colors.black,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: MediaQuery.of(context).size.width * 0.3,
                    color: Colors.black,
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
