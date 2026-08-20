import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_card.dart';

/// Recommended Action card providing calm, actionable security advice.
class RecommendedActionCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onAction;

  const RecommendedActionCard({
    super.key,
    required this.title,
    required this.description,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return StatusCard(
      title: 'Recommended Action',
      trailing: Icon(
        Icons.lightbulb_outline_rounded,
        size: 20,
        color: colors.brandSecondary,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
