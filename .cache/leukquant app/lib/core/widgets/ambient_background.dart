// lib/core/widgets/ambient_background.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Original "Liquid Glass" static ambient background canvas.
///
/// Principles:
/// - "Light behind glass" effect with layered static radial gradients
/// - Blurred large glow circles behind top, mid-card, and bottom areas
/// - Very subtle static micro-grid pattern for depth perception
/// - RepaintBoundary cached with zero continuous GPU movement
/// - No particles, no matrix, no neon
class AmbientBackground extends StatelessWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // ── GPU-Cached Static Liquid Glass Ambient Background ─────────
        Positioned.fill(
          child: RepaintBoundary(
            child: Stack(
              children: [
                // 1. Base Gradient Canvas (Calm & Clean)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? const [
                                Color(0xFF0B1020), // Deep Navy Base
                                Color(0xFF0E1428),
                                Color(0xFF0B1020),
                              ]
                            : const [
                                Color(0xFFF2F6FF), // Very Light Blue Base
                                Color(0xFFEFF4FE),
                                Color(0xFFF2F6FF),
                              ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // 2. Top-Left Primary Blue Ambient Glow Circle (#2563EB)
                Positioned(
                  top: -90,
                  left: -70,
                  width: 440,
                  height: 440,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.backgroundGlow1,
                          colors.backgroundGlow1.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Top-Right Secondary Teal Ambient Glow Circle
                Positioned(
                  top: 70,
                  right: -90,
                  width: 400,
                  height: 400,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.backgroundGlow2,
                          colors.backgroundGlow2.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Center-Behind-Cards Soft Ambient Light Fill
                Positioned(
                  top: 240,
                  left: 20,
                  right: 20,
                  height: 380,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(120),
                      gradient: RadialGradient(
                        radius: 0.9,
                        colors: [
                          colors.backgroundGlow1.withValues(
                            alpha: isDark ? 0.09 : 0.06,
                          ),
                          colors.backgroundGlow1.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // 5. Bottom-Left Soft Indigo Accent Glow Circle
                Positioned(
                  bottom: 80,
                  left: -80,
                  width: 380,
                  height: 380,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (isDark
                                  ? const Color(0xFF60A5FA)
                                  : const Color(0xFF2563EB))
                              .withValues(alpha: isDark ? 0.08 : 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 6. Bottom-Right Teal Soft Orb
                Positioned(
                  bottom: -60,
                  right: -60,
                  width: 340,
                  height: 340,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.backgroundGlow2.withValues(
                            alpha: isDark ? 0.09 : 0.06,
                          ),
                          colors.backgroundGlow2.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // 7. Very Subtle Static Pattern Grid (Depth Cue)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SubtleStaticPatternPainter(
                      dotColor: isDark
                          ? Colors.white.withValues(alpha: 0.025)
                          : const Color(0xFF2563EB).withValues(alpha: 0.03),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Content Layer ──────────────────────────────────────────
        child,
      ],
    );
  }
}

class _SubtleStaticPatternPainter extends CustomPainter {
  final Color dotColor;

  _SubtleStaticPatternPainter({required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    const dotRadius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SubtleStaticPatternPainter oldDelegate) =>
      oldDelegate.dotColor != dotColor;
}
