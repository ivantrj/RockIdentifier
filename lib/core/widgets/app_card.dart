import 'package:flutter/material.dart';
import 'package:snake_id/services/haptic_service.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? cardColor;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    required this.child,
    this.padding,
    this.onTap,
    this.cardColor,
    this.margin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // This widget now primarily uses the global CardTheme for its styling.
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8.0),
      color: cardColor, // Allows overriding the theme color if needed
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () async {
                await HapticService.instance.vibrate();
                onTap!();
              },
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
