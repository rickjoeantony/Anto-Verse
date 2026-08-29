// lib/core/widgets/states/no_search_results_state_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'state_custom_painters.dart';

/// Reusable No Search Results / Filter Mismatch state view for LeukQuant Mobile.
class NoSearchResultsStateView extends StatelessWidget {
  final String title;
  final String message;
  final String? searchQuery;
  final List<String> suggestions;
  final ValueChanged<String>? onSelectSuggestion;
  final VoidCallback? onClearSearch;
  final bool isCard;
  final bool useIllustration;

  const NoSearchResultsStateView({
    super.key,
    this.title = 'No Matching Security Records',
    this.message = 'No honeytokens, incident alerts, or telemetry logs match your current search query or applied filters.',
    this.searchQuery,
    this.suggestions = const ['Critical Incidents', 'SSH Decoys', 'HTTP Canaries', 'Active Ports'],
    this.onSelectSuggestion,
    this.onClearSearch,
    this.isCard = false,
    this.useIllustration = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Illustration
          if (useIllustration) ...[
            const NoSearchResultsIllustration(size: 155)
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              child: Icon(Icons.search_off_rounded, size: 36, color: colors.textSecondary),
            ),
          ],
          const SizedBox(height: 18),

          // Search Query Badge
          if (searchQuery != null && searchQuery!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: colors.surfaceMuted.withValues(alpha: isDark ? 0.7 : 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_rounded, size: 13, color: colors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '"$searchQuery"',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      fontStyle: FontStyle.italic,
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
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Message
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
                height: 1.45,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Suggestions
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Try searching for:',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions.map((tag) {
                return ActionChip(
                  label: Text(tag),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.brandPrimary,
                  ),
                  backgroundColor: colors.brandPrimary.withValues(alpha: isDark ? 0.12 : 0.08),
                  side: BorderSide(color: colors.brandPrimary.withValues(alpha: 0.25)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () => onSelectSuggestion?.call(tag),
                );
              }).toList(),
            ),
          ],

          // Clear Search Action Button
          if (onClearSearch != null) ...[
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
              label: const Text('Clear Filter & Search'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: colors.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );

    if (isCard) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? colors.border.withValues(alpha: 0.8) : colors.border),
        ),
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
