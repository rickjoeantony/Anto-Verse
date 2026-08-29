// lib/core/widgets/glass/liquid_glass_sheet.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Layer 5 Liquid Glass Modal Bottom Sheet with spring physics,
/// high frosted blur (38px), top specular rim, and drag handle.
class LiquidGlassSheet extends StatelessWidget {
  final Widget child;
  final double cornerRadius;
  final double intensity;
  final EdgeInsetsGeometry padding;
  final bool showHandle;
  final Color? customFillColor;

  const LiquidGlassSheet({
    super.key,
    required this.child,
    this.cornerRadius = 32.0,
    this.intensity = 1.0,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 28),
    this.showHandle = true,
    this.customFillColor,
  });

  /// Helper to show a modal liquid glass bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    double cornerRadius = 32.0,
    double intensity = 1.0,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      elevation: 0,
      builder: (ctx) => LiquidGlassSheet(
        cornerRadius: cornerRadius,
        intensity: intensity,
        child: builder(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clampedIntensity = intensity.clamp(0.0, 1.0);
    final effectiveBlur = 38.0 * clampedIntensity;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(cornerRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.65)
                  : const Color(0xFF2563EB).withValues(alpha: 0.16),
              blurRadius: 40,
              spreadRadius: 4,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(cornerRadius),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: effectiveBlur,
              sigmaY: effectiveBlur,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: customFillColor ?? colors.glassStrongFill,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(cornerRadius),
                ),
                border: Border(
                  top: BorderSide(color: colors.glassBorder, width: 1.2),
                  left: BorderSide(color: colors.glassBorder, width: 0.5),
                  right: BorderSide(color: colors.glassBorder, width: 0.5),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Stack(
                  children: [
                    // Specular top highlight line
                    Positioned(
                      top: 0,
                      left: cornerRadius * 0.8,
                      right: cornerRadius * 0.8,
                      height: 1.2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.glassInnerHighlight.withValues(alpha: 0.0),
                              colors.glassInnerHighlight,
                              colors.glassInnerHighlight.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Sheet content with optional drag handle
                    Padding(
                      padding: padding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showHandle) ...[
                            Center(
                              child: Container(
                                width: 36,
                                height: 4.5,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.28)
                                      : Colors.black.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                          Flexible(child: child),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
