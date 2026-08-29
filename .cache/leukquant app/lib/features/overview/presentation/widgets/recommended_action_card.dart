// lib/features/overview/presentation/widgets/recommended_action_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/glass_card.dart';

/// Clean AI-grade recommended action card.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderRadius: 22.0,
      padding: const EdgeInsets.all(18.0),
      onTap: onAction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row — minimal, no heavy icon box
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: colors.brandPrimary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 7),
              Text(
                'Recommended Action',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                  letterSpacing: 0.1,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: colors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action title
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: colors.textPrimary,
              letterSpacing: -0.3,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 6),

          // Description
          Text(
            description,
            style: TextStyle(
              color: colors.textSecondary.withValues(alpha: isDark ? 0.8 : 0.9),
              height: 1.5,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
