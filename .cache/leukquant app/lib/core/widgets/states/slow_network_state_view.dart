// lib/core/widgets/states/slow_network_state_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'state_custom_painters.dart';

/// Reusable Slow Network / High Latency state view for LeukQuant Mobile.
class SlowNetworkStateView extends StatefulWidget {
  final String title;
  final String message;
  final String rttLatency;
  final String packetLoss;
  final VoidCallback? onRetry;
  final ValueChanged<bool>? onToggleLowBandwidth;
  final bool initialLowBandwidth;
  final bool isCard;
  final bool useIllustration;

  const SlowNetworkStateView({
    super.key,
    this.title = 'Unstable Network Connection',
    this.message = 'High packet latency detected on your current route. Decoy feeds and event streams may experience delays.',
    this.rttLatency = '1,840 ms',
    this.packetLoss = '24.2%',
    this.onRetry,
    this.onToggleLowBandwidth,
    this.initialLowBandwidth = false,
    this.isCard = false,
    this.useIllustration = true,
  });

  @override
  State<SlowNetworkStateView> createState() => _SlowNetworkStateViewState();
}

class _SlowNetworkStateViewState extends State<SlowNetworkStateView> {
  late bool _lowBandwidthMode;

  @override
  void initState() {
    super.initState();
    _lowBandwidthMode = widget.initialLowBandwidth;
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
          // Latency Gauge Illustration
          if (widget.useIllustration) ...[
            const SlowNetworkIllustration(size: 155)
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: isDark ? 0.12 : 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.network_ping_rounded, size: 36, color: colors.warning),
            ),
          ],
          const SizedBox(height: 18),

          // High Latency Metrics Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.warning.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.speed_rounded, size: 14, color: colors.warning),
                const SizedBox(width: 6),
                Text(
                  'RTT: ${widget.rttLatency} • LOSS: ${widget.packetLoss}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: colors.warning,
                    letterSpacing: 0.5,
                    fontFamily: 'monospace',
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

          // Low Bandwidth Toggle Card
          const SizedBox(height: 18),
          Container(
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceMuted.withValues(alpha: isDark ? 0.6 : 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bandwidth Saver Mode',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pauses real-time animation sweeps & reduces payload compression overhead.',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _lowBandwidthMode,
                  activeThumbColor: colors.brandPrimary,
                  onChanged: (val) {
                    setState(() => _lowBandwidthMode = val);
                    widget.onToggleLowBandwidth?.call(val);
                  },
                ),
              ],
            ),
          ),

          // Action Buttons
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: widget.onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Re-measure & Reload'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: colors.brandPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
