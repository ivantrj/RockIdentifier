import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Core Palette: Geological Rock Theme ---
  // Dark theme colors - Earthy and Stone tones
  static const Color darkStone = Color(0xFF2C2C2E);
  static const Color sandstone = Color(0xFFD2691E); // Warm brown/orange
  static const Color granite = Color(0xFF708090); // Stone gray
  static const Color slate = Color(0xFF2F4F4F); // Dark slate
  static const Color nearBlack = Color(0xFF000000);
  static Color glassColor = Colors.white.withValues(alpha: 0.1);

  // Light theme colors - Warm geological tones
  static const Color lightBackground = Color(0xFFFFFBF7); // Warm off-white
  static const Color lightSurface = Color(0xFFFFFBF7); // Warm off-white
  static const Color lightCard = Color(0xFFFFFFFF); // Pure white for cards
  static const Color lightBorder = Color(0xFFE8DCC0); // Warm beige border
  static const Color lightTextPrimary = Color(0xFF2C2C2E); // Dark stone text
  static const Color lightTextSecondary = Color(0xFF8B7355); // Warm brown secondary

  // --- Semantic Colors ---
  static const Color successColor = Color(0xFF8B7355); // Warm brown success
  static const Color warningColor = Color(0xFFD2691E); // Sandstone warning
  static const Color errorColor = Color(0xFF8B4513); // Saddle brown error

  // --- Text & UI Colors ---
  static const Color primaryTextColor = Color(0xFFF8F9FA);
  static const Color secondaryTextColor = Color(0xFFB0A99F); // Warm stone gray
  static const Color subtleBorderColor = Color(0xFF4A4A4A); // Dark stone border

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
              color: primaryTextColor.withValues(alpha: 0.9),
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
              color: darkStone, // For text on buttons
            ),
          ),
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: nearBlack,
      colorScheme: const ColorScheme.dark(
        primary: sandstone,
        secondary: granite,
        background: nearBlack,
        surface: darkStone,
        onPrimary: nearBlack, // Text on sandstone buttons
        onSecondary: primaryTextColor,
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
        color: darkStone,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
          side: BorderSide(color: subtleBorderColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sandstone,
          foregroundColor: nearBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkStone.withValues(alpha: 0.8),
        height: 70,
        indicatorColor: sandstone,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: nearBlack, size: 24.0);
          }
          return const IconThemeData(color: secondaryTextColor, size: 24.0);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final color = states.contains(WidgetState.selected) ? sandstone : secondaryTextColor;
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
        primary: sandstone,
        secondary: granite,
        background: lightBackground,
        surface: lightSurface,
        onPrimary: Colors.white, // Text on sandstone buttons
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
        shadowColor: sandstone.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
          side: BorderSide(color: lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sandstone,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 3,
          shadowColor: sandstone.withValues(alpha: 0.3),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface.withValues(alpha: 0.9),
        height: 70,
        indicatorColor: sandstone,
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
