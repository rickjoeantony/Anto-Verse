// lib/features/events/presentation/events_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../domain/security_event.dart';
import '../providers/events_provider.dart';
import 'widgets/event_card.dart';
import 'widgets/event_details_sheet.dart';
import 'widgets/event_filter_bar.dart';
import 'widgets/honeytoken_vault_card.dart';

/// Events screen providing stream search, filtering, pagination, and detailed bottom sheets.
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
      backgroundColor: colors.background,
      appBar: const LeukQuantAppBar(
        title: 'Security Events',
        subtitle: 'Canary & Honeytoken Telemetry',
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Filter & Search Header
            Container(
              color: colors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const EventFilterBar(),
            ),
            const Divider(height: 1),

            // Main Content Area with Async Handling
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.read(eventsNotifierProvider.notifier).fetchInitialEvents();
                },
                child: asyncEvents.when(
                  loading: () => ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                    children: const [
                      ShimmerSkeleton(height: 140, borderRadius: 20),
                      SizedBox(height: 14),
                      ShimmerSkeleton(height: 100, borderRadius: 20),
                      SizedBox(height: 12),
                      ShimmerSkeleton(height: 100, borderRadius: 20),
                      SizedBox(height: 12),
                      ShimmerSkeleton(height: 100, borderRadius: 20),
                    ],
                  ),
                  error: (err, _) => ErrorStateView(
                    message: 'Unable to load security events from backend.',
                    onRetry: () => ref.read(eventsNotifierProvider.notifier).fetchInitialEvents(),
                  ),
                  data: (events) {
                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                          ref.read(eventsNotifierProvider.notifier).fetchNextPage();
                        }
                        return false;
                      },
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // Status & Event Count Bar
                          SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: colors.surfaceMuted,
                              child: Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: events.isNotEmpty ? colors.success : colors.brandPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    events.isEmpty
                                        ? 'Status: Awaiting backend telemetry'
                                        : 'Displaying ${events.length} security events',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Honeytoken Vault Overview Card
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
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

                          // Events List or Empty State
                          if (events.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
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
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 130),
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
                                          .fadeIn(duration: 300.ms, delay: ((index % 8) * 35).ms)
                                          .slideY(begin: 0.05, end: 0, duration: 300.ms),
                                    );
                                  },
                                  childCount: events.length,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
