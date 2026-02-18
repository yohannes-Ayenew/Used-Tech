// lib/core/theme/app_themes.dart

import 'package:flutter/material.dart';
import 'app_theme_extensions.dart';

class AppThemes {
  // Light Theme
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.light.primaryTeal,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00838F),
      secondary: Color(0xFFFF9800),
      surface: Colors.white,
      error: Colors.red,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.light.darkText,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.light.darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.light.darkText),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.light.darkText,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.light.darkText,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: AppColors.light.darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColors.light.darkText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.light.darkText,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: AppColors.light.darkText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.light.greyText, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.light.greyText, fontSize: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.light.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.light.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.light.primaryTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.light.primaryTeal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.light.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.light.borderColor),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.light.cardBackground,
      selectedItemColor: AppColors.light.primaryTeal,
      unselectedItemColor: AppColors.light.greyText,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    extensions: [AppColors.light],
  );

  // Dark Theme
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.dark.primaryTeal,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4FB3BF),
      secondary: Color(0xFFFFB74D),
      surface: Color(0xFF2C2C2C),
      error: Colors.red,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.dark.cardBackground,
      foregroundColor: AppColors.dark.darkText,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.dark.darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.dark.darkText),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.dark.darkText,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.dark.darkText,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: AppColors.dark.darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColors.dark.darkText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.dark.darkText,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: AppColors.dark.darkText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.dark.greyText, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.dark.greyText, fontSize: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.dark.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.dark.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.dark.primaryTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.dark.primaryTeal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.dark.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.dark.borderColor),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.dark.cardBackground,
      selectedItemColor: AppColors.dark.primaryTeal,
      unselectedItemColor: AppColors.dark.greyText,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    extensions: [AppColors.dark],
  );
}
