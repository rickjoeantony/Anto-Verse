// lib/core/widgets/glass/glass_container.dart

import 'package:flutter/material.dart';
import 'liquid_glass_container.dart';

/// Legacy wrapper for [LiquidGlassContainer].
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final bool enableBackdropBlur;
  final Color? customFillColor;
  final Color? customBorderColor;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.blurSigma = 8.0,
    this.enableBackdropBlur = true,
    this.customFillColor,
    this.customBorderColor,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      cornerRadius: borderRadius,
      blurSigma: blurSigma,
      enableBlur: enableBackdropBlur,
      customFillColor: customFillColor,
      customBorderColor: customBorderColor,
      shadows: shadows,
      onTap: onTap,
      child: child,
    );
  }
}
