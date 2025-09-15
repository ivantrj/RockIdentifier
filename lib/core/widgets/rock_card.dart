import 'dart:io';
import 'package:rock_id/data/models/identified_item.dart';
import 'package:flutter/material.dart';
import 'package:rock_id/core/theme/app_theme.dart';

class RockCard extends StatelessWidget {
  final IdentifiedItem item;
  final VoidCallback? onTap;

  const RockCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authenticityStatus = item.authenticity ?? item.details['authenticity'] ?? 'unknown';
    final authenticityColor = _getAuthenticityColor(authenticityStatus);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDarkMode ? AppTheme.darkStone : Colors.white,
          boxShadow: [
            BoxShadow(
              color: authenticityColor.withValues(alpha: isDarkMode ? 0.15 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: authenticityColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image with authenticity status overlay
            Hero(
              tag: 'Rock_image_${item.id}',
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: _buildImage(),
                    ),
                  ],
                ),
              ),
            ),
            // Rock details with fixed height for consistency
            Container(
              height: 130, // Fixed height for consistent card sizing
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main title with authenticity indicator
                  Row(
                    children: [
                      // Authenticity status circle
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: authenticityColor,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: authenticityColor.withValues(alpha: 0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Rock name
                      Expanded(
                        child: Text(
                          item.result,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Subtitle - show rock type/classification
                  Text(
                    _getCleanSubtitle(item.subtitle),
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(), // Push confidence to bottom
                  // Only confidence indicator at bottom
                  if (item.confidence > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: authenticityColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(item.confidence * 100).toStringAsFixed(0)}% confidence',
                          style: TextStyle(
                            color: authenticityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  Color _getAuthenticityColor(String? authenticity) {
    if (authenticity == null) return Colors.grey;
    switch (authenticity.toLowerCase()) {
      case 'authentic':
      case 'real':
      case 'genuine':
      case 'natural':
        return Colors.green.shade600;
      case 'synthetic':
      case 'lab-grown':
      case 'man-made':
        return Colors.blue.shade600;
      case 'fake':
      case 'imitation':
      case 'glass':
        return Colors.red.shade600;
      case 'unknown':
      case 'uncertain':
        return Colors.amber.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getCleanSubtitle(String? subtitle) {
    if (subtitle == null || subtitle.isEmpty) {
      return 'Rock classification';
    }

    // Clean up the subtitle to show meaningful information
    String cleanSubtitle = subtitle.trim();

    // If it's a chemical formula (contains numbers and letters), make it more readable
    if (RegExp(r'[A-Z][a-z]?\d*').hasMatch(cleanSubtitle) && cleanSubtitle.length < 20) {
      return 'Mineral composition: $cleanSubtitle';
    }

    // If it's a subgroup or type, make it clearer
    if (cleanSubtitle.toLowerCase().contains('subgroup') ||
        cleanSubtitle.toLowerCase().contains('group') ||
        cleanSubtitle.toLowerCase().contains('type')) {
      return 'Rock type: $cleanSubtitle';
    }

    // If it's a geological term, add context
    if (cleanSubtitle.length > 3 && cleanSubtitle.length < 30) {
      return 'Classification: $cleanSubtitle';
    }

    // Default fallback
    return cleanSubtitle;
  }
}
