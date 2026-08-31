// lib/features/events/presentation/widgets/event_details_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/liquid_glass_sheet.dart';
import '../../../../core/widgets/protocol_icon.dart';
import '../../domain/security_event.dart';
import '../../domain/severity_level.dart';
import '../../providers/events_provider.dart';
import 'ip_sessions_sheet.dart';

/// Modal bottom sheet displaying detailed triage metrics for a SecurityEvent.
class EventDetailsSheet extends ConsumerWidget {
  final SecurityEvent event;

  const EventDetailsSheet({super.key, required this.event});

  static Future<void> show(BuildContext context, SecurityEvent event) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EventDetailsSheet(event: event),
    );
  }

  String _formatEventType(String raw) {
    final lower = raw.toLowerCase().trim();
    switch (lower) {
      case 'ddos':
        return 'DDoS Attack';
      case 'credential_stuffing':
        return 'Credential Stuffing';
      case 'brute_force':
        return 'Brute Force SSH';
      case 'injection':
      case 'sqli':
        return 'SQL Injection';
      case 'xss':
        return 'XSS Attack';
      case 'ssh':
        return 'SSH Access';
      case 'rdp':
        return 'RDP Brute Force';
      case 'ftp':
        return 'FTP Probe';
      case 'dns':
        return 'DNS Query';
      default:
        return raw.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final formattedTime = '${event.timestamp.toUtc().toString().split('.').first} UTC';

    final severityColor = switch (event.severity) {
      SeverityLevel.critical => colors.critical,
      SeverityLevel.high => colors.high,
      SeverityLevel.warning => colors.warning,
      SeverityLevel.low => colors.brandPrimary,
      _ => colors.brandSecondary,
    };

    final displayTitle = _formatEventType(event.type.isNotEmpty ? event.type : event.classification);

    return LiquidGlassSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Classification + Severity Tag + Close
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: severityColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: severityColor.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              ProtocolBadge(protocol: event.protocol),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Scrollable Content Body
          Flexible(
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Recommended Action Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.brandPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.brandPrimary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: colors.brandPrimary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommended Action',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colors.brandPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event.recommendedAction,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Sanitized Payload Preview
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
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
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
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Password: ', style: TextStyle(fontSize: 12.5, color: colors.textSecondary)),
                                    Text(
                                      'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: colors.critical,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
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
                _buildDetailRow('Attacker IP', event.sourceIp, colors),
                _buildDetailRow('Location', '${event.country} (${event.countryCode})', colors),
                _buildDetailRow('Target Port & Service', '${event.protocol} / Port ${event.destinationPort}', colors),
                _buildDetailRow('Threat Level', '${event.threatLevel} / 5', colors),
                _buildDetailRow('Abuse Score', '${event.abuseScore.toStringAsFixed(1)} %', colors),
                _buildDetailRow('Decoy Sensor', event.honeypot, colors),
                _buildDetailRow(
                  'Containment Status',
                  event.isBlocked ? '✓ Attacker Blocked by Honeypot' : 'Perimeter Drop Rule Enforced',
                  colors,
                ),
                const SizedBox(height: 20),

                // 5. Action: View IP Sessions & Forensics
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      IpSessionsSheet.show(context, event.sourceIp);
                    },
                    icon: const Icon(Icons.history_edu_rounded, size: 18),
                    label: const Text(
                      'View IP Sessions & Forensics',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.brandPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
                fontFamily: label == 'Source IP' ? 'monospace' : null,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}