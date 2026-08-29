// lib/core/widgets/states/state_custom_painters.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 1. Empty State Illustration: Clean Security Shield with Calm Grid
class EmptyStateIllustration extends StatelessWidget {
  final double size;
  final Color? color;

  const EmptyStateIllustration({super.key, this.size = 180, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = color ?? (isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB));
    final secondary = isDark ? const Color(0xFF10B981) : const Color(0xFF059669);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EmptySecurityPainter(
          primary: primary,
          secondary: secondary,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _EmptySecurityPainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  final bool isDark;

  _EmptySecurityPainter({
    required this.primary,
    required this.secondary,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    // Ambient halo
    final haloPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.08 : 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, haloPaint);

    // Concentric grid rings
    final ringPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.2 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius * 0.8, ringPaint);
    canvas.drawCircle(center, radius * 0.55, ringPaint);
    canvas.drawCircle(center, radius * 0.3, ringPaint);

    // Diagonal grid crosshairs
    final gridLinePaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.12 : 0.1)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(center.dx - radius * 0.85, center.dy),
      Offset(center.dx + radius * 0.85, center.dy),
      gridLinePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.85),
      Offset(center.dx, center.dy + radius * 0.85),
      gridLinePaint,
    );

    // Central Security Shield
    final shieldPath = Path();
    final sw = size.width * 0.32;
    final sh = size.height * 0.38;
    final top = center.dy - sh * 0.5;
    final left = center.dx - sw * 0.5;
    final right = center.dx + sw * 0.5;
    final bottom = center.dy + sh * 0.55;

    shieldPath.moveTo(center.dx, top);
    shieldPath.lineTo(right, top + 12);
    shieldPath.quadraticBezierTo(right, top + sh * 0.55, center.dx, bottom);
    shieldPath.quadraticBezierTo(left, top + sh * 0.55, left, top + 12);
    shieldPath.close();

    final shieldFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primary.withValues(alpha: isDark ? 0.25 : 0.18),
          secondary.withValues(alpha: isDark ? 0.15 : 0.08),
        ],
      ).createShader(Rect.fromLTWH(left, top, sw, sh));
    canvas.drawPath(shieldPath, shieldFillPaint);

    final shieldBorderPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.8 : 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawPath(shieldPath, shieldBorderPaint);

    // Glowing Checkmark inside shield
    final checkPath = Path();
    checkPath.moveTo(center.dx - sw * 0.24, center.dy - 2);
    checkPath.lineTo(center.dx - sw * 0.04, center.dy + sw * 0.18);
    checkPath.lineTo(center.dx + sw * 0.28, center.dy - sw * 0.16);

    final checkPaint = Paint()
      ..color = secondary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0;
    canvas.drawPath(checkPath, checkPaint);

    // Peripheral orbiting nodes (Clean status dots)
    final dotPaint = Paint()..color = secondary.withValues(alpha: 0.8);
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + math.pi / 4;
      final dx = center.dx + radius * 0.8 * math.cos(angle);
      final dy = center.dy + radius * 0.8 * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmptySecurityPainter oldDelegate) =>
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.isDark != isDark;
}

/// 2. Loading State Illustration: Cyber Radar Sweep with Telemetry Rings
class LoadingStateIllustration extends StatefulWidget {
  final double size;
  final Color? color;

  const LoadingStateIllustration({super.key, this.size = 180, this.color});

  @override
  State<LoadingStateIllustration> createState() => _LoadingStateIllustrationState();
}

class _LoadingStateIllustrationState extends State<LoadingStateIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = widget.color ?? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _CyberScanningPainter(
              primary: primary,
              progress: _controller.value,
              isDark: isDark,
            ),
          ),
        );
      },
    );
  }
}

class _CyberScanningPainter extends CustomPainter {
  final Color primary;
  final double progress;
  final bool isDark;

  _CyberScanningPainter({
    required this.primary,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    // Ambient base
    final bgPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.07 : 0.04)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Pulsing outer ripple
    final pulseRadius = radius * (0.4 + (progress % 1.0) * 0.6);
    final pulsePaint = Paint()
      ..color = primary.withValues(alpha: (1.0 - (progress % 1.0)) * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, pulseRadius, pulsePaint);

    // Concentric radar circles
    final ringPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.25 : 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius * 0.85, ringPaint);
    canvas.drawCircle(center, radius * 0.6, ringPaint);
    canvas.drawCircle(center, radius * 0.35, ringPaint);

