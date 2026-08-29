// lib/features/events/presentation/widgets/event_details_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/liquid_glass_badge.dart';
import '../../../../core/widgets/glass/liquid_glass_button.dart';
import '../../../../core/widgets/glass/liquid_glass_sheet.dart';
import '../../domain/security_event.dart';
import '../../domain/severity_level.dart';
import '../../providers/events_provider.dart';
import 'ip_sessions_sheet.dart';

/// Layer 5 Liquid Glass Bottom Sheet explaining an individual security event.
class EventDetailsSheet extends ConsumerWidget {
  final SecurityEvent event;

  const EventDetailsSheet({
    super.key,
    required this.event,
  });

  static void show(BuildContext context, SecurityEvent event) {
    LiquidGlassSheet.show(
      context: context,
      isScrollControlled: true,
      builder: (_) => EventDetailsSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedTime =
        '${event.timestamp.toIso8601String().substring(0, 19).replaceAll("T", " ")} UTC';

    final severityColor = switch (event.severity) {
      SeverityLevel.critical => colors.critical,
      SeverityLevel.high => colors.high,
      SeverityLevel.warning => colors.warning,
      SeverityLevel.low => colors.brandPrimary,
      SeverityLevel.healthy => colors.success,
      SeverityLevel.success => colors.success,
      SeverityLevel.info => colors.brandSecondary,
    };

    final severityLabel = switch (event.severity) {
      SeverityLevel.critical => 'Critical (Level 5)',
      SeverityLevel.high => 'High (Level 4)',
      SeverityLevel.warning => 'Warning (Level 3)',
      SeverityLevel.low => 'Low (Level 2)',
      SeverityLevel.healthy => 'Healthy',
      SeverityLevel.success => 'Healthy',
      SeverityLevel.info => 'Info (Level 1)',
    };

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title & Close
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                LiquidGlassBadge(
                  label: severityLabel,
                  color: severityColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event.id,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.06),
                      border: Border.all(
                        color: colors.glassBorder,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),

          // Scrollable Content
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // 1. What Happened?
                Text(
                  'What Happened?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.brandPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.type,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'A security telemetry signal was observed from source ${event.sourceIp} (${event.country}) targeting honeypot ${event.honeypot}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Sanitized Payload Preview (Read-only, never executed)
                Text(
                  'Sanitized Payload Preview',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.brandPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E222A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border.withValues(alpha: 0.8)),
                  ),
                  child: SelectableText(
                    event.payload,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Captured Credentials (Masked Only)
                Text(
                  'Captured Credentials',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.brandPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.credentials.isNotEmpty)
                        ...event.credentials.map(
                          (c) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text('User: ', style: TextStyle(fontSize: 12.5, color: colors.textSecondary)),
                                Text(
                                  c.username,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('Password: ', style: TextStyle(fontSize: 12.5, color: colors.textSecondary)),
                                Text(
                                  '••••••••',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: colors.critical,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Text(
                          'None recorded for this interaction',
                          style: TextStyle(fontSize: 12.5, color: colors.textSecondary),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 4. Telemetry Metrics
                Text(
                  'Telemetry Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.brandPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Timestamp', formattedTime, colors),
                _buildDetailRow('Source IP', event.sourceIp, colors),
                _buildDetailRow('Country', '${event.country} (${event.countryCode})', colors),
                _buildDetailRow('Threat Level', '${event.threatLevel} / 5', colors),
                _buildDetailRow('Abuse Score', '${event.abuseScore.toStringAsFixed(1)} %', colors),
                _buildDetailRow('Honeypot Sensor', event.honeypot, colors),
                _buildDetailRow('Reviewed Status', event.reviewed ? 'Reviewed' : 'Pending SOC Review', colors),
                const SizedBox(height: 18),

                // 5. Actions: View IP Sessions + Toggle Reviewed
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          IpSessionsSheet.show(context, event.sourceIp);
                        },
                        icon: const Icon(Icons.history_edu_rounded, size: 16),
                        label: const Text('IP Sessions'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: LiquidGlassButton(
                        height: 44,
                        cornerRadius: 14,
                        onPressed: () async {
                          final newStatus = !event.reviewed;
                          await ref.read(eventsNotifierProvider.notifier).markReviewed(event.id, newStatus);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              event.reviewed ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              event.reviewed ? 'Mark Unreviewed' : 'Mark Reviewed',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, color: colors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              fontFamily: label == 'Source IP' ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }
}
