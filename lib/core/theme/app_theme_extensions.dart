// lib/core/theme/app_theme_extensions.dart

import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color primaryTeal;
  final Color secondaryOrange;
  final Color successGreen;
  final Color lightGrey;
  final Color darkText;
  final Color greyText;
  final Color pillGreen;
  final Color pillText;
  final Color cardBackground;
  final Color borderColor;

  const AppColors({
    required this.primaryTeal,
    required this.secondaryOrange,
    required this.successGreen,
    required this.lightGrey,
    required this.darkText,
    required this.greyText,
    required this.pillGreen,
    required this.pillText,
    required this.cardBackground,
    required this.borderColor,
  });

  // Light theme colors
  static const light = AppColors(
    primaryTeal: Color(0xFF00838F),
    secondaryOrange: Color(0xFFFF9800),
    successGreen: Color(0xFF4CAF50),
    lightGrey: Color(0xFFF5F5F5),
    darkText: Color(0xFF212121),
    greyText: Color(0xFF757575),
    pillGreen: Color(0xFFE8F5E9),
    pillText: Color(0xFF2E7D32),
    cardBackground: Colors.white,
    borderColor: Color(0xFFE0E0E0),
  );

  // Dark theme colors
  static const dark = AppColors(
    primaryTeal: Color(0xFF4FB3BF), // Lighter teal for dark mode
    secondaryOrange: Color(0xFFFFB74D),
    successGreen: Color(0xFF81C784),
    lightGrey: Color(0xFF2C2C2C),
    darkText: Color(0xFFF5F5F5),
    greyText: Color(0xFFB0B0B0),
    pillGreen: Color(0xFF1B5E20),
    pillText: Color(0xFF81C784),
    cardBackground: Color(0xFF2C2C2C),
    borderColor: Color(0xFF404040),
  );

  @override
  ThemeExtension<AppColors> copyWith({
    Color? primaryTeal,
    Color? secondaryOrange,
    Color? successGreen,
    Color? lightGrey,
    Color? darkText,
    Color? greyText,
    Color? pillGreen,
    Color? pillText,
    Color? cardBackground,
    Color? borderColor,
  }) {
    return AppColors(
      primaryTeal: primaryTeal ?? this.primaryTeal,
      secondaryOrange: secondaryOrange ?? this.secondaryOrange,
      successGreen: successGreen ?? this.successGreen,
      lightGrey: lightGrey ?? this.lightGrey,
      darkText: darkText ?? this.darkText,
      greyText: greyText ?? this.greyText,
      pillGreen: pillGreen ?? this.pillGreen,
      pillText: pillText ?? this.pillText,
      cardBackground: cardBackground ?? this.cardBackground,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primaryTeal: Color.lerp(primaryTeal, other.primaryTeal, t)!,
      secondaryOrange: Color.lerp(secondaryOrange, other.secondaryOrange, t)!,
      successGreen: Color.lerp(successGreen, other.successGreen, t)!,
      lightGrey: Color.lerp(lightGrey, other.lightGrey, t)!,
      darkText: Color.lerp(darkText, other.darkText, t)!,
      greyText: Color.lerp(greyText, other.greyText, t)!,
      pillGreen: Color.lerp(pillGreen, other.pillGreen, t)!,
      pillText: Color.lerp(pillText, other.pillText, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
    );
  }
}
