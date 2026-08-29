// lib/core/widgets/glass/liquid_glass_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'liquid_glass_container.dart';

/// Layer 3 Interactive Liquid Glass Card with smooth spring scale on tap,
/// specular highlights, and adaptive translucency.
class LiquidGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double cornerRadius;
  final double intensity;
  final double blurSigma;
  final bool enableBlur;
  final bool isStrongGlass;
  final VoidCallback? onTap;
  final Color? customFillColor;
  final Color? customBorderColor;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18.0),
    this.margin,
    this.cornerRadius = 24.0,
    this.intensity = 1.0,
    this.blurSigma = 20.0,
    this.enableBlur = true,
    this.isStrongGlass = false,
    this.onTap,
    this.customFillColor,
    this.customBorderColor,
  });

  @override
  State<LiquidGlassCard> createState() => _LiquidGlassCardState();
}

class _LiquidGlassCardState extends State<LiquidGlassCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Widget card = LiquidGlassContainer(
      padding: widget.padding,
      margin: widget.margin,
      cornerRadius: widget.cornerRadius,
      intensity: widget.intensity,
      blurSigma: widget.blurSigma,
      enableBlur: widget.enableBlur,
      isStrongGlass: widget.isStrongGlass,
      customFillColor: widget.customFillColor,
      customBorderColor: widget.customBorderColor,
      child: widget.child,
    );

    if (widget.onTap != null) {
      card = GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: card,
        ),
      );
    }

    return card;
  }
}
