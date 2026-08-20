// lib/features/incidents/presentation/incidents_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../providers/incidents_provider.dart';
import 'widgets/incident_card.dart';

/// Incidents screen displaying verified security incidents and timeline progressions.
class IncidentsScreen extends ConsumerWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncIncidents = ref.watch(incidentsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const LeukQuantAppBar(
        title: 'Incidents',
        subtitle: 'Containment & Resolution',
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(incidentsProvider);
          },
          child: asyncIncidents.when(
            loading: () => ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
              children: const [
                ShimmerSkeleton(height: 160, borderRadius: 24),
                SizedBox(height: 14),
                ShimmerSkeleton(height: 160, borderRadius: 24),
              ],
            ),
            error: (err, _) => ErrorStateView(
              message: 'Unable to connect to incident correlation service.',
              onRetry: () => ref.invalidate(incidentsProvider),
            ),
            data: (incidents) {
              return Column(
                children: [
                  // Header Summary Banner (Zero Overflow)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? colors.border.withValues(alpha: 0.6) : colors.border,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 16, color: colors.brandPrimary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            incidents.isEmpty
                                ? 'Status: Incident service awaiting backend connection'
                                : '${incidents.length} active incident(s) under containment',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main List / Empty State
                  Expanded(
                    child: incidents.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 40, 24, 130),
                            children: const [
                              EmptyStateView(
                                icon: Icons.check_circle_outline_rounded,
                                title: 'No Active Incidents',
                                description:
                                    'Incident correlation pipeline is active. Correlated alert clusters requiring triage will appear here.',
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
                            itemCount: incidents.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final incident = incidents[index];
                              return IncidentCard(incident: incident)
                                  .animate()
                                  .fadeIn(duration: 350.ms, delay: (index * 60).ms)
                                  .slideY(begin: 0.06, end: 0, duration: 350.ms);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
