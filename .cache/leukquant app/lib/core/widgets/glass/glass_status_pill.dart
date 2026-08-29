// lib/core/widgets/glass/glass_status_pill.dart

import 'package:flutter/material.dart';
import 'liquid_glass_badge.dart';

/// Legacy wrapper for [LiquidGlassBadge].
class GlassStatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool showDot;
  final bool isUppercase;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final double cornerRadius;
  final double intensity;

  const GlassStatusPill({
    super.key,
    required this.label,
    required this.color,
    this.showDot = true,
    this.isUppercase = false,
    this.fontSize = 11.0,
    this.cornerRadius = 14.0,
    this.intensity = 1.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
  });

  factory GlassStatusPill.severity(String severity, BuildContext context) {
    return LiquidGlassBadge.severity(severity, context) as dynamic;
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBadge(
      label: label,
      color: color,
      showDot: showDot,
      isUppercase: isUppercase,
      fontSize: fontSize,
      cornerRadius: cornerRadius,
      intensity: intensity,
      padding: padding,
    );
  }
}
