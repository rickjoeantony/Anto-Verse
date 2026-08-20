import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable calm error state widget for LeukQuant Mobile.
class ErrorStateView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool isCard;

  const ErrorStateView({
    super.key,
    this.title = 'Unable to Load Data',
    this.message = 'An unexpected error occurred while retrieving security details.',
    this.onRetry,
    this.isCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.critical.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: colors.critical.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 32,
              color: colors.critical,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: content,
      );
    }

    return Center(child: content);
  }
}
