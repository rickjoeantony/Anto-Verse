// lib/features/settings/presentation/widgets/profile_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/glass_card.dart';
import '../../domain/user_profile.dart';
import 'edit_profile_sheet.dart';
import 'user_avatar_widget.dart';

/// Clean enterprise profile card in Settings with iOS frosted glass and Edit Profile capabilities.
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
    final isDark = theme.brightness == Brightness.dark;
    final hasEmail = profile.email != null;
    final company = profile.organisation ?? 'Leukquant Enterprise';

    return GlassCard(
      borderRadius: 24.0,
      padding: const EdgeInsets.all(18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User Cyber Avatar
          UserAvatarWidget(
            avatarKey: profile.avatar,
            name: profile.name,
            size: 52,
            showGlow: true,
            onTap: () {
              HapticFeedback.selectionClick();
              EditProfileSheet.show(context, profile);
            },
          ),
          const SizedBox(width: 14),

          // User Info Details & Company
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasEmail ? profile.name : AppConstants.awaitingProfileData,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Company Name Row
                Row(
                  children: [
                    Icon(
                      Icons.business_rounded,
                      size: 13,
                      color: colors.brandSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        company,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.brandSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Plan & Email Row
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: colors.brandPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.brandPrimary.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        hasEmail ? profile.planDisplayName : 'Pending Profile Sync',
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

          // Edit Profile Action Button
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: colors.brandPrimary,
              ),
              tooltip: 'Edit Profile & Company',
              onPressed: () {
                HapticFeedback.selectionClick();
                EditProfileSheet.show(context, profile);
              },
            ),
          ),
        ],
      ),
    );
  }
}