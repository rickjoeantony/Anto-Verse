import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Onboarding Illustration for Page 1: Observe ("See suspicious activity early").
class ObserveIllustration extends StatelessWidget {
  final double size;

  const ObserveIllustration({super.key, this.size = 240});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ObservePainter(
          primary: colors.brandPrimary,
          secondary: colors.brandSecondary,
          soft: colors.brandPrimarySoft,
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

class _ObservePainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  final Color soft;
  final bool isDark;

  _ObservePainter({
    required this.primary,
    required this.secondary,
    required this.soft,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.width * 0.44;

    // 1. Soft ambient background circle
    final bgPaint = Paint()
      ..color = isDark ? primary.withOpacity(0.08) : soft.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Concentric radar sweep rings
    final ringPaint = Paint()
      ..color = primary.withOpacity(isDark ? 0.2 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.75, ringPaint);
    canvas.drawCircle(center, radius * 0.5, ringPaint);
    canvas.drawCircle(center, radius * 0.25, ringPaint);

    // 3. Radar sweep arc
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          primary.withOpacity(0.0),
          primary.withOpacity(0.3),
        ],
        startAngle: 0.0,
        endAngle: math.pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.75));
    canvas.drawCircle(center, radius * 0.75, sweepPaint);

    // 4. Central Ghost-Net Decoy Node
    final nodePaint = Paint()
      ..color = primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 16, nodePaint);

    final innerDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, innerDot);

    // 5. Decoy sensor perimeter nodes
    final angles = [0.0, math.pi * 0.6, math.pi * 1.2, math.pi * 1.7];
    for (int i = 0; i < angles.length; i++) {
      final angle = angles[i];
      final nodePos = center + Offset(math.cos(angle) * radius * 0.65, math.sin(angle) * radius * 0.65);
      
      // Connector ray
      final rayPaint = Paint()
        ..color = secondary.withOpacity(0.5)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center, nodePos, rayPaint);

      // Node circle
      final subNodePaint = Paint()
        ..color = secondary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(nodePos, 8, subNodePaint);

      final subNodeInner = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(nodePos, 3, subNodeInner);
    }
  }

  @override
  bool shouldRepaint(covariant _ObservePainter oldDelegate) => false;
}

/// Onboarding Illustration for Page 2: Understand ("Understand every security event").
class UnderstandIllustration extends StatelessWidget {
  final double size;

  const UnderstandIllustration({super.key, this.size = 240});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _UnderstandPainter(
          primary: colors.brandPrimary,
          secondary: colors.brandSecondary,
          warning: colors.warning,
          soft: colors.brandPrimarySoft,
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

class _UnderstandPainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  final Color warning;
  final Color soft;
  final bool isDark;

  _UnderstandPainter({
    required this.primary,
    required this.secondary,
    required this.warning,
    required this.soft,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final w = size.width;
    final h = size.height;

    // 1. Soft background rounded pill
    final bgRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w * 0.88, height: h * 0.78),
      const Radius.circular(28),
    );
    final bgPaint = Paint()
      ..color = isDark ? primary.withOpacity(0.08) : soft.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bgRRect, bgPaint);

    // 2. Timeline cards stack
    final cardW = w * 0.68;
    final cardH = 34.0;

    final cards = [
      {'offsetY': -40.0, 'color': primary, 'label': 'SSH Anomaly Detected', 'badge': secondary},
      {'offsetY': 6.0, 'color': warning, 'label': 'Canary Token Triggered', 'badge': warning},
      {'offsetY': 52.0, 'color': secondary, 'label': 'Action Recommended', 'badge': primary},
    ];

    for (final card in cards) {
      final cardCenter = Offset(center.dx, center.dy + (card['offsetY'] as double));
      final cardRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: cardCenter, width: cardW, height: cardH),
        const Radius.circular(10),
      );

      // Card surface
      final surfacePaint = Paint()
        ..color = isDark ? const Color(0xFF1E293B) : Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRRect(cardRect, surfacePaint);

      // Card border
      final borderPaint = Paint()
        ..color = (card['color'] as Color).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRRect(cardRect, borderPaint);

      // Left severity dot
      final dotPaint = Paint()
        ..color = card['color'] as Color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cardCenter.dx - cardW * 0.4, cardCenter.dy), 5, dotPaint);

      // Line placeholders
      final textLine = Paint()
        ..color = isDark ? Colors.white70 : const Color(0xFF334155)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cardCenter.dx - cardW * 0.28, cardCenter.dy),
        Offset(cardCenter.dx + cardW * 0.15, cardCenter.dy),
        textLine,
      );

      // Right tag
      final tagPaint = Paint()
        ..color = (card['badge'] as Color).withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cardCenter.dx + cardW * 0.32, cardCenter.dy), width: 26, height: 14),
          const Radius.circular(4),
        ),
        tagPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _UnderstandPainter oldDelegate) => false;
}

/// Onboarding Illustration for Page 3: Act ("Act with confidence").
class ActIllustration extends StatelessWidget {
  final double size;

  const ActIllustration({super.key, this.size = 240});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ActPainter(
          primary: colors.brandPrimary,
          secondary: colors.brandSecondary,
          success: colors.success,
          soft: colors.brandPrimarySoft,
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

class _ActPainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  final Color success;
  final Color soft;
  final bool isDark;

  _ActPainter({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.soft,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final w = size.width;
    final h = size.height;

    // 1. Soft background concentric shield geometry
    final bgPaint = Paint()
      ..color = isDark ? primary.withOpacity(0.08) : soft.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w * 0.44, bgPaint);

    // 2. Verified Shield Path
    final shieldPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shieldPath = Path()
      ..moveTo(center.dx, center.dy - 50)
      ..lineTo(center.dx + 44, center.dy - 28)
      ..lineTo(center.dx + 44, center.dy + 14)
      ..cubicTo(center.dx + 44, center.dy + 42, center.dx, center.dy + 56, center.dx, center.dy + 56)
      ..cubicTo(center.dx, center.dy + 56, center.dx - 44, center.dy + 42, center.dx - 44, center.dy + 14)
      ..lineTo(center.dx - 44, center.dy - 28)
      ..close();

    canvas.drawPath(shieldPath, shieldPaint);

    // Inner shield fill
    final fillPaint = Paint()
      ..color = primary.withOpacity(isDark ? 0.2 : 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shieldPath, fillPaint);

    // 3. Central checkmark
    final checkPaint = Paint()
      ..color = secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path()
      ..moveTo(center.dx - 16, center.dy + 2)
      ..lineTo(center.dx - 4, center.dy + 14)
      ..lineTo(center.dx + 18, center.dy - 10);

    canvas.drawPath(checkPath, checkPaint);

    // 4. Broadcasting verified pulses
    final pulsePaint = Paint()
      ..color = secondary.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx + 52, center.dy - 10), radius: 14),
      -math.pi * 0.4,
      math.pi * 0.8,
      false,
      pulsePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx - 52, center.dy - 10), radius: 14),
      math.pi * 0.6,
      math.pi * 0.8,
      false,
      pulsePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ActPainter oldDelegate) => false;
}
