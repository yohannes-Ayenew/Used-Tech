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

  // Access custom app colors
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;

  // Helper methods for common colors
  Color get primaryColor => appColors.primaryTeal;
  Color get secondaryColor => appColors.secondaryOrange;
  Color get successColor => appColors.successGreen;
  Color get lightGrey => appColors.lightGrey;
  Color get darkText => appColors.darkText;
  Color get greyText => appColors.greyText;
  Color get pillGreen => appColors.pillGreen;
  Color get pillText => appColors.pillText;
  Color get cardBackground => appColors.cardBackground;
  Color get borderColor => appColors.borderColor;

  // Helper for responsive sizing
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  bool get isSmallScreen => width < 600;
  bool get isMediumScreen => width >= 600 && width < 1200;
  bool get isLargeScreen => width >= 1200;
}
