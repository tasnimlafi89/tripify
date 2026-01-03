import 'package:flutter/material.dart';

class AppColors {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color accent;
  
  final Color background;
  final Color backgroundGradientStart;
  final Color backgroundGradientMiddle;
  final Color backgroundGradientEnd;
  
  final Color surface;
  final Color surfaceVariant;
  
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  
  // Featured destination colors
  final Color featuredPink;
  final Color featuredPurple;
  final Color featuredBlue;
  final Color featuredOrange;
  
  // Search bar border color
  final Color searchBarBorder;
  
  final Brightness brightness;

  List<Color> get featuredColors => [
    featuredPink,
    featuredPurple,
    featuredBlue,
    featuredOrange,
  ];

  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.backgroundGradientStart,
    required this.backgroundGradientMiddle,
    required this.backgroundGradientEnd,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.featuredPink,
    required this.featuredPurple,
    required this.featuredBlue,
    required this.featuredOrange,
    required this.searchBarBorder,
    required this.brightness,
  });

  LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryLight, secondary],
  );

  LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundGradientStart, backgroundGradientMiddle, backgroundGradientEnd],
  );

  // Purple Theme (Default)
  static const AppColors purple = AppColors(
    primary: Color(0xFF7C3AED),
    primaryLight: Color(0xFFA78BFA),
    primaryDark: Color(0xFF6D28D9),
    secondary: Color(0xFF818CF8),
    accent: Color(0xFF6366F1),
    background: Color(0xFFF8F7FF),
    backgroundGradientStart: Color(0xFFF8F7FF),
    backgroundGradientMiddle: Color(0xFFEDE9FE),
    backgroundGradientEnd: Color(0xFFE0D6FF),
    surface: Colors.white,
    surfaceVariant: Color(0xFFF3F4F6),
    textPrimary: Color(0xFF374151),
    textSecondary: Color(0xFF6B7280),
    textHint: Color(0xFF9CA3AF),
    success: Color(0xFF10B981),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF3B82F6),
    featuredPink: Color(0xFFEC4899),
    featuredPurple: Color(0xFF8B5CF6),
    featuredBlue: Color(0xFF3B82F6),
    featuredOrange: Color(0xFFF59E0B),
    searchBarBorder: Colors.transparent,
    brightness: Brightness.light,
  );

  // Blue Theme
  static const AppColors blue = AppColors(
    primary: Color(0xFF3B82F6),
    primaryLight: Color(0xFF60A5FA),
    primaryDark: Color(0xFF2563EB),
    secondary: Color(0xFF38BDF8),
    accent: Color(0xFF0EA5E9),
    background: Color(0xFFF0F9FF),
    backgroundGradientStart: Color(0xFFF0F9FF),
    backgroundGradientMiddle: Color(0xFFE0F2FE),
    backgroundGradientEnd: Color(0xFFBAE6FD),
    surface: Colors.white,
    surfaceVariant: Color(0xFFF1F5F9),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF475569),
    textHint: Color(0xFF94A3B8),
    success: Color(0xFF10B981),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF0EA5E9),
    featuredPink: Color(0xFFF472B6),
    featuredPurple: Color(0xFF60A5FA),
    featuredBlue: Color(0xFF0EA5E9),
    featuredOrange: Color(0xFFFBBF24),
    searchBarBorder: Colors.transparent,
    brightness: Brightness.light,
  );

  // Green Theme
  static const AppColors green = AppColors(
    primary: Color(0xFF10B981),
    primaryLight: Color(0xFF34D399),
    primaryDark: Color(0xFF059669),
    secondary: Color(0xFF6EE7B7),
    accent: Color(0xFF14B8A6),
    background: Color(0xFFF0FDF4),
    backgroundGradientStart: Color(0xFFF0FDF4),
    backgroundGradientMiddle: Color(0xFFDCFCE7),
    backgroundGradientEnd: Color(0xFFBBF7D0),
    surface: Colors.white,
    surfaceVariant: Color(0xFFF0FDF4),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF4B5563),
    textHint: Color(0xFF9CA3AF),
    success: Color(0xFF10B981),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF3B82F6),
    featuredPink: Color(0xFF14B8A6),
    featuredPurple: Color(0xFF34D399),
    featuredBlue: Color(0xFF059669),
    featuredOrange: Color(0xFF6EE7B7),
    searchBarBorder: Colors.transparent,
    brightness: Brightness.light,
  );

  // Yellow/Amber Theme
  static const AppColors yellow = AppColors(
    primary: Color(0xFFF59E0B),
    primaryLight: Color(0xFFFBBF24),
    primaryDark: Color(0xFFD97706),
    secondary: Color(0xFFFCD34D),
    accent: Color(0xFFF97316),
    background: Color(0xFFFFFBEB),
    backgroundGradientStart: Color(0xFFFFFBEB),
    backgroundGradientMiddle: Color(0xFFFEF3C7),
    backgroundGradientEnd: Color(0xFFFDE68A),
    surface: Colors.white,
    surfaceVariant: Color(0xFFFFFBEB),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF4B5563),
    textHint: Color(0xFF9CA3AF),
    success: Color(0xFF10B981),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF3B82F6),
    featuredPink: Color(0xFFF97316),
    featuredPurple: Color(0xFFFBBF24),
    featuredBlue: Color(0xFFD97706),
    featuredOrange: Color(0xFFFCD34D),
    searchBarBorder: Colors.transparent,
    brightness: Brightness.light,
  );

  // Dark Theme
  static const AppColors dark = AppColors(
    primary: Color(0xFFA78BFA),
    primaryLight: Color(0xFFC4B5FD),
    primaryDark: Color(0xFF8B5CF6),
    secondary: Color(0xFF818CF8),
    accent: Color(0xFF6366F1),
    background: Color(0xFF0F172A),
    backgroundGradientStart: Color(0xFF0F172A),
    backgroundGradientMiddle: Color(0xFF1E293B),
    backgroundGradientEnd: Color(0xFF334155),
    surface: Color.fromARGB(255, 57, 59, 79),
    surfaceVariant: Color(0xFF334155),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFFCBD5E1),
    textHint: Color(0xFF94A3B8),
    success: Color(0xFF34D399),
    error: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF60A5FA),
    featuredPink: Color(0xFFF472B6),
    featuredPurple: Color(0xFFC4B5FD),
    featuredBlue: Color(0xFF60A5FA),
    featuredOrange: Color(0xFFFBBF24),
    searchBarBorder: Colors.white,
    brightness: Brightness.dark,
  );

  // Dark Blue Theme
  static const AppColors darkBlue = AppColors(
    primary: Color(0xFF60A5FA),
    primaryLight: Color(0xFF93C5FD),
    primaryDark: Color(0xFF3B82F6),
    secondary: Color(0xFF38BDF8),
    accent: Color(0xFF0EA5E9),
    background: Color(0xFF0F172A),
    backgroundGradientStart: Color(0xFF0F172A),
    backgroundGradientMiddle: Color(0xFF1E293B),
    backgroundGradientEnd: Color(0xFF334155),
    surface: Color.fromARGB(255, 57, 59, 79),
    surfaceVariant: Color(0xFF334155),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFFCBD5E1),
    textHint: Color(0xFF94A3B8),
    success: Color(0xFF34D399),
    error: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF60A5FA),
    featuredPink: Color(0xFFF472B6),
    featuredPurple: Color(0xFFC4B5FD),
    featuredBlue: Color(0xFF60A5FA),
    featuredOrange: Color(0xFFFBBF24),
    searchBarBorder: Colors.white,
    brightness: Brightness.dark,
  );

  // Dark Green Theme
  static const AppColors darkGreen = AppColors(
    primary: Color(0xFF34D399),
    primaryLight: Color(0xFF6EE7B7),
    primaryDark: Color(0xFF10B981),
    secondary: Color(0xFF6EE7B7),
    accent: Color(0xFF14B8A6),
    background: Color(0xFF0F172A),
    backgroundGradientStart: Color(0xFF0F172A),
    backgroundGradientMiddle: Color(0xFF1E293B),
    backgroundGradientEnd: Color(0xFF334155),
    surface: Color.fromARGB(255, 57, 59, 79),
    surfaceVariant: Color(0xFF334155),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFFCBD5E1),
    textHint: Color(0xFF94A3B8),
    success: Color(0xFF34D399),
    error: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF60A5FA),
    featuredPink: Color(0xFFF472B6),
    featuredPurple: Color(0xFFC4B5FD),
    featuredBlue: Color(0xFF60A5FA),
    featuredOrange: Color(0xFFFBBF24),
    searchBarBorder: Colors.white,
    brightness: Brightness.dark,
  );

  // Dark Yellow Theme
  static const AppColors darkYellow = AppColors(
    primary: Color(0xFFFBBF24),
    primaryLight: Color(0xFFFCD34D),
    primaryDark: Color(0xFFF59E0B),
    secondary: Color(0xFFFCD34D),
    accent: Color(0xFFF97316),
    background: Color(0xFF0F172A),
    backgroundGradientStart: Color(0xFF0F172A),
    backgroundGradientMiddle: Color(0xFF1E293B),
    backgroundGradientEnd: Color(0xFF334155),
    surface: Color.fromARGB(255, 57, 59, 79),
    surfaceVariant: Color(0xFF334155),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFFCBD5E1),
    textHint: Color(0xFF94A3B8),
    success: Color(0xFF34D399),
    error: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF60A5FA),
    featuredPink: Color(0xFFF472B6),
    featuredPurple: Color(0xFFC4B5FD),
    featuredBlue: Color(0xFF60A5FA),
    featuredOrange: Color(0xFFFBBF24),
    searchBarBorder: Colors.white,
    brightness: Brightness.dark,
  );
}
