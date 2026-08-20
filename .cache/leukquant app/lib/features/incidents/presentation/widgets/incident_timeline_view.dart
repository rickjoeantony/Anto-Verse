// lib/features/incidents/presentation/widgets/incident_timeline_view.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/incident.dart';

/// 4-Stage Visual Audit Stepper: Detection → Correlation → Review → Resolution
class IncidentTimelineView extends StatelessWidget {
  final List<IncidentTimelineStage> timeline;
  final String status;

  const IncidentTimelineView({
    super.key,
    required this.timeline,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final stages = [
      {'label': 'Detection', 'step': 1},
      {'label': 'Correlation', 'step': 2},
      {'label': 'Review', 'step': 3},
      {'label': 'Resolution', 'step': 4},
    ];

    // Determine current active step based on backend status
    final currentStep = () {
      final s = status.toLowerCase();
      if (s.contains('resolved') || s.contains('closed')) return 4;
      if (s.contains('review') || s.contains('triage') || s.contains('contained')) return 3;
      if (s.contains('correlation') || s.contains('correlated')) return 2;
      return 1;
    }();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Horizontal Stepper Bar
        Row(
          children: List.generate(stages.length * 2 - 1, (index) {
            if (index.isOdd) {
              final stepIndex = (index ~/ 2) + 1;
              final isPassed = stepIndex < currentStep;
              return Expanded(
                child: Container(
                  height: 2,
                  color: isPassed ? colors.brandPrimary : colors.border,
                ),
              );
            }

            final stageIndex = index ~/ 2;
            final stage = stages[stageIndex];
            final step = stage['step'] as int;
            final isCompleted = step < currentStep;
            final isCurrent = step == currentStep;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? colors.brandPrimary
                        : (isCurrent ? colors.brandPrimary.withValues(alpha: 0.15) : colors.surfaceMuted),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent || isCompleted ? colors.brandPrimary : colors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                        : Text(
                            '$step',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isCurrent ? colors.brandPrimary : colors.textSecondary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stage['label'] as String,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent ? colors.brandPrimary : colors.textSecondary,
                  ),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 16),

        // Timeline Step Notes
        ...timeline.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: item.isCompleted ? colors.brandPrimary : colors.brandSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.stage,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          '${item.timestamp} · ${item.description}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
