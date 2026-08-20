// lib/features/more/presentation/deployments_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../overview/providers/overview_provider.dart';

/// Screen displaying customer-friendly protected deployment sensor status.
class DeploymentsScreen extends ConsumerWidget {
  const DeploymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(overviewSummaryProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const LeukQuantAppBar(
        title: 'Deployments',
        subtitle: 'Protected Cloud & On-Premises Sensors',
      ),
      body: SafeArea(
        child: summaryAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: colors.brandPrimary),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: EmptyStateView(
              icon: Icons.cloud_off_rounded,
              title: 'No Deployment Connected',
              description: 'Connect an active Ghost-Net sensor to view verified deployment health and telemetry.',
            ),
          ),
          data: (summary) {
            final isConnected = summary.isBackendConnected;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.border),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isConnected ? colors.success : colors.brandPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isConnected ? 'Ghost-Net Primary Sensor' : 'Ghost-Net Deployment',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isConnected ? colors.success.withValues(alpha: 0.1) : colors.surfaceMuted,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isConnected ? colors.success.withValues(alpha: 0.3) : colors.border),
                            ),
                            child: Text(
                              isConnected ? 'Connected' : 'Awaiting Connection',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isConnected ? colors.success : colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isConnected
                            ? 'Protected deployment operating normally in region: ${summary.deploymentRegion ?? "Primary"}.'
                            : 'Connect an active deployment to view verified security status and activity.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Last Heartbeat', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                          Text(
                            isConnected ? (summary.lastEventTimestamp ?? 'Active now') : 'Awaiting sensor heartbeat',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
