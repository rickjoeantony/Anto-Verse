// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// Semantic colors and Liquid Glass tokens defined for LeukQuant Flutter Mobile.
class AppColors {
  AppColors._();

  // -------------------------------------------------------------
  // BRAND COLOR TOKENS
  // -------------------------------------------------------------
  static const Color brandPrimary = Color(0xFF2563EB); // Royal Pro Blue
  static const Color brandPrimaryDark = Color(0xFF1D4ED8);
  static const Color brandPrimarySoft = Color(0xFFEFF6FF);
  static const Color brandPrimaryVeryLight = Color(0xFFF2F6FF);
  static const Color brandSecondaryTeal = Color(0xFF0F766E);
  static const Color brandSecondaryCyan = Color(0xFF2DD4BF);

  // -------------------------------------------------------------
  // LIGHT THEME PALETTE (Very light blue #F2F6FF base + Liquid Glass)
  // -------------------------------------------------------------
  static const Color lightBackground = Color(0xFFF2F6FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFE8EFFD);
  static const Color lightTextPrimary = Color(0xFF0B111D);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightBorder = Color(0xFFDBE5F5);
  static const Color lightBrandPrimary = brandPrimary;
  static const Color lightBrandSecondary = brandSecondaryTeal;
  static const Color lightSuccess = Color(0xFF16A34A);
  static const Color lightWarning = Color(0xFFD97706);
  static const Color lightHigh = Color(0xFFEA580C);
  static const Color lightCritical = Color(0xFFDC2626);

  // Liquid Glass Tokens - Light Mode
  static const Color lightGlassFill = Color(0x8EFFFFFF); // white at 55% opacity
  static const Color lightGlassStrongFill = Color(0xB2FFFFFF); // white at 70% opacity
  static const Color lightGlassBorder = Color(0xC2FFFFFF); // white at 76% opacity
  static const Color lightGlassInnerHighlight = Color(0xE6FFFFFF); // white at 90% opacity
  static const Color lightGlassEdgeGlow = Color(0x1B2563EB); // blue #2563EB at 10.6% opacity
  static const Color lightGlassPill = Color(0x202563EB);
  static const Color lightBackgroundGlow1 = Color(0x1A2563EB); // blue #2563EB at 10% opacity
  static const Color lightBackgroundGlow2 = Color(0x140F766E); // teal #0F766E at 8% opacity

  // -------------------------------------------------------------
  // DARK THEME PALETTE (Deep Navy #0B1020 base + Liquid Glass)
  // -------------------------------------------------------------
  static const Color darkBackground = Color(0xFF0B1020);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkSurfaceMuted = Color(0xFF172033);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0x28FFFFFF);
  static const Color darkBrandPrimary = Color(0xFF3B82F6);
  static const Color darkBrandSecondary = brandSecondaryCyan;
  static const Color darkSuccess = Color(0xFF22C55E);
  static const Color darkWarning = Color(0xFFF59E0B);
  static const Color darkHigh = Color(0xFFF97316);
  static const Color darkCritical = Color(0xFFEF4444);

  // Liquid Glass Tokens - Dark Mode
  static const Color darkGlassFill = Color(0x9E172033); // navy #172033 at 62% opacity
  static const Color darkGlassStrongFill = Color(0xC7172033); // navy #172033 at 78% opacity
  static const Color darkGlassBorder = Color(0x28FFFFFF); // white at 16% opacity
  static const Color darkGlassInnerHighlight = Color(0x45FFFFFF); // white at 27% opacity
  static const Color darkGlassEdgeGlow = Color(0x2160A5FA); // blue #60A5FA at 13% opacity
  static const Color darkGlassPill = Color(0x2E3B82F6);
  static const Color darkBackgroundGlow1 = Color(0x242563EB); // blue #2563EB at 14% opacity
  static const Color darkBackgroundGlow2 = Color(0x1A2DD4BF); // teal #2DD4BF at 10% opacity

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
    glassCard: lightGlassFill,
    glassStrongFill: lightGlassStrongFill,
    glassBorder: lightGlassBorder,
    glassInnerHighlight: lightGlassInnerHighlight,
    glassEdgeGlow: lightGlassEdgeGlow,
    glassPill: lightGlassPill,
    backgroundGlow1: lightBackgroundGlow1,
    backgroundGlow2: lightBackgroundGlow2,
  );

  static const AppColorScheme darkScheme = AppColorScheme(
    background: darkBackground,
    surface: darkSurface,
    surfaceMuted: darkSurfaceMuted,
    textPrimary: darkTextPrimary,
    textSecondary: darkTextSecondary,
    border: darkBorder,
    brandPrimary: darkBrandPrimary,
    brandPrimaryDark: brandPrimary,
    brandPrimarySoft: Color(0xFF172554),
    brandPrimaryVeryLight: Color(0xFF0B1020),
    brandSecondary: darkBrandSecondary,
    success: darkSuccess,
    warning: darkWarning,
    high: darkHigh,
    critical: darkCritical,
    glassCard: darkGlassFill,
    glassStrongFill: darkGlassStrongFill,
    glassBorder: darkGlassBorder,
    glassInnerHighlight: darkGlassInnerHighlight,
    glassEdgeGlow: darkGlassEdgeGlow,
    glassPill: darkGlassPill,
    backgroundGlow1: darkBackgroundGlow1,
    backgroundGlow2: darkBackgroundGlow2,
  );
}

