import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:used_tech_client/core/theme/app_theme_extensions.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';

void main() {
  group('ThemeExtensions Widget Tests', () {
    testWidgets('should correctly extract ThemeData, ColorScheme, and TextTheme from context', (tester) async {
      late ThemeData extractedTheme;
      late ColorScheme extractedColorScheme;
      late TextTheme extractedTextTheme;
      late bool extractedDarkMode;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              extractedTheme = context.theme;
              extractedColorScheme = context.colorScheme;
              extractedTextTheme = context.textTheme;
              extractedDarkMode = context.isDarkMode;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(extractedTheme, isNotNull);
      expect(extractedColorScheme, isNotNull);
      expect(extractedTextTheme, isNotNull);
      expect(extractedDarkMode, isFalse);
    });

    testWidgets('should detect dark mode when dark theme is applied', (tester) async {
      late bool extractedDarkMode;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              extractedDarkMode = context.isDarkMode;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(extractedDarkMode, isTrue);
    });

    testWidgets('should return AppColors light fallback when extension is not provided', (tester) async {
      late Color primaryColor;
      late AppColors appColors;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              primaryColor = context.primaryColor;
              appColors = context.appColors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(primaryColor, equals(const Color(0xFF00838F)));
      expect(appColors.primaryTeal, equals(AppColors.light.primaryTeal));
    });

    testWidgets('should return registered AppColors extension when configured in theme', (tester) async {
      late AppColors appColors;
      late Color secondaryColor;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            extensions: [AppColors.light],
          ),
          home: Builder(
            builder: (context) {
              appColors = context.appColors;
              secondaryColor = context.secondaryColor;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(appColors.primaryTeal, equals(AppColors.light.primaryTeal));
      expect(secondaryColor, equals(AppColors.light.secondaryOrange));
    });

    testWidgets('should evaluate responsive screen categories correctly based on MediaQuery size', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      late bool isSmall;
      late bool isMedium;
      late bool isLarge;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isSmall = context.isSmallScreen;
              isMedium = context.isMediumScreen;
              isLarge = context.isLargeScreen;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(isSmall, isTrue);
      expect(isMedium, isFalse);
      expect(isLarge, isFalse);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
