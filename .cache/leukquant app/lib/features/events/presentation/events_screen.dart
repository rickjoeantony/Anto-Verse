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
// import 'widgets/honeytoken_vault_card.dart';

/// Events screen with iOS-inspired glass styling, search, filter chips, interactive sheet, and infinite historical pagination.
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      ref.read(eventsNotifierProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            controller: _scrollController,
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
                        'All recorded telemetry · Auto-sync active',
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
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 170),
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
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 170),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final event = events[index];
                            return RepaintBoundary(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: EventCard(
                                  event: event,
                                  onTap: () => EventDetailsSheet.show(context, event),
                                ),
                              ),
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