/// Theme extension for custom LeukQuant semantic colors and liquid glass tokens.
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

  // Liquid Glass Specific Tokens
  final Color glassCard; // Standard fill (52-58% light, 58-64% dark)
  final Color glassStrongFill; // Strong fill (66-72% light, 75-80% dark)
  final Color glassBorder; // Border (72-80% light, 14-18% dark)
  final Color glassInnerHighlight; // Top inner highlight (88-94% light, 24-30% dark)
  final Color glassEdgeGlow; // Edge glow (blue 8-14% light, 10-16% dark)
  final Color glassPill;
  final Color backgroundGlow1;
  final Color backgroundGlow2;

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
    required this.glassCard,
    required this.glassStrongFill,
    required this.glassBorder,
    required this.glassInnerHighlight,
    required this.glassEdgeGlow,
    required this.glassPill,
    required this.backgroundGlow1,
    required this.backgroundGlow2,
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
    Color? glassCard,
    Color? glassStrongFill,
    Color? glassBorder,
    Color? glassInnerHighlight,
    Color? glassEdgeGlow,
    Color? glassPill,
    Color? backgroundGlow1,
    Color? backgroundGlow2,
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
      glassCard: glassCard ?? this.glassCard,
      glassStrongFill: glassStrongFill ?? this.glassStrongFill,
      glassBorder: glassBorder ?? this.glassBorder,
      glassInnerHighlight: glassInnerHighlight ?? this.glassInnerHighlight,
      glassEdgeGlow: glassEdgeGlow ?? this.glassEdgeGlow,
      glassPill: glassPill ?? this.glassPill,
      backgroundGlow1: backgroundGlow1 ?? this.backgroundGlow1,
      backgroundGlow2: backgroundGlow2 ?? this.backgroundGlow2,
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
      glassCard: Color.lerp(glassCard, other.glassCard, t)!,
      glassStrongFill: Color.lerp(glassStrongFill, other.glassStrongFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassInnerHighlight: Color.lerp(glassInnerHighlight, other.glassInnerHighlight, t)!,
      glassEdgeGlow: Color.lerp(glassEdgeGlow, other.glassEdgeGlow, t)!,
      glassPill: Color.lerp(glassPill, other.glassPill, t)!,
      backgroundGlow1: Color.lerp(backgroundGlow1, other.backgroundGlow1, t)!,
      backgroundGlow2: Color.lerp(backgroundGlow2, other.backgroundGlow2, t)!,
    );
  }
}
