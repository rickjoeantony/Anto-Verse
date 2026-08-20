// lib/features/settings/presentation/widgets/profile_card.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/user_profile.dart';

/// Clean enterprise profile card in Settings.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasEmail = profile.email != null;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? colors.border.withValues(alpha: 0.85) : colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0x0C2563EB),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // User Avatar Circle
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.brandPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.brandPrimary.withValues(alpha: 0.25)),
            ),
            child: Center(
              child: Icon(
                Icons.person_outline_rounded,
                color: colors.brandPrimary,
                size: 22,
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
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email ?? 'Sign in with corporate identity',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    hasEmail ? 'Authenticated' : 'Pending Profile Sync',
                    style: TextStyle(
                      fontSize: 10,
                      color: hasEmail ? colors.brandPrimary : colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
