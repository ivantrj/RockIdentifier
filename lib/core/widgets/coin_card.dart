import 'dart:io';
import 'package:snake_id/data/models/identified_item.dart';
import 'package:flutter/material.dart';
import 'package:snake_id/core/theme/app_theme.dart';

class SnakeCard extends StatelessWidget {
  final IdentifiedItem item;
  final VoidCallback? onTap;

  const SnakeCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
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
            // Hero image for smooth transition
            Hero(
              tag: 'snake_image_${item.id}',
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.cardBorderRadius),
                    topRight: Radius.circular(AppTheme.cardBorderRadius),
                  ),
                  child: _buildImage(),
                ),
              ),
            ),
            // Snake details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.result, // e.g., "Ball Python"
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle, // e.g., "Python regius, Africa"
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Check if it's an asset path (starts with 'assets/')
    if (item.imagePath.startsWith('assets/')) {
      return Image.asset(
        item.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image, color: Colors.grey),
          );
        },
      );
    } else {
      // It's a file path
      return Image.file(
        File(item.imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image, color: Colors.grey),
          );
        },
      );
    }
  }
}
