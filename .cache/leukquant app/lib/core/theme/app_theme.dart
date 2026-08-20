// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'sans-serif',
    colorScheme: ColorScheme.light(
      primary: AppColors.lightBrandPrimary,
      secondary: AppColors.lightBrandSecondary,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    extensions: <ThemeExtension<dynamic>>[AppColors.lightScheme],
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'sans-serif',
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkBrandPrimary,
      secondary: AppColors.darkBrandSecondary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    extensions: <ThemeExtension<dynamic>>[AppColors.darkScheme],
  );
}
