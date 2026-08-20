// lib/features/events/presentation/widgets/event_details_sheet.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/severity_badge.dart';
import '../../domain/security_event.dart';

/// Customer-focused bottom sheet explaining an individual security event.
class EventDetailsSheet extends StatelessWidget {
  final SecurityEvent event;

  const EventDetailsSheet({
    super.key,
    required this.event,
  });

  static void show(BuildContext context, SecurityEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventDetailsSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final formattedTime = '${event.timestamp.toIso8601String().substring(0, 19).replaceAll("T", " ")} UTC';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: Title & Close
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  SeverityBadge(severity: event.severity),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      event.id,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Flexible(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // 1. What Happened?
                  Text(
                    'What Happened?',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.classification,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A security signal was observed from source ${event.sourceIp} targeting protected protocol ${event.protocol}.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Why This Matters
                  Text(
                    'Why This Matters',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      event.classificationReasons.isNotEmpty
                          ? event.classificationReasons.first
                          : 'Ghost-Net decoy successfully intercepted this interaction early before any production assets were impacted.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textPrimary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Recommended Action
                  Text(
                    'Recommended Action',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 18, color: colors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.recommendedAction ?? 'Decoy sensor absorbed the interaction. No manual action required.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. Source & Protected Details
                  Text(
                    'Activity Details',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Timestamp', formattedTime, colors),
                  _buildDetailRow('Origin', '${event.sourceIp} (${event.country})', colors),
                  _buildDetailRow('Protocol', event.protocol, colors),
                  _buildDetailRow('Credentials Masked', event.maskedCredentials, colors),
                  const SizedBox(height: 16),

                  // 5. Timeline Step
                  Text(
                    'Timeline',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTimelineItem(
                    title: 'Sensor Interaction Recorded',
                    time: formattedTime,
                    isLast: false,
                    colors: colors,
                  ),
                  _buildTimelineItem(
                    title: 'Automated Isolation & Masking',
                    time: 'Immediate',
                    isLast: true,
                    colors: colors,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              fontFamily: label == 'Origin' || label == 'Credentials Masked' ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String time,
    required bool isLast,
    required AppColorScheme colors,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: colors.brandPrimary, shape: BoxShape.circle),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: colors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary)),
              Text(time, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
