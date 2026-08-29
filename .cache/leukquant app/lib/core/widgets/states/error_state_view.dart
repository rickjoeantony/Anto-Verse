// lib/core/widgets/states/error_state_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'state_custom_painters.dart';

/// Reusable cyber error state widget with technical diagnostics for LeukQuant Mobile.
class ErrorStateView extends StatefulWidget {
  final String title;
  final String message;
  final String? errorCode;
  final String? technicalDetails;
  final String retryLabel;
  final VoidCallback? onRetry;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool isCard;
  final bool useIllustration;

  const ErrorStateView({
    super.key,
    this.title = 'Security Feed Unavailable',
    this.message = 'An unexpected upstream fault occurred while retrieving live telemetry data.',
    this.errorCode = 'ERR_BACKEND_TIMEOUT_504',
    this.technicalDetails = 'WebSocket connection pool exhausted on gateway [soc-ingress-us-east-1]. Status: 504 Gateway Timeout. Trace ID: lkq-tx-9942a1.',
    this.retryLabel = 'Retry Connection',
    this.onRetry,
    this.secondaryActionLabel = 'Contact SOC Support',
    this.onSecondaryAction,
    this.isCard = false,
    this.useIllustration = true,
  });

  @override
  State<ErrorStateView> createState() => _ErrorStateViewState();
}

class _ErrorStateViewState extends State<ErrorStateView> {
  bool _showDiagnostics = false;

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
          // Illustration or Warning Icon
          if (widget.useIllustration) ...[
            const ErrorStateIllustration(size: 155)
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.critical.withValues(alpha: isDark ? 0.12 : 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: colors.critical.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.warning_amber_rounded, size: 36, color: colors.critical),
            ),
          ],
          const SizedBox(height: 18),

          // Error Code Pill
          if (widget.errorCode != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.critical.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.critical.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded, size: 12, color: colors.critical),
                  const SizedBox(width: 6),
                  Text(
                    widget.errorCode!,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: colors.critical,
                      letterSpacing: 0.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Title
          Text(
            widget.title,
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
              widget.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
                height: 1.45,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Diagnostics Expander
          if (widget.technicalDetails != null) ...[
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  _showDiagnostics = !_showDiagnostics;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _showDiagnostics ? 'Hide Diagnostics' : 'View Diagnostics Log',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showDiagnostics ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: colors.brandPrimary,
                    ),
                  ],
                ),
              ),
            ),
            if (_showDiagnostics) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F141E) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border.withValues(alpha: 0.6)),
                ),
                child: SelectableText(
                  widget.technicalDetails!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ).animate().fadeIn(duration: 250.ms),
            ],
          ],

          // Actions
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              if (widget.onRetry != null)
                ElevatedButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(widget.retryLabel),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    backgroundColor: colors.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              if (widget.secondaryActionLabel != null && widget.onSecondaryAction != null)
                OutlinedButton.icon(
                  onPressed: widget.onSecondaryAction,
                  icon: const Icon(Icons.support_agent_rounded, size: 18),
                  label: Text(widget.secondaryActionLabel!),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    side: BorderSide(color: colors.border),
                    foregroundColor: colors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    if (widget.isCard) {
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
