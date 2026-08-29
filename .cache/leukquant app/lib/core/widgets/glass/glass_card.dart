// lib/core/widgets/glass/glass_card.dart

import 'package:flutter/material.dart';
import 'liquid_glass_card.dart';

/// Legacy wrapper for [LiquidGlassCard].
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? customFillColor;
  final Color? customBorderColor;
  final double blurSigma;
  final double intensity;
  final bool enableBlur;
  final bool isStrongGlass;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18.0),
    this.margin,
    this.borderRadius = 24.0,
    this.onTap,
    this.customFillColor,
    this.customBorderColor,
    this.blurSigma = 20.0,
    this.intensity = 1.0,
    this.enableBlur = true,
    this.isStrongGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: padding,
      margin: margin,
      cornerRadius: borderRadius,
      onTap: onTap,
      customFillColor: customFillColor,
      customBorderColor: customBorderColor,
      blurSigma: blurSigma,
      intensity: intensity,
      enableBlur: enableBlur,
      isStrongGlass: isStrongGlass,
      child: child,
    );
  }
}
