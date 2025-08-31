// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Sophisticated, museum-inspired color palette for antique identification
  static const Color primaryColor = Color(0xFF2C3E50); // Deep charcoal blue - primary
  static const Color secondaryColor = Color(0xFF8B7355); // Warm bronze - secondary
  static const Color accentColor = Color(0xFFD4AF37); // Elegant gold - accent
  static const Color tertiaryColor = Color(0xFF34495E); // Dark slate - tertiary

  // Neutral palette
  static const Color neutral100 = Color(0xFFF8F9FA); // Lightest neutral
  static const Color neutral200 = Color(0xFFE9ECEF); // Light neutral
  static const Color neutral300 = Color(0xFFDEE2E6); // Medium light neutral
  static const Color neutral400 = Color(0xFFCED4DA); // Medium neutral
  static const Color neutral500 = Color(0xFFADB5BD); // Medium dark neutral
  static const Color neutral600 = Color(0xFF6C757D); // Dark neutral
  static const Color neutral700 = Color(0xFF495057); // Darker neutral
  static const Color neutral800 = Color(0xFF343A40); // Very dark neutral
  static const Color neutral900 = Color(0xFF212529); // Darkest neutral

  // Semantic colors
  static const Color successColor = Color(0xFF28A745); // Professional green
  static const Color warningColor = Color(0xFFFFC107); // Muted amber
  static const Color errorColor = Color(0xFFDC3545); // Professional red
  static const Color infoColor = Color(0xFF17A2B8); // Professional blue

  // UI element colors - light mode
  static const Color lightSurfaceColor = Colors.white;
  static const Color lightBackgroundColor = Color(0xFFFAFBFC); // Slightly off-white
  static const Color lightCardColor = Colors.white;
  static const Color lightBorderColor = Color(0xFFE9ECEF); // Subtle border

  // UI element colors - dark mode
  static const Color darkSurfaceColor = Color(0xFF1A1A1A); // Deep charcoal
  static const Color darkBackgroundColor = Color(0xFF0F0F0F); // Near black
  static const Color darkCardColor = Color(0xFF1E1E1E); // Dark card
  static const Color darkBorderColor = Color(0xFF2D2D2D); // Subtle dark border

  // Text colors
  static const Color _lightTextColor = Color(0xFF212529); // Professional dark
  static const Color _darkTextColor = Color(0xFFF8F9FA); // Professional light

  // Shadow colors
  static Color lightShadowColor = Colors.black.withValues(alpha: 0.08);
  static Color darkShadowColor = Colors.black.withValues(alpha: 0.25);

  // Opacity values for consistent usage
  static const double emphasisHighOpacity = 1.0;
  static const double emphasisMediumOpacity = 0.8;
  static const double emphasisLowOpacity = 0.6;
  static const double emphasisDisabledOpacity = 0.38;
  static const double surfaceOverlayOpacity = 0.08;
  static const double borderOpacity = 0.12;

  // UI element colors
  static const Color lightUnselectedItemColor = Color(0xFF6C757D);
  static final Color _darkUnselectedItemColor = Color(0xFF495057);
  static final Color _lightInputBorderColor = Color(0xFFDEE2E6);
  static final Color _darkInputBorderColor = Color(0xFF495057);

  // Shadows and transparent colors
  static final Color _shadowColor = primaryColor.withValues(alpha: 0.12);

  // Navigation
  static const TextStyle _navLabelBaseStyle = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // --- Component Constants ---
  // Button constants - more refined
  static const double buttonHeight = 48.0;
  static const double buttonBorderRadius = 8.0; // Subtle rounding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 12, horizontal: 24);

  // Card constants - more professional
  static const double cardBorderRadius = 12.0; // Subtle rounding
  static const double cardElevation = 1.0; // Subtle elevation
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);

  // Icon container constants
  static const double iconContainerSize = 40.0;
  static const double iconContainerBorderRadius = 8.0;
  static const double iconSize = 18.0;

  // Base button text style - more refined
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // --- Text Styles - Professional Typography ---
  static const TextStyle pageTitleStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.2,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.3,
  );

  static const TextStyle cardSubtitleStyle = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.2,
  );

  static const TextStyle tabLabelStyle = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: lightSurfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: _lightTextColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: lightBackgroundColor,
      cardColor: lightCardColor,
      cardTheme: CardThemeData(
        color: lightCardColor,
        elevation: cardElevation,
        shadowColor: lightShadowColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
          side: BorderSide(color: lightBorderColor, width: 1),
        ),
        margin: cardMargin,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: _lightTextColor),
        titleTextStyle: pageTitleStyle.copyWith(
          color: _lightTextColor,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        toolbarHeight: 56, // Standard height
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: TextTheme(
        headlineLarge: pageTitleStyle.copyWith(color: _lightTextColor),
        titleMedium: cardTitleStyle.copyWith(color: _lightTextColor),
        titleSmall: cardSubtitleStyle.copyWith(color: _lightTextColor.withValues(alpha: 0.7)),
        bodyMedium: TextStyle(
          fontSize: 14.0,
          height: 1.5,
          color: _lightTextColor.withValues(alpha: 0.8),
          letterSpacing: 0.2,
        ),
        bodySmall: TextStyle(
          fontSize: 12.0,
          height: 1.4,
          color: _lightTextColor.withValues(alpha: 0.6),
          letterSpacing: 0.1,
        ),
        labelSmall: labelStyle.copyWith(color: _lightTextColor.withValues(alpha: 0.5)),
        labelMedium: labelStyle.copyWith(color: _lightTextColor.withValues(alpha: 0.7)),
        labelLarge: tabLabelStyle.copyWith(color: _lightTextColor),
      ).apply(
        bodyColor: _lightTextColor.withValues(alpha: 0.8),
        displayColor: _lightTextColor,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightCardColor,
        elevation: 2.0,
        shadowColor: _shadowColor,
        height: 64,
        indicatorColor: primaryColor.withValues(alpha: 0.08),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((Set<WidgetState> states) {
          final Color iconColor = states.contains(WidgetState.selected) ? primaryColor : lightUnselectedItemColor;
          return IconThemeData(color: iconColor, size: 20.0);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) {
          final Color textColor = states.contains(WidgetState.selected) ? primaryColor : lightUnselectedItemColor;
          return _navLabelBaseStyle.copyWith(color: textColor);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Input decoration theme for text fields
      inputDecorationTheme: InputDecorationTheme(
        fillColor: lightSurfaceColor,
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _lightInputBorderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _lightInputBorderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor, width: 1.0),
        ),
        labelStyle: labelStyle.copyWith(color: _lightTextColor.withValues(alpha: 0.6)),
        hintStyle: labelStyle.copyWith(color: _lightTextColor.withValues(alpha: 0.4)),
        prefixIconColor: lightUnselectedItemColor,
        suffixIconColor: lightUnselectedItemColor,
      ),

      // Other component themes
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: lightUnselectedItemColor),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return Colors.transparent;
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return lightUnselectedItemColor.withValues(alpha: 0.3);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      dividerTheme: DividerThemeData(
        color: _lightInputBorderColor,
        thickness: 1,
        space: 24,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: darkSurfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: _darkTextColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkCardColor,
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 0,
        shadowColor: _shadowColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
          side: BorderSide(color: _darkInputBorderColor, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: _darkTextColor),
        titleTextStyle: pageTitleStyle.copyWith(
          color: _darkTextColor,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 56,
      ),
      textTheme: TextTheme(
        headlineLarge: pageTitleStyle.copyWith(color: _darkTextColor),
        titleMedium: cardTitleStyle.copyWith(color: _darkTextColor),
        titleSmall: cardSubtitleStyle.copyWith(color: _darkTextColor.withValues(alpha: 0.7)),
        bodyMedium: TextStyle(
          fontSize: 14.0,
          height: 1.5,
          color: _darkTextColor.withValues(alpha: 0.8),
          letterSpacing: 0.2,
        ),
        bodySmall: TextStyle(
          fontSize: 12.0,
          height: 1.4,
          color: _darkTextColor.withValues(alpha: 0.6),
          letterSpacing: 0.1,
        ),
        labelSmall: labelStyle.copyWith(color: _darkTextColor.withValues(alpha: 0.5)),
        labelMedium: labelStyle.copyWith(color: _darkTextColor.withValues(alpha: 0.7)),
        labelLarge: tabLabelStyle.copyWith(color: _darkTextColor),
      ).apply(
        bodyColor: _darkTextColor.withValues(alpha: 0.8),
        displayColor: _darkTextColor,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCardColor,
        elevation: 2.0,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        height: 64,
        indicatorColor: primaryColor.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((Set<WidgetState> states) {
          final Color iconColor = states.contains(WidgetState.selected) ? primaryColor : _darkUnselectedItemColor;
          return IconThemeData(color: iconColor, size: 20.0);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) {
          final Color textColor = states.contains(WidgetState.selected) ? primaryColor : _darkUnselectedItemColor;
          return _navLabelBaseStyle.copyWith(color: textColor);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Input decoration theme for text fields
      inputDecorationTheme: InputDecorationTheme(
        fillColor: darkSurfaceColor,
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _darkInputBorderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _darkInputBorderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor, width: 1.0),
        ),
        labelStyle: labelStyle.copyWith(color: _darkTextColor.withValues(alpha: 0.6)),
        hintStyle: labelStyle.copyWith(color: _darkTextColor.withValues(alpha: 0.4)),
        prefixIconColor: _darkUnselectedItemColor,
        suffixIconColor: _darkUnselectedItemColor,
      ),

      // Other component themes
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: _darkUnselectedItemColor),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return Colors.transparent;
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return _darkUnselectedItemColor.withValues(alpha: 0.3);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      dividerTheme: DividerThemeData(
        color: _darkInputBorderColor,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
