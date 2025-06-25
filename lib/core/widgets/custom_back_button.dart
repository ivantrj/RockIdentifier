import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CustomBackButton({
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.appBarTheme.iconTheme?.color;
    final backgroundColor = theme.cardTheme.color;
    final double borderRadius = (theme.cardTheme.shape is RoundedRectangleBorder)
        ? ((theme.cardTheme.shape as RoundedRectangleBorder).borderRadius as BorderRadius? ?? BorderRadius.circular(12.0)).resolve(Directionality.of(context)).topLeft.x // Extract radius
        : 12.0; // Default radius

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: iconColor,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: onPressed ??
              () {
                // Use provided action or default pop
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
