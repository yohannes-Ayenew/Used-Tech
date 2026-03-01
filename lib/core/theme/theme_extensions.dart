// lib/core/theme/theme_extensions.dart

import 'package:flutter/material.dart';
import 'app_theme_extensions.dart';

extension ThemeExtensions on BuildContext {
  // Access theme data
  ThemeData get theme => Theme.of(this);

  // Access text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Access color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Access custom app colors safely
  AppColors get appColors => Theme.of(this).extension<AppColors>() ?? AppColors.light;

  // Helper methods for common colors with fallbacks
  Color get primaryColor => Theme.of(this).extension<AppColors>()?.primaryTeal ?? const Color(0xFF00838F);
  Color get secondaryColor => Theme.of(this).extension<AppColors>()?.secondaryOrange ?? const Color(0xFFFF9800);
  Color get successColor => Theme.of(this).extension<AppColors>()?.successGreen ?? const Color(0xFF4CAF50);
  Color get lightGrey => Theme.of(this).extension<AppColors>()?.lightGrey ?? const Color(0xFFF5F5F5);
  Color get darkText => Theme.of(this).extension<AppColors>()?.darkText ?? const Color(0xFF212121);
  Color get greyText => Theme.of(this).extension<AppColors>()?.greyText ?? const Color(0xFF757575);
  Color get pillGreen => Theme.of(this).extension<AppColors>()?.pillGreen ?? const Color(0xFFE8F5E9);
  Color get pillText => Theme.of(this).extension<AppColors>()?.pillText ?? const Color(0xFF2E7D32);
  Color get cardBackground => Theme.of(this).extension<AppColors>()?.cardBackground ?? Colors.white;
  Color get borderColor => Theme.of(this).extension<AppColors>()?.borderColor ?? const Color(0xFFE0E0E0);

  // Helper for responsive sizing
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  bool get isSmallScreen => width < 600;
  bool get isMediumScreen => width >= 600 && width < 1200;
  bool get isLargeScreen => width >= 1200;
}
