// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Modern, nature-inspired color palette
  static const Color primaryColor = Color(0xFF4CAF50); // Fresh green
  static const Color secondaryColor = Color(0xFF64B5F6); // Soft blue
  static const Color accentColor = Color(0xFFFFF176); // Gentle yellow accent

  // Category colors
  static const Color focusColor = Color(0xFFC8E6C9); // Light green
  static const Color sleepColor = Color(0xFFB3E5FC); // Light blue
  static const Color stressColor = Color(0xFFFFF9C4); // Light yellow

  // UI element colors - light mode
  static const Color lightSurfaceColor = Colors.white; // Light surface color
  static const Color lightBackgroundColor = Colors.white; // Light background
  static const Color lightCardColor = Colors.white; // Light card color
  static const Color lightBorderColor = Color(0x0D000000); // Light border (5% black)

  // UI element colors - dark mode
  static const Color darkSurfaceColor = Color(0xFF2A2A36); // Dark surface color
  static const Color darkBackgroundColor = Color(0xFF121218); // Dark background
  static const Color darkCardColor = Color(0xFF1E1E2A); // Dark card color
  static const Color darkBorderColor = Color(0x1AFFFFFF); // Dark border (10% white)

  // Text colors
  static const Color _lightTextColor = Color(0xFF2D2C3C); // Almost black with a hint of blue
  static const Color _darkTextColor = Colors.white;

  // Shadow colors
  static Color lightShadowColor = Colors.black.withValues(alpha: 0.05);
  static Color darkShadowColor = Colors.black.withValues(alpha: 0.2);

  // Opacity values for consistent usage
  static const double emphasisHighOpacity = 1.0;
  static const double emphasisMediumOpacity = 0.8;
  static const double emphasisLowOpacity = 0.5;
  static const double emphasisDisabledOpacity = 0.38;
  static const double surfaceOverlayOpacity = 0.1;
  static const double borderOpacity = 0.05;

  // UI element colors
  static const Color lightUnselectedItemColor = Color(0xFFADADB8);
  static final Color _darkUnselectedItemColor = Color(0xFF6F6F87);
  static final Color _lightInputBorderColor = Color(0xFFE0E0E9);
  static final Color _darkInputBorderColor = Color(0xFF3A3A48);

  // Shadows and transparent colors
  static final Color _shadowColor = primaryColor.withValues(alpha: 0.15);

  // Navigation
  static const TextStyle _navLabelBaseStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  // --- Component Constants ---
  // Button constants
  static const double buttonHeight = 50.0;
  static const double buttonBorderRadius = 30.0; // Rounded button corners
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 14, horizontal: 20);

  // Card constants
  static const double cardBorderRadius = 28.0;
  static const double cardElevation = 0.0;
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);

  // Icon container constants
  static const double iconContainerSize = 42.0;
  static const double iconContainerBorderRadius = 14.0;
  static const double iconSize = 20.0;

  // Base button text style
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
  );

  // --- Text Styles ---
  static const TextStyle pageTitleStyle = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle cardSubtitleStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.2,
  );

  static const TextStyle tabLabelStyle = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurfaceColor,
        error: accentColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _lightTextColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: lightBackgroundColor,
      cardColor: lightCardColor,
      cardTheme: CardTheme(
        color: lightCardColor,
        elevation: cardElevation,
        shadowColor: lightShadowColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
          side: BorderSide(color: lightBorderColor, width: 1), // Subtle border
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
        toolbarHeight: 64, // Slightly taller appbar for modern look
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: TextTheme(
        headlineLarge: pageTitleStyle.copyWith(color: _lightTextColor),
        titleMedium: cardTitleStyle.copyWith(color: _lightTextColor),
        titleSmall: cardSubtitleStyle.copyWith(color: _lightTextColor.withValues(alpha: 0.8)),
        bodyMedium: TextStyle(
          fontSize: 15.0,
          height: 1.5,
          color: _lightTextColor.withValues(alpha: 0.8),
          letterSpacing: 0.15,
        ),
        bodySmall: TextStyle(
          fontSize: 13.0,
          height: 1.4,
          color: _lightTextColor.withValues(alpha: 0.7),
          letterSpacing: 0.1,
        ),
        labelSmall: labelStyle.copyWith(color: _lightTextColor.withValues(alpha: 0.6)),
        labelMedium: labelStyle.copyWith(color: _lightTextColor.withValues(alpha: 0.8)),
        labelLarge: tabLabelStyle.copyWith(color: _lightTextColor),
      ).apply(
        bodyColor: _lightTextColor.withValues(alpha: 0.8),
        displayColor: _lightTextColor,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightCardColor,
        elevation: 5.0,
        shadowColor: _shadowColor,
        height: 70,
        indicatorColor: primaryColor.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((Set<WidgetState> states) {
          final Color iconColor = states.contains(WidgetState.selected) ? primaryColor : lightUnselectedItemColor;
          return IconThemeData(color: iconColor, size: 22.0);
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
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _lightInputBorderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _lightInputBorderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 1.0),
        ),
        labelStyle: labelStyle.copyWith(color: _lightTextColor.withValues(alpha: 0.7)),
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
        surface: darkSurfaceColor,
        error: accentColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _darkTextColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkCardColor,
      cardTheme: CardTheme(
        color: darkCardColor,
        elevation: 0, // Modern flat design
        shadowColor: _shadowColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0), // More pronounced rounded corners
          side: BorderSide(color: _darkInputBorderColor, width: 1), // Subtle border
        ),
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
        toolbarHeight: 64, // Slightly taller appbar for modern look
      ),
      textTheme: TextTheme(
        headlineLarge: pageTitleStyle.copyWith(color: _darkTextColor),
        titleMedium: cardTitleStyle.copyWith(color: _darkTextColor),
        titleSmall: cardSubtitleStyle.copyWith(color: _darkTextColor.withValues(alpha: 0.8)),
        bodyMedium: TextStyle(
          fontSize: 15.0,
          height: 1.5,
          color: _darkTextColor.withValues(alpha: 0.8),
          letterSpacing: 0.15,
        ),
        bodySmall: TextStyle(
          fontSize: 13.0,
          height: 1.4,
          color: _darkTextColor.withValues(alpha: 0.7),
          letterSpacing: 0.1,
        ),
        labelSmall: labelStyle.copyWith(color: _darkTextColor.withValues(alpha: 0.6)),
        labelMedium: labelStyle.copyWith(color: _darkTextColor.withValues(alpha: 0.8)),
        labelLarge: tabLabelStyle.copyWith(color: _darkTextColor),
      ).apply(
        bodyColor: _darkTextColor.withValues(alpha: 0.8),
        displayColor: _darkTextColor,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCardColor,
        elevation: 5.0,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        height: 70,
        indicatorColor: primaryColor.withValues(alpha: 0.15),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((Set<WidgetState> states) {
          final Color iconColor = states.contains(WidgetState.selected) ? primaryColor : _darkUnselectedItemColor;
          return IconThemeData(color: iconColor, size: 22.0);
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
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _darkInputBorderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _darkInputBorderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 1.0),
        ),
        labelStyle: labelStyle.copyWith(color: _darkTextColor.withValues(alpha: 0.7)),
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
