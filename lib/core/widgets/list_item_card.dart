// lib/core/widgets/list_item_card.dart
import 'package:flutter/material.dart';
import 'package:JewelryID/core/widgets/app_card.dart';

class ListItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ListItemCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconBackgroundColor,
    this.onTap,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      useBorder: true,
      onTap: onTap,
      // Use fixed padding to ensure consistent sizing
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? Colors.white : const Color(0xFF4A6572),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
