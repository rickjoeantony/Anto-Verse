// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// Semantic colors defined strictly per LeukQuant Enterprise specifications.
class AppColors {
  AppColors._();

  // -------------------------------------------------------------
  // BRAND COLOR TOKENS
  // -------------------------------------------------------------
  static const Color brandPrimary = Color(0xFF2563EB);
  static const Color brandPrimaryDark = Color(0xFF1D4ED8);
  static const Color brandPrimarySoft = Color(0xFFDBEAFE);
  static const Color brandPrimaryVeryLight = Color(0xFFEFF6FF);

  // -------------------------------------------------------------
  // LIGHT THEME PALETTE
  // -------------------------------------------------------------
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBrandPrimary = brandPrimary;
  static const Color lightBrandSecondary = Color(0xFF0F766E);
  static const Color lightSuccess = Color(0xFF16A34A);
  static const Color lightWarning = Color(0xFFD97706);
  static const Color lightHigh = Color(0xFFEA580C);
  static const Color lightCritical = Color(0xFFDC2626);

  // -------------------------------------------------------------
  // DARK THEME PALETTE (ACTUAL PITCH OLED BLACK)
  // -------------------------------------------------------------
  static const Color darkBackground = Color(0xFF000000); // True OLED Black
  static const Color darkSurface = Color(0xFF0B101D); // Deep midnight surface
  static const Color darkSurfaceMuted = Color(0xFF12192A);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF1E293B);
  static const Color darkBrandPrimary = Color(0xFF3B82F6);
  static const Color darkBrandSecondary = Color(0xFF14B8A6);
  static const Color darkSuccess = Color(0xFF22C55E);
  static const Color darkWarning = Color(0xFFF59E0B);
  static const Color darkHigh = Color(0xFFF97316);
  static const Color darkCritical = Color(0xFFEF4444);

  /// Helper to get the active [AppColorScheme] from context
  static AppColorScheme of(BuildContext context) {
    return Theme.of(context).extension<AppColorScheme>() ?? lightScheme;
  }

  static const AppColorScheme lightScheme = AppColorScheme(
    background: lightBackground,
    surface: lightSurface,
    surfaceMuted: lightSurfaceMuted,
    textPrimary: lightTextPrimary,
    textSecondary: lightTextSecondary,
    border: lightBorder,
    brandPrimary: lightBrandPrimary,
    brandPrimaryDark: brandPrimaryDark,
    brandPrimarySoft: brandPrimarySoft,
    brandPrimaryVeryLight: brandPrimaryVeryLight,
    brandSecondary: lightBrandSecondary,
    success: lightSuccess,
    warning: lightWarning,
    high: lightHigh,
    critical: lightCritical,
  );

  static const AppColorScheme darkScheme = AppColorScheme(
    background: darkBackground,
    surface: darkSurface,
    surfaceMuted: darkSurfaceMuted,
    textPrimary: darkTextPrimary,
    textSecondary: darkTextSecondary,
    border: darkBorder,
    brandPrimary: darkBrandPrimary,
    brandPrimaryDark: Color(0xFF2563EB),
    brandPrimarySoft: Color(0xFF1E293B),
    brandPrimaryVeryLight: Color(0xFF000000),
    brandSecondary: darkBrandSecondary,
    success: darkSuccess,
    warning: darkWarning,
    high: darkHigh,
    critical: darkCritical,
  );
}

/// Theme extension for custom LeukQuant semantic colors.
@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color brandPrimary;
  final Color brandPrimaryDark;
  final Color brandPrimarySoft;
  final Color brandPrimaryVeryLight;
  final Color brandSecondary;
  final Color success;
  final Color warning;
  final Color high;
  final Color critical;

  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.brandPrimary,
    required this.brandPrimaryDark,
    required this.brandPrimarySoft,
    required this.brandPrimaryVeryLight,
    required this.brandSecondary,
    required this.success,
    required this.warning,
    required this.high,
    required this.critical,
  });

  @override
  AppColorScheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? brandPrimary,
    Color? brandPrimaryDark,
    Color? brandPrimarySoft,
    Color? brandPrimaryVeryLight,
    Color? brandSecondary,
    Color? success,
    Color? warning,
    Color? high,
    Color? critical,
  }) {
    return AppColorScheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandPrimaryDark: brandPrimaryDark ?? this.brandPrimaryDark,
      brandPrimarySoft: brandPrimarySoft ?? this.brandPrimarySoft,
      brandPrimaryVeryLight: brandPrimaryVeryLight ?? this.brandPrimaryVeryLight,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      high: high ?? this.high,
      critical: critical ?? this.critical,
    );
  }

  @override
  AppColorScheme lerp(ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandPrimaryDark: Color.lerp(brandPrimaryDark, other.brandPrimaryDark, t)!,
      brandPrimarySoft: Color.lerp(brandPrimarySoft, other.brandPrimarySoft, t)!,
      brandPrimaryVeryLight: Color.lerp(brandPrimaryVeryLight, other.brandPrimaryVeryLight, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      high: Color.lerp(high, other.high, t)!,
      critical: Color.lerp(critical, other.critical, t)!,
    );
  }
}
