// lib/features/incidents/presentation/incidents_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/api_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../domain/incident.dart';
import '../providers/incidents_provider.dart';
import 'widgets/incident_card.dart';

/// Clean, high-end Incidents screen with executive summary and automated containment timelines.
class IncidentsScreen extends ConsumerWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncResult = ref.watch(incidentsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(incidentsProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // ── iOS Large Title Header ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incidents',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          color: colors.textPrimary,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Automated containment & multi-stage triage timeline',
                        style: TextStyle(
                          color: colors.textSecondary.withValues(alpha: 0.75),
                          fontSize: 13.5,
                          letterSpacing: -0.2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ...asyncResult.when(
                loading: () => [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(const [
                        ShimmerSkeleton(height: 170, borderRadius: 22),
                        SizedBox(height: 14),
                        ShimmerSkeleton(height: 170, borderRadius: 22),
                      ]),
                    ),
                  ),
                ],
                error: (err, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: ErrorStateView(
                        message: 'Unable to load incidents.',
                        onRetry: () => ref.invalidate(incidentsProvider),
                      ),
                    ),
                  ),
                ],
                data: (result) => _buildSlivers(context, ref, result, colors, theme, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(
    BuildContext context,
    WidgetRef ref,
    ApiResult<List<Incident>> result,
    AppColorScheme colors,
    ThemeData theme,
    bool isDark,
  ) {
    return switch (result) {
      ApiSuccess<List<Incident>>(:final data) => [
          // ── Status banner line ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: data.isNotEmpty ? colors.warning : colors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (data.isNotEmpty ? colors.warning : colors.success)
                              .withValues(alpha: 0.55),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      data.isNotEmpty
                          ? '${data.length} high-risk item${data.length == 1 ? '' : 's'} · Derived from verified events'
                          : 'All perimeters nominal · 0 active incidents',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 130),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final incident = data[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: IncidentCard(incident: incident)
                        .animate()
                        .fadeIn(duration: 300.ms, delay: (index * 40).ms)
                        .slideY(begin: 0.04, end: 0, duration: 300.ms),
                  );
                },
                childCount: data.length,
              ),
            ),
          ),
        ],

      ApiEmpty<List<Incident>>() => [
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 40, 24, 130),
              child: EmptyStateView(
                icon: Icons.check_circle_outline_rounded,
                title: 'No Active Incidents',
                description:
                    'Incident correlation pipeline is active. Correlated alert clusters requiring triage will appear here.',
              ),
            ),
          ),
        ],

      ApiUnauthorized<List<Incident>>() => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: 'Your session has expired. Please sign in again.',
              onRetry: () => ref.invalidate(incidentsProvider),
            ),
          ),
        ],

      ApiPermissionDenied<List<Incident>>() => const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: 'Access restricted. You do not have permission to view incidents. Contact your administrator.',
            ),
          ),
        ],

      ApiRateLimited<List<Incident>>() => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: 'Too many requests. Please wait a moment and try again.',
              onRetry: () => ref.invalidate(incidentsProvider),
            ),
          ),
        ],

      ApiValidationError<List<Incident>>(:final message) => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: 'Request error: $message',
              onRetry: () => ref.invalidate(incidentsProvider),
            ),
          ),
        ],

      ApiServerError<List<Incident>>(:final message) => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: 'The LeukQuant service encountered a temporary issue. $message',
              onRetry: () => ref.invalidate(incidentsProvider),
            ),
          ),
        ],

      ApiServiceUnavailable<List<Incident>>(:final message) => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: message,
              onRetry: () => ref.invalidate(incidentsProvider),
            ),
          ),
        ],

      ApiError<List<Incident>>(:final message) => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: message,
              onRetry: () => ref.invalidate(incidentsProvider),
            ),
          ),
        ],
    };
  }
}
