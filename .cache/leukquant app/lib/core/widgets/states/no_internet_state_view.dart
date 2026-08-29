// lib/core/widgets/states/no_internet_state_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'state_custom_painters.dart';

/// Reusable No Internet / Offline state view for LeukQuant Mobile.
class NoInternetStateView extends StatefulWidget {
  final String title;
  final String message;
  final String? cachedItemsInfo;
  final VoidCallback? onCheckConnection;
  final VoidCallback? onOpenOfflineVault;
  final bool isCard;
  final bool useIllustration;

  const NoInternetStateView({
    super.key,
    this.title = 'No Internet Connection',
    this.message = 'Unable to reach LeukQuant SOC gateway. Please verify your Wi-Fi or cellular network settings.',
    this.cachedItemsInfo = '36 cached incidents and decoy rules available offline.',
    this.onCheckConnection,
    this.onOpenOfflineVault,
    this.isCard = false,
    this.useIllustration = true,
  });

  @override
  State<NoInternetStateView> createState() => _NoInternetStateViewState();
}

class _NoInternetStateViewState extends State<NoInternetStateView> {
  bool _isPinging = false;

  void _handlePing() async {
    setState(() => _isPinging = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() => _isPinging = false);
      if (widget.onCheckConnection != null) {
        widget.onCheckConnection!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Still unreachable. Waiting for active network signal...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

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
          // Offline Satellite Illustration
          if (widget.useIllustration) ...[
            const NoInternetIllustration(size: 155)
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.high.withValues(alpha: isDark ? 0.12 : 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: colors.high.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.wifi_off_rounded, size: 36, color: colors.high),
            ),
          ],
          const SizedBox(height: 18),

          // Offline Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.high.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.high.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colors.high,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'STANDALONE OFFLINE MODE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: colors.high,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

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

          // Cached storage note
          if (widget.cachedItemsInfo != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceMuted.withValues(alpha: isDark ? 0.5 : 0.8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 14, color: colors.textSecondary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.cachedItemsInfo!,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isPinging ? null : _handlePing,
                icon: _isPinging
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.network_check_rounded, size: 18),
                label: Text(_isPinging ? 'Pinging Gateway...' : 'Check Connection'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: colors.brandPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (widget.onOpenOfflineVault != null)
                OutlinedButton.icon(
                  onPressed: widget.onOpenOfflineVault,
                  icon: const Icon(Icons.lock_clock_outlined, size: 18),
                  label: const Text('View Cached Vault'),
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
