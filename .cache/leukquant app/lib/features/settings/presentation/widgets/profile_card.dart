// lib/features/settings/presentation/widgets/profile_card.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/glass_card.dart';
import '../../domain/user_profile.dart';

/// Clean enterprise profile card in Settings with iOS frosted glass.
class ProfileCard extends StatelessWidget {
  final UserProfile profile;

  const ProfileCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final hasEmail = profile.email != null;

    return GlassCard(
      borderRadius: 24.0,
      padding: const EdgeInsets.all(18.0),
      child: Row(
        children: [
          // User Avatar Box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.brandPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.brandPrimary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.person_outline_rounded,
                color: colors.brandPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User Info Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasEmail ? profile.name : AppConstants.awaitingProfileData,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email ?? 'Sign in with corporate identity',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: colors.brandPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.brandPrimary.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        hasEmail ? 'Plan: ${profile.planDisplayName}' : 'Pending Profile Sync',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: hasEmail ? colors.brandPrimary : colors.textSecondary,
                          fontWeight: FontWeight.w700,
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
}
