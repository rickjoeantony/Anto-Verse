import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Ambient canvas background rendering soft blue waves and subtle dot grid matrices.
class AmbientBackground extends StatelessWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _AmbientWavePainter(
              waveColor: isDark
                  ? const Color(0xFF1E293B).withOpacity(0.5)
                  : const Color(0xFFDBEAFE).withOpacity(0.55),
              dotColor: isDark
                  ? const Color(0xFF334155).withOpacity(0.4)
                  : const Color(0xFF93C5FD).withOpacity(0.4),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _AmbientWavePainter extends CustomPainter {
  final Color waveColor;
  final Color dotColor;

  _AmbientWavePainter({
    required this.waveColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Top-left corner organic blue curve
    final topLeftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.45, 0)
      ..cubicTo(w * 0.35, h * 0.12, w * 0.15, h * 0.18, 0, h * 0.15)
      ..close();

    final wavePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(topLeftPath, wavePaint);

    // 2. Bottom-right corner organic blue wave
    final botRightPath = Path()
      ..moveTo(w, h * 0.72)
      ..cubicTo(w * 0.75, h * 0.78, w * 0.65, h * 0.9, w * 0.60, h)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(botRightPath, wavePaint);

    // 3. Subtle decorative dot grid matrix (Top-Right)
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    const dotSpacing = 14.0;
    const dotRadius = 1.8;

    // Top-Right Matrix
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 5; c++) {
        final x = w - 85 + (c * dotSpacing);
        final y = 25 + (r * dotSpacing);
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }

    // Bottom-Left Matrix
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        final x = 25 + (c * dotSpacing);
        final y = h - 110 + (r * dotSpacing);
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientWavePainter oldDelegate) => false;
}
