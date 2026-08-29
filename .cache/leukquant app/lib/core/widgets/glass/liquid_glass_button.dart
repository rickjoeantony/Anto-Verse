// lib/core/widgets/glass/liquid_glass_button.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

/// Tactile Liquid Glass Button with spring scale micro-interaction,
/// clean organic border, and high-performance blur.
class LiquidGlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final double height;
  final double cornerRadius;
  final double intensity;
  final EdgeInsetsGeometry padding;
  final Color? customColor;

  const LiquidGlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isPrimary = true,
    this.height = 50.0,
    this.cornerRadius = 16.0,
    this.intensity = 1.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.customColor,
  });

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null;
    final clampedIntensity = widget.intensity.clamp(0.0, 1.0);

    final primaryGradient = LinearGradient(
      colors: [
        widget.customColor ?? colors.brandPrimary,
        (widget.customColor ?? colors.brandPrimary).withValues(alpha: 0.90),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final decoration = BoxDecoration(
      gradient: widget.isPrimary ? primaryGradient : null,
      color: widget.isPrimary ? null : colors.glassStrongFill,
      borderRadius: BorderRadius.circular(widget.cornerRadius),
      border: Border.all(
        color: widget.isPrimary
            ? Colors.white.withValues(alpha: isDark ? 0.30 : 0.50)
            : colors.glassBorder,
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: widget.isPrimary
              ? (widget.customColor ?? colors.brandPrimary)
                  .withValues(alpha: (isDark ? 0.35 : 0.22) * clampedIntensity)
              : (isDark
                  ? Colors.black.withValues(alpha: 0.25 * clampedIntensity)
                  : const Color(0xFF2563EB)
                      .withValues(alpha: 0.08 * clampedIntensity)),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: isEnabled
            ? () {
                HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.cornerRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 16 * clampedIntensity,
                sigmaY: 16 * clampedIntensity,
              ),
              child: AnimatedOpacity(
                opacity: isEnabled ? 1.0 : 0.45,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  height: widget.height,
                  padding: widget.padding,
                  decoration: decoration,
                  alignment: Alignment.center,
                  child: DefaultTextStyle(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: widget.isPrimary
                          ? Colors.white
                          : colors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