    // Sweeping Radar Cone
    final sweepAngle = progress * 2 * math.pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          primary.withValues(alpha: 0.0),
          primary.withValues(alpha: isDark ? 0.45 : 0.35),
        ],
        startAngle: 0.0,
        endAngle: math.pi / 2,
        transform: GradientRotation(sweepAngle - math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.85));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.85),
      sweepAngle - math.pi / 2,
      math.pi / 2,
      true,
      sweepPaint,
    );

    // Rotating scanner line
    final scanLinePaint = Paint()
      ..color = primary.withValues(alpha: 0.9)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final lineEnd = Offset(
      center.dx + radius * 0.85 * math.cos(sweepAngle),
      center.dy + radius * 0.85 * math.sin(sweepAngle),
    );
    canvas.drawLine(center, lineEnd, scanLinePaint);

    // Center Core Node
    final centerFill = Paint()..color = primary;
    canvas.drawCircle(center, 5.0, centerFill);
    final centerGlow = Paint()
      ..color = primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, 9.0, centerGlow);
  }

  @override
  bool shouldRepaint(covariant _CyberScanningPainter oldDelegate) => true;
}

/// 3. Error State Illustration: Hexagonal Warning Shield & Glitch Lattice
class ErrorStateIllustration extends StatelessWidget {
  final double size;
  final Color? color;

  const ErrorStateIllustration({super.key, this.size = 180, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final critical = color ?? (isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626));

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexErrorPainter(
          critical: critical,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _HexErrorPainter extends CustomPainter {
  final Color critical;
  final bool isDark;

  _HexErrorPainter({required this.critical, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // Ambient danger halo
    final haloPaint = Paint()
      ..color = critical.withValues(alpha: isDark ? 0.1 : 0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 1.05, haloPaint);

    // Hexagonal Boundary Path
    Path createHexPath(Offset c, double r) {
      final path = Path();
      for (int i = 0; i < 6; i++) {
        final angle = (i * 60) * math.pi / 180 - math.pi / 6;
        final x = c.dx + r * math.cos(angle);
        final y = c.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      return path;
    }

    // Outer and Inner Hexagons
    final outerHex = createHexPath(center, radius * 0.9);
    final innerHex = createHexPath(center, radius * 0.65);

    final hexFillPaint = Paint()
      ..color = critical.withValues(alpha: isDark ? 0.15 : 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawPath(outerHex, hexFillPaint);

    final hexBorderPaint = Paint()
      ..color = critical.withValues(alpha: isDark ? 0.85 : 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawPath(outerHex, hexBorderPaint);

    final innerHexPaint = Paint()
      ..color = critical.withValues(alpha: isDark ? 0.35 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(innerHex, innerHexPaint);

    // Warning Triangle / Exclamation in center
    final triPath = Path();
    final tw = size.width * 0.26;
    final th = size.height * 0.26;
    final top = center.dy - th * 0.55;
    triPath.moveTo(center.dx, top);
    triPath.lineTo(center.dx + tw * 0.5, top + th);
    triPath.lineTo(center.dx - tw * 0.5, top + th);
    triPath.close();

    final triPaint = Paint()
      ..color = critical.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(triPath, triPaint);

    final triBorder = Paint()
      ..color = critical
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(triPath, triBorder);

    // Exclamation Mark
    final markPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy - th * 0.15),
      Offset(center.dx, center.dy + th * 0.12),
      markPaint,
    );
    canvas.drawCircle(Offset(center.dx, center.dy + th * 0.32), 1.8, markPaint);

    // Danger Sparks
    final sparkPaint = Paint()..color = critical.withValues(alpha: 0.7);
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final x = center.dx + radius * 0.9 * math.cos(angle);
      final y = center.dy + radius * 0.9 * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 3, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HexErrorPainter oldDelegate) =>
      oldDelegate.critical != critical || oldDelegate.isDark != isDark;
}

/// 4. No Internet State Illustration: Severed Fiber / Disconnected Antenna
class NoInternetIllustration extends StatelessWidget {
  final double size;
  final Color? color;

  const NoInternetIllustration({super.key, this.size = 180, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = color ?? (isDark ? const Color(0xFFF97316) : const Color(0xFFEA580C));

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _OfflineSatellitePainter(
          primary: primary,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _OfflineSatellitePainter extends CustomPainter {
  final Color primary;
  final bool isDark;

  _OfflineSatellitePainter({required this.primary, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // Ambient offline glow
    final bgPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.08 : 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Disconnected dashed perimeter
    final ringPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.25 : 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, radius * 0.85, ringPaint);

    // Wi-Fi / Satellite Wave Arcs
    final arcPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.75 : 0.85)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.2;

    // 3 Concentric broadcast arcs
    final arcCenter = Offset(center.dx, center.dy + radius * 0.25);
    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: radius * 0.3),
      -math.pi * 0.8,
      math.pi * 0.6,
      false,
      arcPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: radius * 0.55),
      -math.pi * 0.8,
      math.pi * 0.6,
      false,
      arcPaint..color = primary.withValues(alpha: isDark ? 0.55 : 0.6),
    );
    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: radius * 0.8),
      -math.pi * 0.8,
      math.pi * 0.6,
      false,
      arcPaint..color = primary.withValues(alpha: isDark ? 0.35 : 0.4),
    );

    // Base transmitter dot
    final dotPaint = Paint()..color = primary;
    canvas.drawCircle(arcCenter, 4.5, dotPaint);

    // Severing Slash / Strike-through Barrier Line
    final slashPaint = Paint()
      ..color = isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - radius * 0.65, center.dy - radius * 0.65),
      Offset(center.dx + radius * 0.65, center.dy + radius * 0.65),
      slashPaint,
    );

    // Disconnection Nodes
    final breakDotPaint = Paint()
      ..color = isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.65, center.dy - radius * 0.65),
      4.0,
      breakDotPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.65, center.dy + radius * 0.65),
      4.0,
      breakDotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OfflineSatellitePainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.isDark != isDark;
}

/// 5. Slow Network State Illustration: High Latency Wave & Degraded Speedometer
class SlowNetworkIllustration extends StatelessWidget {
  final double size;
  final Color? color;

