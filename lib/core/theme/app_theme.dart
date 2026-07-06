import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// App-wide light and dark ThemeData, both anchored to the gold brand accent.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.light,
      primary: AppColors.gold,
      secondary: AppColors.goldDark,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.black,
        elevation: 0,
        titleTextStyle: AppTextStyles.heading3(AppColors.black),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.heading1(AppColors.lightTextPrimary),
        headlineMedium: AppTextStyles.heading2(AppColors.lightTextPrimary),
        headlineSmall: AppTextStyles.heading3(AppColors.lightTextPrimary),
        bodyLarge: AppTextStyles.body(AppColors.lightTextPrimary),
        bodyMedium: AppTextStyles.body(AppColors.lightTextSecondary),
        labelLarge: AppTextStyles.button,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.white,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.dark,
      primary: AppColors.goldLight,
      secondary: AppColors.gold,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.black,
        elevation: 0,
        titleTextStyle: AppTextStyles.heading3(AppColors.black),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.heading1(AppColors.darkTextPrimary),
        headlineMedium: AppTextStyles.heading2(AppColors.darkTextPrimary),
        headlineSmall: AppTextStyles.heading3(AppColors.darkTextPrimary),
        bodyLarge: AppTextStyles.body(AppColors.darkTextPrimary),
        bodyMedium: AppTextStyles.body(AppColors.darkTextSecondary),
        labelLarge: AppTextStyles.button,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldLight,
          foregroundColor: AppColors.black,
          textStyle: AppTextStyles.button.copyWith(color: AppColors.black),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
