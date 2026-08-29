// lib/core/widgets/states/empty_state_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../glass/glass_card.dart';
import 'state_custom_painters.dart';

/// Reusable iOS-inspired frosted empty state widget with 3D security illustration for LeukQuant Mobile.
class EmptyStateView extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String description;
  final String? badgeLabel;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool isCard;
  final bool useIllustration;

  const EmptyStateView({
    super.key,
    this.icon,
    this.title = 'No Security Events Detected',
    this.description = 'All monitored honeytokens and decoy nodes are active with zero detected anomalies.',
    this.badgeLabel,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.isCard = false,
    this.useIllustration = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3D-styled Security Shield Illustration or Icon Badge
          if (useIllustration && icon == null) ...[
            const EmptyStateIllustration(size: 160),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.brandPrimary.withValues(alpha: isDark ? 0.14 : 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.brandPrimary.withValues(alpha: isDark ? 0.35 : 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.brandPrimary.withValues(alpha: isDark ? 0.25 : 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon ?? Icons.shield_rounded,
                size: 34,
                color: colors.brandPrimary,
              ),
            ),
          ],
          const SizedBox(height: 18),

          // Status Badge
          if (badgeLabel != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    badgeLabel!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: colors.success,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Title
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: colors.textPrimary,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              description,
              style: GoogleFonts.plusJakartaSans(
                color: colors.textSecondary,
                height: 1.45,
                fontSize: 13,
                letterSpacing: -0.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Primary / Secondary Action Buttons
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 22),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    backgroundColor: colors.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    actionLabel!,
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                if (secondaryActionLabel != null && onSecondaryAction != null) ...[
                  OutlinedButton(
                    onPressed: onSecondaryAction,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      side: BorderSide(color: colors.border),
                      foregroundColor: colors.textPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      secondaryActionLabel!,
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );

    if (isCard) {
      return GlassCard(
        borderRadius: 24.0,
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: content,
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: content,
      ),
    );
  }
}
