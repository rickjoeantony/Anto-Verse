// lib/features/events/presentation/widgets/event_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/glass_card.dart';
import '../../../../core/widgets/protocol_icon.dart';
import '../../domain/security_event.dart';
import '../../domain/severity_level.dart';

/// Premium clean Event Card — no heavy rail bars, AI-grade surface.
class EventCard extends StatelessWidget {
  final SecurityEvent event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '$h:$m:$s · $d ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = _formatTime(event.timestamp);

    final severityColor = switch (event.severity) {
      SeverityLevel.critical => colors.critical,
      SeverityLevel.high     => colors.high,
      SeverityLevel.warning  => colors.warning,
      SeverityLevel.low      => colors.brandPrimary,
      SeverityLevel.healthy || SeverityLevel.success => colors.success,
      SeverityLevel.info     => colors.brandSecondary,
    };

    final severityLabel = switch (event.severity) {
      SeverityLevel.critical => 'Critical',
      SeverityLevel.high     => 'High',
      SeverityLevel.warning  => 'Warning',
      SeverityLevel.low      => 'Low',
      SeverityLevel.healthy || SeverityLevel.success => 'Healthy',
      SeverityLevel.info     => 'Info',
    };

    return GlassCard(
      borderRadius: 22.0,
      padding: const EdgeInsets.all(16.0),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: dot + severity + protocol + time ─────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Glowing severity dot
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: severityColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: severityColor.withValues(alpha: 0.55),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),

              // Severity label — plain text, tinted
              Text(
                severityLabel,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: severityColor,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(width: 10),

              // Protocol badge
              ProtocolBadge(protocol: event.protocol, isCompact: true),

              const Spacer(),

              // Timestamp — right-aligned, muted
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 10.5,
                  color: colors.textSecondary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Event classification title ─────────────────────────────
          Text(
            event.classification,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              fontSize: 15,
              letterSpacing: -0.3,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 10),

          // ── Bottom row: source + action link ──────────────────────
          Row(
            children: [
              Icon(
                Icons.public_rounded,
                size: 13,
                color: colors.textSecondary.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${event.sourceIp}  ·  ${event.country}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary.withValues(alpha: isDark ? 0.7 : 0.8),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.brandPrimary,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 15,
                color: colors.brandPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
