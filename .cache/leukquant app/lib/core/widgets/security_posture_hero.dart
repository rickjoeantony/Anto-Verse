// lib/core/widgets/security_posture_hero.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated CustomPainter drawing futuristic concentric radar rings
class _SecurityRadarPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final double animationValue;

  _SecurityRadarPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.86, size.height * 0.52);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Concentric calm radar rings with subtle pulse expansion
    for (int i = 0; i < 4; i++) {
      final baseR = 20.0 + (i * 22.0);
      final dynamicR = baseR + (animationValue * 4.0);
      final alpha = (0.14 - (i * 0.03)).clamp(0.02, 0.16);

      paint.color = primaryColor.withValues(alpha: alpha);
      canvas.drawCircle(center, dynamicR, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SecurityRadarPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.animationValue != animationValue;
}

/// Security Posture Hero Card with curved glass/dark surface and radar canvas.
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

class _SecurityPostureHeroState extends State<SecurityPostureHero> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
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
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isReducedMotion = MediaQuery.disableAnimationsOf(context);

    final (String cardTitle, String statusBadge, String subtitle, Color accentColor, IconData statusIcon) = () {
      if (widget.hasActiveIncident) {
        return (
          'Security Attention Required',
          'Action Needed',
          'High-risk activity detected. Review active incidents for recommended mitigations.',
          colors.critical,
          Icons.shield_outlined,
        );
      }

      if (!widget.isBackendConnected) {
        return (
          'Ghost-Net Deployment',
          'Awaiting Signals',
          'Connect an active Ghost-Net deployment to receive verified security telemetry.',
          colors.brandPrimary,
          Icons.sensors_outlined,
        );
      }

      return (
        'Ghost-Net Deployment',
        'Connected',
        'Last verified telemetry: ${widget.lastTelemetryTime ?? "Active now"} (Region: ${widget.region ?? "Primary"}).',
        colors.success,
        Icons.verified_user_outlined,
      );
    }();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0C101D),
                  const Color(0xFF000000),
                ]
              : [
                  const Color(0xFFFFFFFF),
                  const Color(0xFFEFF6FF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: widget.hasActiveIncident
              ? colors.critical.withValues(alpha: 0.4)
              : (isDark
                  ? colors.brandPrimary.withValues(alpha: 0.22)
                  : colors.brandPrimary.withValues(alpha: 0.16)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.hasActiveIncident
                ? colors.critical.withValues(alpha: 0.12)
                : (isDark ? const Color(0x33000000) : const Color(0x142563EB)),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _radarController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _SecurityRadarPainter(
                        primaryColor: accentColor,
                        accentColor: colors.brandSecondary,
                        animationValue: isReducedMotion ? 0.0 : _radarController.value,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                          ),
                          child: Icon(statusIcon, size: 20, color: accentColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cardTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                              letterSpacing: -0.3,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withValues(alpha: 0.6),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                statusBadge,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                        height: 1.45,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
