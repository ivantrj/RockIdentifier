import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Core Palette: Snake-Inspired Natural Colors ---
  // Dark theme colors
  static const Color darkCharcoal = Color(0xFF1A2E1A);
  static const Color forestGreen = Color(0xFF2D5016);
  static const Color emeraldGreen = Color(0xFF50C878);
  static const Color nearBlack = Color(0xFF0F1B0A);
  static Color glassColor = Colors.white.withValues(alpha: 0.1);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF8FFFE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F8F5);
  static const Color lightBorder = Color(0xFFE8F5E8);
  static const Color lightTextPrimary = Color(0xFF1A2E1A);
  static const Color lightTextSecondary = Color(0xFF4A6741);

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
        primary: forestGreen,
        secondary: emeraldGreen,
        background: nearBlack,
        surface: darkCharcoal,
        onPrimary: primaryTextColor, // Text on green buttons
        onSecondary: nearBlack,
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
          backgroundColor: forestGreen,
          foregroundColor: primaryTextColor,
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
        indicatorColor: forestGreen,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: darkCharcoal, size: 24.0);
          }
          return const IconThemeData(color: secondaryTextColor, size: 24.0);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final color = states.contains(WidgetState.selected) ? emeraldGreen : secondaryTextColor;
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

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData.light().textTheme.copyWith(
            headlineLarge: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
              color: lightTextPrimary,
              letterSpacing: -0.5,
            ),
            titleLarge: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: lightTextPrimary,
            ),
            titleMedium: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: lightTextPrimary,
            ),
            bodyLarge: TextStyle(
              fontSize: 16.0,
              color: lightTextPrimary.withValues(alpha: 0.9),
              height: 1.5,
            ),
            bodyMedium: TextStyle(
              fontSize: 14.0,
              color: lightTextSecondary,
              height: 1.5,
            ),
            labelLarge: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.white, // For text on green buttons
            ),
          ),
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: forestGreen,
        secondary: emeraldGreen,
        background: lightBackground,
        surface: lightSurface,
        onPrimary: Colors.white, // Text on green buttons
        onSecondary: Colors.white,
        onBackground: lightTextPrimary,
        onSurface: lightTextPrimary,
        error: errorColor,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 2,
        shadowColor: forestGreen.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
          side: BorderSide(color: lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 3,
          shadowColor: forestGreen.withValues(alpha: 0.3),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface.withValues(alpha: 0.9),
        height: 70,
        indicatorColor: forestGreen,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white, size: 24.0);
          }
          return const IconThemeData(color: lightTextSecondary, size: 24.0);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final color = states.contains(WidgetState.selected) ? Colors.white : lightTextSecondary;
          return TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            color: color,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: lightBorder,
        thickness: 1,
      ),
    );
  }
}
