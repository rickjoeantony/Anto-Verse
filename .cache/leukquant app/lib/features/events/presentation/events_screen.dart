// lib/features/events/presentation/events_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../providers/events_provider.dart';
import 'widgets/event_card.dart';
import 'widgets/event_details_sheet.dart';
import 'widgets/event_filter_bar.dart';
import 'widgets/honeytoken_vault_card.dart';

/// Events screen with iOS-inspired glass styling, search, filter chips, and interactive sheet.
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final asyncEvents = ref.watch(filteredEventsProvider);
    final hasActiveFilter = ref.watch(eventSearchQueryProvider).isNotEmpty ||
        ref.watch(eventSeverityFilterProvider) != null ||
        ref.watch(eventProtocolFilterProvider) != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(eventsNotifierProvider.notifier).fetchInitialEvents();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // iOS Large Title Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security Events',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          color: colors.textPrimary,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Canary interactions and decoy sensor telemetry',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                          fontSize: 14,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter & Search Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: EventFilterBar(),
                ),
              ),

              // Honeytoken Vault Overview Card
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: HoneytokenVaultCard(
                    tokens: [
                      HoneytokenData(
                        id: 'TOKEN-SSH-882',
                        type: 'SSH Keypair',
                        credential: 'admin / **********',
                        auditHash: 'a8f9c2...4e1',
                      ),
                      HoneytokenData(
                        id: 'TOKEN-SQL-104',
                        type: 'DB Connection',
                        credential: 'pg_readonly / **********',
                        auditHash: '3d7b11...9a2',
                      ),
                      HoneytokenData(
                        id: 'TOKEN-AWS-592',
                        type: 'IAM API Key',
                        credential: 'AKIA**********',
                        auditHash: '7c2e04...f83',
                      ),
                    ],
                  ),
                ),
              ),

              // Status Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: colors.brandPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.brandPrimary.withValues(alpha: 0.55),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Live telemetry stream · Canary sensors active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Async Events Stream
              ...asyncEvents.when(
                loading: () => [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 130),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(const [
                        ShimmerSkeleton(height: 100, borderRadius: 24),
                        SizedBox(height: 12),
                        ShimmerSkeleton(height: 100, borderRadius: 24),
                        SizedBox(height: 12),
                        ShimmerSkeleton(height: 100, borderRadius: 24),
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
                        message: 'Unable to load security events from backend.',
                        onRetry: () => ref.read(eventsNotifierProvider.notifier).fetchInitialEvents(),
                      ),
                    ),
                  ),
                ],
                data: (events) {
                  if (events.isEmpty) {
                    return [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 130),
                          child: EmptyStateView(
                            icon: hasActiveFilter
                                ? Icons.filter_alt_off_rounded
                                : Icons.stream_rounded,
                            title: hasActiveFilter
                                ? 'No Matching Events'
                                : 'No Events Received',
                            description: hasActiveFilter
                                ? 'No events match the selected search or filter criteria.'
                                : AppConstants.noEventsState,
                            actionLabel: hasActiveFilter ? 'Reset Filters' : null,
                            onAction: () {
                              ref.read(eventSearchQueryProvider.notifier).state = '';
                              ref.read(eventSeverityFilterProvider.notifier).state = null;
                              ref.read(eventProtocolFilterProvider.notifier).state = null;
                            },
                          ),
                        ),
                      ),
                    ];
                  }

                  return [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final event = events[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: EventCard(
                                event: event,
                                onTap: () => EventDetailsSheet.show(context, event),
                              )
                                  .animate()
                                  .fadeIn(duration: 250.ms, delay: ((index % 6) * 30).ms)
                                  .slideY(begin: 0.04, end: 0, duration: 250.ms),
                            );
                          },
                          childCount: events.length,
                        ),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
