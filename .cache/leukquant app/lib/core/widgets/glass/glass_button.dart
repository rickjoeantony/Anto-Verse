// lib/core/widgets/glass/glass_button.dart

import 'package:flutter/material.dart';
import 'liquid_glass_button.dart';

/// Legacy wrapper for [LiquidGlassButton].
class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final double height;
  final double borderRadius;
  final double intensity;
  final EdgeInsetsGeometry padding;
  final Color? customColor;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isPrimary = true,
    this.height = 50.0,
    this.borderRadius = 16.0,
    this.intensity = 1.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassButton(
      onPressed: onPressed,
      isPrimary: isPrimary,
      height: height,
      cornerRadius: borderRadius,
      intensity: intensity,
      padding: padding,
      customColor: customColor,
      child: child,
    );
  }
}
