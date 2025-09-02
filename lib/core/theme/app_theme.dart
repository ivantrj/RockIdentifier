import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Core Palette: Modern, High-Contrast ---
  static const Color darkCharcoal = Color(0xFF1A1A1A);
  static const Color metallicGold = Color(0xFFFFD700);
  static const Color shimmeringSilver = Color(0xFFC0C0C0);
  static const Color nearBlack = Color(0xFF0F0F0F);
  static Color glassColor = Colors.white.withOpacity(0.1);

  // --- Semantic Colors ---
  static const Color successColor = Color(0xFF28A745);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFDC3545);

  // --- Text & UI Colors ---
  static const Color primaryTextColor = Color(0xFFF8F9FA);
  static const Color secondaryTextColor = Color(0xFFADB5BD);
  static const Color subtleBorderColor = Color(0xFF2D2D2D);

  // --- Sizing & Spacing ---
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme.copyWith(
            headlineLarge: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
              letterSpacing: -0.5,
            ),
            titleLarge: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
            titleMedium: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
            bodyLarge: TextStyle(
              fontSize: 16.0,
              color: primaryTextColor.withOpacity(0.9),
              height: 1.5,
            ),
            bodyMedium: TextStyle(
              fontSize: 14.0,
              color: secondaryTextColor,
              height: 1.5,
            ),
            labelLarge: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: darkCharcoal, // For text on buttons
            ),
          ),
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: nearBlack,
      colorScheme: const ColorScheme.dark(
        primary: metallicGold,
        secondary: shimmeringSilver,
        background: nearBlack,
        surface: darkCharcoal,
        onPrimary: darkCharcoal, // Text on gold buttons
        onSecondary: darkCharcoal,
        onBackground: primaryTextColor,
        onSurface: primaryTextColor,
        error: errorColor,
        onError: primaryTextColor,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: darkCharcoal,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
          side: BorderSide(color: subtleBorderColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: metallicGold,
          foregroundColor: darkCharcoal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCharcoal.withOpacity(0.8),
        height: 70,
        indicatorColor: metallicGold,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: darkCharcoal, size: 24.0);
          }
          return const IconThemeData(color: secondaryTextColor, size: 24.0);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final color = states.contains(WidgetState.selected) ? metallicGold : secondaryTextColor;
          return TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            color: color,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: subtleBorderColor,
        thickness: 1,
      ),
    );
  }
}
