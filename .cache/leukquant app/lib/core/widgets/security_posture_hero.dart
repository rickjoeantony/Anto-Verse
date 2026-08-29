// lib/core/widgets/security_posture_hero.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass/glass_container.dart';

/// Subtle animated radar rings drawn in the background of the hero card.
class _SecurityRadarPainter extends CustomPainter {
  final Color primaryColor;
  final double animationValue;

  _SecurityRadarPainter({
    required this.primaryColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.90, size.height * 0.48);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    for (int i = 0; i < 4; i++) {
      final baseR = 18.0 + (i * 24.0);
      final dynamicR = baseR + (animationValue * 6.0);
      final alpha = (0.12 - (i * 0.025)).clamp(0.01, 0.16);
      paint.color = primaryColor.withValues(alpha: alpha);
      canvas.drawCircle(center, dynamicR, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SecurityRadarPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.animationValue != animationValue;
}

/// Ultra-luxury Security Posture Hero Card — AI-grade, specular glass, no clunky boxes.
class SecurityPostureHero extends StatefulWidget {
  final bool isBackendConnected;
  final bool hasActiveIncident;
  final String? lastTelemetryTime;
  final String? region;

  const SecurityPostureHero({
    super.key,
    required this.isBackendConnected,
    this.hasActiveIncident = false,
    this.lastTelemetryTime,
    this.region,
  });

  @override
  State<SecurityPostureHero> createState() => _SecurityPostureHeroState();
}

class _SecurityPostureHeroState extends State<SecurityPostureHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isReducedMotion = MediaQuery.disableAnimationsOf(context);

    final (
      String cardTitle,
      String statusLabel,
      Color statusColor,
      IconData statusIcon,
      String subtitle,
    ) = () {
      if (widget.hasActiveIncident) {
        return (
          'Security Attention Required',
          'Review Required',
          colors.warning,
          Icons.shield_outlined,
          'Active threat signal detected in monitored cluster. Automated containment active.',
        );
      }
      if (!widget.isBackendConnected) {
        return (
          'Perimeter Posture',
          'Awaiting Signals',
          colors.brandPrimary,
          Icons.sensors_outlined,
          'Sensor fleet listening on decoy perimeter. Zero anomalous breaches logged.',
        );
      }
      return (
        'Perimeter Posture',
        'All Clear · Optimal',
        colors.success,
        Icons.verified_user_outlined,
        'Last telemetry: ${widget.lastTelemetryTime ?? "Active now"}  ·  Region: ${widget.region ?? "Global"}',
      );
    }();

    return GlassContainer(
      borderRadius: 26.0,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: Stack(
        children: [
          // ── Background Ambient Radar Shimmer ─────────────────────
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _radarController,
                builder: (context, _) => CustomPaint(
                  isComplex: true,
                  painter: _SecurityRadarPainter(
                    primaryColor: statusColor,
                    animationValue: isReducedMotion ? 0.0 : _radarController.value,
                  ),
                ),
              ),
            ),
          ),

          // ── Card Content ─────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top Meta Status Row ──────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Luminous Glowing Status Beacon
                  Container(
                    width: 7.5,
                    height: 7.5,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.70),
                          blurRadius: 9,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    statusIcon,
                    size: 19,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.28)
                        : Colors.black.withValues(alpha: 0.16),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Main Hero Title ──────────────────────────────────
              Text(
                cardTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22.5,
                  color: colors.textPrimary,
                  letterSpacing: -0.7,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // ── Subtitle Details ─────────────────────────────────
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  color: colors.textSecondary.withValues(alpha: isDark ? 0.80 : 0.85),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
