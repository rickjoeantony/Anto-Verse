// lib/features/overview/presentation/overview_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/animation/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/websocket/websocket_service.dart';
import '../../../core/widgets/animated_metric_card.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/security_posture_hero.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../providers/overview_provider.dart';
import 'widgets/analytics_charts.dart';
import 'widgets/recent_activity_list.dart';
import 'widgets/recommended_action_card.dart';

/// Futuristic, premium Home Screen answering the 3 core business questions:
/// 1. Is my deployment active?
/// 2. Did anything important happen?
/// 3. What should I do next?
class OverviewScreen extends ConsumerStatefulWidget {
  const OverviewScreen({super.key});

  @override
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(webSocketProvider.notifier).connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final summaryAsync = ref.watch(overviewSummaryProvider);
    final isReducedMotion = AppMotion.isReducedMotion(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const LeukQuantAppBar(
        title: 'Home',
        subtitle: 'Security Posture & Intelligence',
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(overviewSummaryProvider);
          },
          child: summaryAsync.when(
            loading: () => _buildLoadingSkeleton(context),
            error: (err, _) => ErrorStateView(
              message: 'Unable to reach LeukQuant dashboard service.',
              onRetry: () => ref.invalidate(overviewSummaryProvider),
            ),
            data: (summary) => ResponsiveLayout(
              builder: (context, category, constraints) {
                final isTablet = category == ScreenCategory.tablet || category == ScreenCategory.desktopWide;

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Organisation Name Banner
                          if (summary.organisationName != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(
                                summary.organisationName!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),

                          // 1. Security Posture Hero Card (Question 1: Is my deployment active?)
                          SecurityPostureHero(
                            isBackendConnected: summary.isBackendConnected,
                            hasActiveIncident: (summary.criticalIncidentsCount ?? 0) > 0,
                            lastTelemetryTime: summary.lastEventTimestamp,
                            region: summary.deploymentRegion,
                          ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0, duration: 350.ms),

                          const SizedBox(height: 16),

                          // 2. Metric Cards Grid (Question 2: Did anything important happen?)
                          if (isTablet)
                            Row(
                              children: [
                                Expanded(
                                  child: AnimatedMetricCard(
                                    title: 'Critical Incidents',
                                    count: summary.criticalIncidentsCount,
                                    subtitle: summary.isBackendConnected ? 'Active tickets' : 'Awaiting stream',
                                    icon: Icons.shield_outlined,
                                    accentColor: colors.critical,
                                    isPending: !summary.isBackendConnected,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: AnimatedMetricCard(
                                    title: 'High Risk Events',
                                    count: summary.highRiskEventsCount,
                                    subtitle: summary.isBackendConnected ? 'High alerts' : 'Awaiting stream',
                                    icon: Icons.warning_amber_rounded,
                                    accentColor: colors.high,
                                    isPending: !summary.isBackendConnected,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: AnimatedMetricCard(
                                    title: 'Protected Nodes',
                                    stringValue: summary.isBackendConnected ? '4 Active' : 'Standby',
                                    subtitle: 'Decoy fleet status',
                                    icon: Icons.hub_outlined,
                                    accentColor: colors.brandSecondary,
                                    isPending: !summary.isBackendConnected,
                                  ),
                                ),
                              ],
                            ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 50.ms).slideY(begin: 0.05, end: 0, duration: 400.ms)
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: AnimatedMetricCard(
                                    title: 'Critical Incidents',
                                    count: summary.criticalIncidentsCount,
                                    subtitle: summary.isBackendConnected ? 'Active tickets' : 'Awaiting stream',
                                    icon: Icons.shield_outlined,
                                    accentColor: colors.critical,
                                    isPending: !summary.isBackendConnected,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AnimatedMetricCard(
                                    title: 'High Risk Events',
                                    count: summary.highRiskEventsCount,
                                    subtitle: summary.isBackendConnected ? 'High alerts' : 'Awaiting stream',
                                    icon: Icons.warning_amber_rounded,
                                    accentColor: colors.high,
                                    isPending: !summary.isBackendConnected,
                                  ),
                                ),
                              ],
                            ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 50.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),

                          const SizedBox(height: 16),

                          // 3. What Needs Attention Card (Question 3: What should I do next?)
                          if (summary.recommendedActionTitle != null) ...[
                            RecommendedActionCard(
                              title: summary.recommendedActionTitle!,
                              description: summary.recommendedActionDescription ?? '',
                            ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 100.ms),
                            const SizedBox(height: 16),
                          ],

                          // 4. Security Activity Chart
                          RepaintBoundary(
                            child: SecurityActivityLineChart(
                              dataPoints: summary.activityTrendData,
                            ),
                          ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 150.ms),

                          const SizedBox(height: 16),

                          // 5. Threat Distribution Donut Chart
                          RepaintBoundary(
                            child: ThreatDistributionDonutChart(
                              threatData: summary.threatDistribution,
                            ),
                          ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 200.ms),

                          const SizedBox(height: 16),

                          // 6. Protocol Activity Bar Chart
                          RepaintBoundary(
                            child: ProtocolActivityBarChart(
                              protocolData: summary.protocolActivity,
                            ),
                          ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 250.ms),

                          const SizedBox(height: 16),

                          // 7. Recent Events Preview with 'View all events'
                          RecentActivityList(
                            activities: summary.recentActivities,
                            isBackendConnected: summary.isBackendConnected,
                          ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 300.ms),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      children: const [
        ShimmerSkeleton(height: 130, borderRadius: 28),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: MetricCardSkeleton()),
            SizedBox(width: 12),
            Expanded(child: MetricCardSkeleton()),
          ],
        ),
        SizedBox(height: 16),
        ChartSkeleton(height: 210),
        SizedBox(height: 16),
        ChartSkeleton(height: 160),
      ],
    );
  }
}