  const SlowNetworkIllustration({super.key, this.size = 180, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warning = color ?? (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706));

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LatencyGaugePainter(
          warning: warning,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _LatencyGaugePainter extends CustomPainter {
  final Color warning;
  final bool isDark;

  _LatencyGaugePainter({required this.warning, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + size.height * 0.05);
    final radius = size.width * 0.4;

    // Background Arc (Speedometer Track)
    final trackPaint = Paint()
      ..color = warning.withValues(alpha: isDark ? 0.2 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.8,
      math.pi * 1.4,
      false,
      trackPaint,
    );

    // Active Slow / High-Latency Warning Segment
    final activePaint = Paint()
      ..color = warning
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.8,
      math.pi * 0.45,
      false,
      activePaint,
    );

    // Speedometer Needle pointing to low band
    const needleAngle = math.pi * 1.05;
    final needleEnd = Offset(
      center.dx + radius * 0.7 * math.cos(needleAngle),
      center.dy + radius * 0.7 * math.sin(needleAngle),
    );
    final needlePaint = Paint()
      ..color = warning
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 5.0, Paint()..color = warning);

    // High Latency sine-wave packet jitter at bottom
    final wavePath = Path();
    final waveY = center.dy + radius * 0.45;
    final waveStart = center.dx - radius * 0.7;
    wavePath.moveTo(waveStart, waveY);
    for (double x = 0; x <= radius * 1.4; x += 4) {
      final y = waveY + math.sin(x * 0.15) * 6;
      wavePath.lineTo(waveStart + x, y);
    }
    final wavePaint = Paint()
      ..color = warning.withValues(alpha: isDark ? 0.6 : 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _LatencyGaugePainter oldDelegate) =>
      oldDelegate.warning != warning || oldDelegate.isDark != isDark;
}

/// 6. No Search Results Illustration: Encrypted Radar Matrix & Empty Lens
class NoSearchResultsIllustration extends StatelessWidget {
  final double size;
  final Color? color;

  const NoSearchResultsIllustration({super.key, this.size = 180, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = color ?? (isDark ? const Color(0xFF64748B) : const Color(0xFF475569));

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EmptySearchMatrixPainter(
          primary: primary,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _EmptySearchMatrixPainter extends CustomPainter {
  final Color primary;
  final bool isDark;

  _EmptySearchMatrixPainter({required this.primary, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // Encrypted matrix dot grid
    final dotPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.2 : 0.15);
    for (int row = -3; row <= 3; row++) {
      for (int col = -3; col <= 3; col++) {
        final pt = Offset(center.dx + col * 18, center.dy + row * 18);
        if ((pt - center).distance <= radius) {
          canvas.drawCircle(pt, 1.4, dotPaint);
        }
      }
    }

    // Outer Matrix Border
    final boxPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.25 : 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: radius * 1.7, height: radius * 1.7),
        const Radius.circular(16),
      ),
      boxPaint,
    );

    // Magnifying Lens
    final lensCenter = Offset(center.dx - 8, center.dy - 8);
    final lensRadius = radius * 0.36;

    final lensFill = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.18 : 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lensCenter, lensRadius, lensFill);

    final lensBorder = Paint()
      ..color = primary.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(lensCenter, lensRadius, lensBorder);

    // Lens Handle
    final handlePaint = Paint()
      ..color = primary.withValues(alpha: 0.9)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    final handleStart = Offset(
      lensCenter.dx + lensRadius * math.cos(math.pi / 4),
      lensCenter.dy + lensRadius * math.sin(math.pi / 4),
    );
    final handleEnd = Offset(handleStart.dx + 26, handleStart.dy + 26);
    canvas.drawLine(handleStart, handleEnd, handlePaint);

    // Empty '0' or question mark inside lens
    final questionPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final qPath = Path();
    qPath.moveTo(lensCenter.dx - 5, lensCenter.dy - 6);
    qPath.quadraticBezierTo(lensCenter.dx, lensCenter.dy - 12, lensCenter.dx + 5, lensCenter.dy - 6);
    qPath.quadraticBezierTo(lensCenter.dx + 4, lensCenter.dy - 1, lensCenter.dx, lensCenter.dy + 3);
    canvas.drawPath(qPath, questionPaint);
    canvas.drawCircle(Offset(lensCenter.dx, lensCenter.dy + 8), 1.5, Paint()..color = primary);
  }

  @override
  bool shouldRepaint(covariant _EmptySearchMatrixPainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.isDark != isDark;
}

/// 7. Permission Denied State Illustration: Biometric Vault Lock & Security Perimeter
class PermissionDeniedIllustration extends StatelessWidget {
  final double size;
  final Color? color;

  const PermissionDeniedIllustration({super.key, this.size = 180, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = color ?? (isDark ? const Color(0xFFF43F5E) : const Color(0xFFE11D48));

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _VaultAccessLockedPainter(
          primary: primary,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _VaultAccessLockedPainter extends CustomPainter {
  final Color primary;
  final bool isDark;

  _VaultAccessLockedPainter({required this.primary, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // Laser boundary circle
    final haloPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.1 : 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, haloPaint);

    final borderPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.35 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, radius * 0.85, borderPaint);

    // Cryptographic Lock Body
    final lockWidth = size.width * 0.34;
    final lockHeight = size.height * 0.28;
    final lockRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + size.height * 0.07),
      width: lockWidth,
      height: lockHeight,
    );

    final lockFill = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.22 : 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(lockRect, const Radius.circular(12)), lockFill);

    final lockBorder = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawRRect(RRect.fromRectAndRadius(lockRect, const Radius.circular(12)), lockBorder);

    // Lock Shackle (Arch)
    final shacklePath = Path();
    final shackleTop = center.dy - size.height * 0.14;
    final shackleLeft = center.dx - lockWidth * 0.32;
    final shackleRight = center.dx + lockWidth * 0.32;

    shacklePath.moveTo(shackleLeft, lockRect.top + 4);
    shacklePath.lineTo(shackleLeft, shackleTop + 14);
    shacklePath.quadraticBezierTo(shackleLeft, shackleTop, center.dx, shackleTop);
    shacklePath.quadraticBezierTo(shackleRight, shackleTop, shackleRight, shackleTop + 14);
    shacklePath.lineTo(shackleRight, lockRect.top + 4);

    final shacklePaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(shacklePath, shacklePaint);

    // Keyhole / Biometric Core
    final keyholePaint = Paint()..color = primary;
    canvas.drawCircle(Offset(center.dx, lockRect.center.dy - 3), 4.0, keyholePaint);
    final keyholeTail = Path();
    keyholeTail.moveTo(center.dx - 2.5, lockRect.center.dy - 1);
    keyholeTail.lineTo(center.dx + 2.5, lockRect.center.dy - 1);
    keyholeTail.lineTo(center.dx + 1.5, lockRect.center.dy + 8);
    keyholeTail.lineTo(center.dx - 1.5, lockRect.center.dy + 8);
    keyholeTail.close();
    canvas.drawPath(keyholeTail, keyholePaint);
  }

  @override
  bool shouldRepaint(covariant _VaultAccessLockedPainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.isDark != isDark;
}

/// 8. Session Expired State Illustration: Hourglass Countdown & Token Revocation
class SessionExpiredIllustration extends StatelessWidget {
  final double size;
  final Color? color;

  const SessionExpiredIllustration({super.key, this.size = 180, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = color ?? (isDark ? const Color(0xFFA855F7) : const Color(0xFF9333EA));

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ExpiredTokenPainter(
          primary: primary,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _ExpiredTokenPainter extends CustomPainter {
  final Color primary;
  final bool isDark;

  _ExpiredTokenPainter({required this.primary, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // Ambient glow
    final bgPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.09 : 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Outer Dotted Clock Ring
    final clockBorder = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.3 : 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, radius * 0.85, clockBorder);

    // Hourglass Shape
    final hgPath = Path();
    final hw = size.width * 0.26;
    final hh = size.height * 0.38;
    final top = center.dy - hh * 0.5;
    final bottom = center.dy + hh * 0.5;

    hgPath.moveTo(center.dx - hw * 0.5, top);
    hgPath.lineTo(center.dx + hw * 0.5, top);
    hgPath.lineTo(center.dx + 3, center.dy);
    hgPath.lineTo(center.dx + hw * 0.5, bottom);
    hgPath.lineTo(center.dx - hw * 0.5, bottom);
    hgPath.lineTo(center.dx - 3, center.dy);
    hgPath.close();

    final hgFill = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.18 : 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawPath(hgPath, hgFill);

    final hgBorder = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(hgPath, hgBorder);

    // Fallen sand at bottom
    final sandPath = Path();
    sandPath.moveTo(center.dx - hw * 0.35, bottom - 2);
    sandPath.lineTo(center.dx + hw * 0.35, bottom - 2);
    sandPath.quadraticBezierTo(center.dx, bottom - hh * 0.25, center.dx - hw * 0.35, bottom - 2);
    sandPath.close();
    canvas.drawPath(sandPath, Paint()..color = primary.withValues(alpha: 0.7));

    // Expiry Slash
    final strikePaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - radius * 0.55, center.dy - radius * 0.55),
      Offset(center.dx + radius * 0.55, center.dy + radius * 0.55),
      strikePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ExpiredTokenPainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.isDark != isDark;
}

/// 9. Success State Illustration: Glowing Emerald Shield with Confetti Particle Field
class SuccessStateIllustration extends StatelessWidget {
  final double size;
  final Color? color;

  const SuccessStateIllustration({super.key, this.size = 180, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emerald = color ?? (isDark ? const Color(0xFF22C55E) : const Color(0xFF16A34A));

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SuccessShieldPainter(
          emerald: emerald,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _SuccessShieldPainter extends CustomPainter {
  final Color emerald;
  final bool isDark;

  _SuccessShieldPainter({required this.emerald, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // Glowing aura rings
    final glowPaint = Paint()
      ..color = emerald.withValues(alpha: isDark ? 0.12 : 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 1.05, glowPaint);

    final ringPaint = Paint()
      ..color = emerald.withValues(alpha: isDark ? 0.35 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, radius * 0.85, ringPaint);

    // Verified Success Badge Shield
    final shieldPath = Path();
    final sw = size.width * 0.34;
    final sh = size.height * 0.42;
    final top = center.dy - sh * 0.5;
    final left = center.dx - sw * 0.5;
    final right = center.dx + sw * 0.5;
    final bottom = center.dy + sh * 0.55;

    shieldPath.moveTo(center.dx, top);
    shieldPath.lineTo(right, top + 14);
    shieldPath.quadraticBezierTo(right, top + sh * 0.6, center.dx, bottom);
    shieldPath.quadraticBezierTo(left, top + sh * 0.6, left, top + 14);
    shieldPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          emerald.withValues(alpha: isDark ? 0.35 : 0.25),
          emerald.withValues(alpha: isDark ? 0.15 : 0.08),
        ],
      ).createShader(Rect.fromLTWH(left, top, sw, sh));
    canvas.drawPath(shieldPath, fillPaint);

    final borderPaint = Paint()
      ..color = emerald
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;
    canvas.drawPath(shieldPath, borderPaint);

    // Thick animated checkmark
    final checkPath = Path();
    checkPath.moveTo(center.dx - sw * 0.26, center.dy - 2);
    checkPath.lineTo(center.dx - sw * 0.04, center.dy + sw * 0.2);
    checkPath.lineTo(center.dx + sw * 0.3, center.dy - sw * 0.18);

    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.8;
    canvas.drawPath(checkPath, checkPaint);

    // Floating verification nodes
    final sparkPaint = Paint()..color = emerald.withValues(alpha: 0.85);
    final offsets = [
      Offset(center.dx - radius * 0.7, center.dy - radius * 0.5),
      Offset(center.dx + radius * 0.7, center.dy - radius * 0.4),
      Offset(center.dx - radius * 0.6, center.dy + radius * 0.55),
      Offset(center.dx + radius * 0.65, center.dy + radius * 0.5),
    ];
    for (final pt in offsets) {
      canvas.drawCircle(pt, 3.2, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SuccessShieldPainter oldDelegate) =>
      oldDelegate.emerald != emerald || oldDelegate.isDark != isDark;
}
