// lib/core/widgets/glass/liquid_glass_container.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Ultra-smooth Liquid Glass Container with translucent blurred surface,
/// adaptive light/dark glass tokens, natural specular border gradients,
/// and soft tinted shadows. Optimized for 60-120fps on all devices.
class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double cornerRadius;
  final double intensity; // 0.0 to 1.0
  final double blurSigma;
  final bool enableBlur;
  final bool isStrongGlass;
  final Color? customFillColor;
  final Color? customBorderColor;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.cornerRadius = 24.0,
    this.intensity = 1.0,
    this.blurSigma = 20.0,
    this.enableBlur = true,
    this.isStrongGlass = false,
    this.customFillColor,
    this.customBorderColor,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final clampedIntensity = intensity.clamp(0.0, 1.0);
    final effectiveBlur = enableBlur ? (blurSigma * clampedIntensity) : 0.0;

    // Resolve adaptive glass colors based on light/dark tokens
    final baseFill = isStrongGlass ? colors.glassStrongFill : colors.glassCard;
    final fillColor = customFillColor ??
        (clampedIntensity < 1.0
            ? baseFill.withValues(alpha: baseFill.a * clampedIntensity)
            : baseFill);

    final borderColor = customBorderColor ?? colors.glassBorder;

    // Colored soft shadows with blue tint
    final defaultShadows = shadows ??
        [
          // Ambient soft blue-tinted shadow
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45 * clampedIntensity)
                : const Color(0xFF1E40AF).withValues(alpha: 0.08 * clampedIntensity),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          // Subtle edge glow
          BoxShadow(
            color: colors.glassEdgeGlow.withValues(
              alpha: colors.glassEdgeGlow.a * clampedIntensity,
            ),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
          // Crisp contact shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ];

    Widget body = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(cornerRadius),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      body = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(cornerRadius),
          splashColor: colors.brandPrimary.withValues(alpha: 0.06),
          highlightColor: Colors.transparent,
          child: body,
        ),
      );
    }

    // Wrap in ClipRRect before BackdropFilter as specified
    Widget glassWidget;
    if (enableBlur && effectiveBlur > 0.0) {
      glassWidget = ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: body,
        ),
      );
    } else {
      glassWidget = ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: body,
      );
    }

    return RepaintBoundary(
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cornerRadius),
          boxShadow: defaultShadows,
        ),
        child: glassWidget,
      ),
    );
  }
}
