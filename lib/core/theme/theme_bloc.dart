// lib/core/theme/theme_bloc.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:used_tech_client/core/theme/app_themes.dart';

enum AppTheme { light, dark, system }

class ThemeState {
  final AppTheme currentTheme;
  final ThemeData themeData;

  ThemeState({required this.currentTheme, required this.themeData});
}

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themePrefKey = 'app_theme';

  ThemeCubit()
    : super(
        ThemeState(
          currentTheme: AppTheme.system,
          themeData: _getThemeFromMode(ThemeMode.system),
        ),
      ) {
    _loadSavedTheme();
  }

  static ThemeData _getThemeFromMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppThemes.lightTheme;
      case ThemeMode.dark:
        return AppThemes.darkTheme;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? AppThemes.darkTheme
            : AppThemes.lightTheme;
    }
  }

  static ThemeData _getThemeFromAppTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return AppThemes.lightTheme;
      case AppTheme.dark:
        return AppThemes.darkTheme;
      case AppTheme.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? AppThemes.darkTheme
            : AppThemes.lightTheme;
    }
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex =
        prefs.getInt(_themePrefKey) ?? 2; // Default to system
    final savedTheme = AppTheme.values[savedThemeIndex];

    emit(
      ThemeState(
        currentTheme: savedTheme,
        themeData: _getThemeFromAppTheme(savedTheme),
      ),
    );
  }

  Future<void> setTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePrefKey, theme.index);

    emit(
      ThemeState(currentTheme: theme, themeData: _getThemeFromAppTheme(theme)),
    );
  }

  ThemeMode get themeMode {
    switch (state.currentTheme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }
}
