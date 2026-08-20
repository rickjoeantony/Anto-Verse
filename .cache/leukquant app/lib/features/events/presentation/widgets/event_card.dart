// lib/features/events/presentation/widgets/event_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/protocol_icon.dart';
import '../../../../core/widgets/severity_badge.dart';
import '../../domain/security_event.dart';
import '../../domain/severity_level.dart';

/// Highly premium customer-friendly card representing a single security event.
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dt.month - 1];
    return '$h:$m:$s · $d $month';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = _formatTime(event.timestamp);

    final severityColor = switch (event.severity) {
      SeverityLevel.critical => colors.critical,
      SeverityLevel.high => colors.high,
      SeverityLevel.warning => colors.warning,
      SeverityLevel.low => colors.brandPrimary,
      SeverityLevel.healthy || SeverityLevel.success => colors.success,
      SeverityLevel.info => colors.brandSecondary,
    };

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? colors.border.withValues(alpha: 0.85)
              : colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0x0C2563EB),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Severity Accent Rail
              Container(
                width: 4.5,
                color: severityColor,
              ),

              // Card Content
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Severity Badge + Protocol Badge + Timestamp
                          Row(
                            children: [
                              SeverityBadge(
                                severity: event.severity,
                                compact: true,
                              ),
                              const SizedBox(width: 8),
                              ProtocolBadge(
                                protocol: event.protocol,
                                isCompact: true,
                              ),
                              const Spacer(),
                              Text(
                                timeStr,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Plain Language Event Title
                          Text(
                            event.classification,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Source Origin & Action Chevron
                          Row(
                            children: [
                              Icon(Icons.public_rounded, size: 14, color: colors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                '${event.sourceIp} (${event.country})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'View details',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colors.brandPrimary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.chevron_right_rounded, size: 16, color: colors.brandPrimary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
