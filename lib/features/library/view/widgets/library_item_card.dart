import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:antique_id/data/models/identified_item.dart';

class LibraryItemCard extends StatefulWidget {
  final IdentifiedItem item;
  final VoidCallback onTap;
  final bool isJustAdded;
  final VoidCallback? onJustAddedAnimationEnd;

  const LibraryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.isJustAdded = false,
    this.onJustAddedAnimationEnd,
  });

  @override
  State<LibraryItemCard> createState() => _LibraryItemCardState();
}

class _LibraryItemCardState extends State<LibraryItemCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<Color?> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scaleAnim = Tween<double>(begin: 1.35, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _glowAnim = ColorTween(
      begin: Colors.yellow.withValues(alpha: 0.7),
      end: Colors.transparent,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.isJustAdded) {
      print('DEBUG: Animation triggered in initState for ${widget.item.id}');
      _controller.forward().then((_) {
        if (widget.onJustAddedAnimationEnd != null) {
          widget.onJustAddedAnimationEnd!();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant LibraryItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isJustAdded && !oldWidget.isJustAdded) {
      print('DEBUG: Animation triggered in didUpdateWidget for ${widget.item.id}');
      _controller.forward(from: 0).then((_) {
        if (widget.onJustAddedAnimationEnd != null) {
          widget.onJustAddedAnimationEnd!();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exists = widget.item.imagePath.isNotEmpty && File(widget.item.imagePath).existsSync();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isJustAdded ? _scaleAnim.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: widget.isJustAdded && _glowAnim.value != null
                  ? [
                      BoxShadow(
                        color: _glowAnim.value!,
                        blurRadius: 48,
                        spreadRadius: 6,
                      ),
                    ]
                  : [],
            ),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: exists
                  ? Image.file(
                      File(widget.item.imagePath),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),
            // Price badge
            if (_shouldShowPriceBadge())
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _extractPriceRange(widget.item.details['Estimated Price'].toString()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            // Bottom overlay with item details
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.result,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(widget.item.confidence * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.item.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Image not found', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  bool _shouldShowPriceBadge() {
    final price = widget.item.details['Estimated Price'];
    return price != null && price.toString().isNotEmpty && price.toString().toLowerCase() != 'unknown';
  }

  String _extractPriceRange(String priceText) {
    // Extract just the price range from text like "$50-$100 depending on the specific model"
    final priceRegex = RegExp(r'\$[\d,]+(?:-\$[\d,]+)?');
    final match = priceRegex.firstMatch(priceText);
    if (match != null) {
      return match.group(0)!;
    }

    // Try to find USD pattern like "USD 500-1000" and convert to "$500-$1000"
    final usdRegex = RegExp(r'USD\s+([\d,]+(?:-[\d,]+)?)', caseSensitive: false);
    final usdMatch = usdRegex.firstMatch(priceText);
    if (usdMatch != null) {
      final numbers = usdMatch.group(1)!;
      return '\$$numbers';
    }

    // Try to find any price-like pattern
    final anyPriceRegex = RegExp(r'[\d,]+(?:-[\d,]+)?\s*(?:USD|dollars?|bucks?)', caseSensitive: false);
    final anyMatch = anyPriceRegex.firstMatch(priceText);
    if (anyMatch != null) {
      return anyMatch.group(0)!;
    }

    // If no price range found, return first 20 characters
    return priceText.length > 20 ? '${priceText.substring(0, 20)}...' : priceText;
  }
}
