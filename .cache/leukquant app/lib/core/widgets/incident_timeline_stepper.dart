// lib/core/widgets/incident_timeline_stepper.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/incidents/domain/incident.dart';

/// Clean 4-stage incident audit stepper with modern Apple-inspired timeline aesthetics.
class IncidentTimelineStepper extends StatelessWidget {
  final List<IncidentTimelineStage> timeline;
  final String status;

  const IncidentTimelineStepper({
    super.key,
    required this.timeline,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stages = [
      {'label': 'Detect', 'full': 'Detection', 'step': 1},
      {'label': 'Correlate', 'full': 'Correlation', 'step': 2},
      {'label': 'Contain', 'full': 'Containment', 'step': 3},
      {'label': 'Resolve', 'full': 'Resolution', 'step': 4},
    ];

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

        // ── 4-Stage Horizontal Stepper ──────────────────────────────
        Row(
          children: List.generate(stages.length * 2 - 1, (index) {
            if (index.isOdd) {
              final stepIndex = (index ~/ 2) + 1;
              final isPassed = stepIndex < currentStep;
              return Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isPassed
                        ? colors.brandPrimary
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06)),
                    borderRadius: BorderRadius.circular(1),
                  ),
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
                        : (isCurrent
                            ? colors.brandPrimary.withValues(alpha: isDark ? 0.20 : 0.12)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.04))),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent || isCompleted
                          ? colors.brandPrimary
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.black.withValues(alpha: 0.08)),
                      width: 1.5,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: colors.brandPrimary.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                        : Text(
                            '$step',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isCurrent ? colors.brandPrimary : colors.textSecondary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 54,
                  child: Text(
                    stage['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                      color: isCurrent
                          ? colors.brandPrimary
                          : colors.textSecondary.withValues(alpha: 0.75),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }),
        ),

        const SizedBox(height: 18),

        // ── Vertical Audit Log Trail ────────────────────────────────
        ...timeline.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final isLast = idx == timeline.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline dot + line
                SizedBox(
                  width: 16,
                  child: Column(
                    children: [
                      const SizedBox(height: 3),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: item.isCompleted ? colors.brandPrimary : colors.brandSecondary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (item.isCompleted ? colors.brandPrimary : colors.brandSecondary)
                                  .withValues(alpha: 0.55),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 1.5,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colors.brandPrimary.withValues(alpha: 0.25),
                                  isDark
                                      ? Colors.white.withValues(alpha: 0.04)
                                      : Colors.black.withValues(alpha: 0.03),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 4 : 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.stage,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                                letterSpacing: -0.1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '·',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.textSecondary.withValues(alpha: 0.4),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.timestamp,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: colors.textSecondary.withValues(alpha: 0.65),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.textSecondary.withValues(alpha: isDark ? 0.7 : 0.8),
                            height: 1.35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
