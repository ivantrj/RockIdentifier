import 'dart:io';
import 'package:rock_id/data/models/identified_item.dart';
import 'package:flutter/material.dart';
import 'package:rock_id/core/theme/app_theme.dart';
import 'package:hugeicons/hugeicons.dart';

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
    final authenticityIcon = _getAuthenticityIcon(authenticityStatus);

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
                    // Authenticity status indicator
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: authenticityColor.withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          authenticityIcon,
                          color: authenticityColor,
                          size: 16,
                        ),
                      ),
                    ),
                    // Confidence badge
                    if (item.confidence > 0)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(item.confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Rock details with improved typography
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.result,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Authenticity status text
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: authenticityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getAuthenticityStatusText(authenticityStatus),
                          style: TextStyle(
                            color: authenticityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? AppTheme.secondaryTextColor : AppTheme.lightTextSecondary,
                      fontSize: 13,
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

  IconData _getAuthenticityIcon(String? authenticity) {
    if (authenticity == null) return HugeIcons.strokeRoundedQuestion;
    switch (authenticity.toLowerCase()) {
      case 'authentic':
      case 'real':
      case 'genuine':
      case 'natural':
        return HugeIcons.strokeRoundedShield01;
      case 'synthetic':
      case 'lab-grown':
      case 'man-made':
        return HugeIcons.strokeRoundedSettings01;
      case 'fake':
      case 'imitation':
      case 'glass':
        return HugeIcons.strokeRoundedAlert02;
      case 'unknown':
      case 'uncertain':
        return HugeIcons.strokeRoundedQuestion;
      default:
        return HugeIcons.strokeRoundedQuestion;
    }
  }

  String _getAuthenticityStatusText(String? authenticity) {
    if (authenticity == null) return 'Unknown';
    switch (authenticity.toLowerCase()) {
      case 'authentic':
      case 'real':
      case 'genuine':
      case 'natural':
        return 'Authentic';
      case 'synthetic':
      case 'lab-grown':
      case 'man-made':
        return 'Synthetic';
      case 'fake':
      case 'imitation':
      case 'glass':
        return 'Fake';
      case 'unknown':
      case 'uncertain':
        return 'Unknown';
      default:
        return authenticity;
    }
  }
}
