import 'package:flutter/material.dart';
import 'app_colors.dart';

enum AppThemeType { purple, blue, green, yellow, dark, darkBlue, darkGreen, darkYellow }

class AppTheme {
  static AppColors getColors(AppThemeType type) {
    switch (type) {
      case AppThemeType.purple:
        return AppColors.purple;
      case AppThemeType.blue:
        return AppColors.blue;
      case AppThemeType.green:
        return AppColors.green;
      case AppThemeType.yellow:
        return AppColors.yellow;
      case AppThemeType.dark:
        return AppColors.dark;
      case AppThemeType.darkBlue:
        return AppColors.darkBlue;
      case AppThemeType.darkGreen:
        return AppColors.darkGreen;
      case AppThemeType.darkYellow:
        return AppColors.darkYellow;
    }
  }

  static ThemeData getThemeData(AppThemeType type) {
    final colors = getColors(type);
    
    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: colors.brightness,
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.surface,
        error: colors.error,
      ),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        hintStyle: TextStyle(color: colors.textHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textHint,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: colors.textPrimary),
        bodyMedium: TextStyle(color: colors.textSecondary),
        bodySmall: TextStyle(color: colors.textHint),
      ),
    );
  }

  // Default theme
  static ThemeData get light => getThemeData(AppThemeType.purple);
  static ThemeData get dark => getThemeData(AppThemeType.dark);
}
