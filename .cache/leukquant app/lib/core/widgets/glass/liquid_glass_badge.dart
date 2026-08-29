// lib/core/widgets/glass/liquid_glass_badge.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

/// Translucent Liquid Glass Status and Severity Badge with glowing indicator dot,
/// frosted blur, and crisp typography.
class LiquidGlassBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool showDot;
  final bool isUppercase;
  final double fontSize;
  final double cornerRadius;
  final double intensity;
  final EdgeInsetsGeometry padding;
  final IconData? icon;

  const LiquidGlassBadge({
    super.key,
    required this.label,
    required this.color,
    this.showDot = true,
    this.isUppercase = true,
    this.fontSize = 11.0,
    this.cornerRadius = 20.0,
    this.intensity = 1.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
    this.icon,
  });

  /// Factory helper for Severity levels
  factory LiquidGlassBadge.severity(
    String severity,
    BuildContext context, {
    Key? key,
    bool showDot = true,
    double fontSize = 11.0,
  }) {
    final colors = AppColors.of(context);
    final (Color badgeColor, String badgeLabel) = switch (severity.toLowerCase()) {
      'critical' => (colors.critical, 'Critical'),
      'high' => (colors.high, 'High'),
      'medium' => (colors.warning, 'Medium'),
      'low' => (colors.brandPrimary, 'Low'),
      'info' => (colors.textSecondary, 'Info'),
      _ => (colors.textSecondary, severity),
    };

    return LiquidGlassBadge(
      key: key,
      label: badgeLabel,
      color: badgeColor,
      showDot: showDot,
      isUppercase: false,
      fontSize: fontSize,
    );
  }

  /// Factory helper for online/healthy status
  factory LiquidGlassBadge.status({
    Key? key,
    required String label,
    required bool isOnline,
    required BuildContext context,
    double fontSize = 11.0,
  }) {
    final colors = AppColors.of(context);
    return LiquidGlassBadge(
      key: key,
      label: label,
      color: isOnline ? colors.success : colors.critical,
      showDot: true,
      isUppercase: false,
      fontSize: fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clampedIntensity = intensity.clamp(0.0, 1.0);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12 * clampedIntensity,
            sigmaY: 12 * clampedIntensity,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(cornerRadius),
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.40 : 0.30),
                width: 0.9,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: fontSize + 1, color: color),
                  const SizedBox(width: 4.5),
                ] else if (showDot) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.7),
                          blurRadius: 6,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5.5),
                ],
                Text(
                  isUppercase ? label.toUpperCase() : label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
