// lib/features/overview/presentation/overview_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/animation/app_motion.dart';
import '../../../core/config/app_config.dart';
import '../../../core/domain/api_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/websocket/websocket_service.dart';
import '../../../core/widgets/animated_metric_card.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/security_posture_hero.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../domain/overview_summary.dart';
import '../providers/overview_provider.dart';
import '../../settings/presentation/widgets/user_avatar_widget.dart';
import '../../settings/presentation/widgets/edit_profile_sheet.dart';
import 'widgets/analytics_charts.dart';
import 'widgets/recent_activity_list.dart';
import 'widgets/recommended_action_card.dart';

/// Clean Warm Minimalist Security Overview Screen for LeukQuant.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(overviewSummaryProvider);
    final isReducedMotion = AppMotion.isReducedMotion(context);
    final authState = ref.watch(authProvider);
    final profile = ref.watch(userProfileProvider);

    final userName = profile.name.isNotEmpty && profile.name != '—'
        ? profile.name
        : (authState.email != null ? authState.email!.split('@').first : 'Security User');

    final mutedText = colors.textSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(overviewSummaryProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 170),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. TOP HEADER (Profile Avatar + Circular Action Bells)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Circular Profile Avatar with Glowing Liquid Ring
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            context.go('/more');
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [
                                            colors.brandPrimary.withValues(alpha: 0.6),
                                            Colors.white.withValues(alpha: 0.2),
                                          ]
                                        : [
                                            Colors.white,
                                            colors.brandPrimary.withValues(alpha: 0.4),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.brandPrimary.withValues(alpha: isDark ? 0.35 : 0.15),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(2.5),
                                child: ClipOval(
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedBox(
                                    width: 45,
                                    height: 45,
                                    child: Image.network(
                                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
                                      fit: BoxFit.cover,
                                      cacheWidth: 160,
                                      cacheHeight: 160,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: colors.brandPrimary.withValues(alpha: 0.2),
                                        child: Center(
                                          child: Text(
                                            userName.substring(0, math.min(userName.length, 2)).toUpperCase(),
                                            style: TextStyle(
                                              color: colors.brandPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Online glowing beacon
                              Positioned(
                                bottom: 1,
                                right: 1,
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: colors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF0B1020) : Colors.white,
                                      width: 2.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.success.withValues(alpha: 0.85),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Floating Circular Action Buttons
                        Row(
                          children: [
                            // Theme Toggle Button
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colors.glassCard,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.glassBorder,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                tooltip: 'Toggle Theme',
                                icon: Icon(
                                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                  color: isDark ? const Color(0xFFFBBF24) : colors.brandPrimary,
                                  size: 19,
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  ref.read(themeModeProvider.notifier).toggleTheme();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Floating Circular Notification Bell Button
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colors.glassCard,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.glassBorder,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    tooltip: 'Alerts & Incidents',
                                    icon: Icon(
                                      Icons.notifications_none_rounded,
                                      color: colors.textPrimary,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      context.go('/incidents');
                                    },
                                  ),
                                  Positioned(
                                    top: 11,
                                    right: 12,
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: colors.critical,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: colors.critical.withValues(alpha: 0.8),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // 2. GREETING SECTION
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Hello, $userName 👋',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: mutedText,
                                letterSpacing: 0.05,
                              ),
                            ),
                            if (!AppConfig.isProduction) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppConfig.isLocal
                                      ? colors.warning.withValues(alpha: 0.15)
                                      : colors.brandPrimary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppConfig.isLocal
                                        ? colors.warning.withValues(alpha: 0.35)
                                        : colors.brandPrimary.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  AppConfig.isLocal ? 'DEV/LOCAL' : 'STAGING',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppConfig.isLocal ? colors.warning : colors.brandPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Security Command',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                            letterSpacing: -0.8,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Real-time honeypot sensors & telemetry',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: colors.textSecondary.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 3. MAIN VERIFIED DASHBOARD TELEMETRY & CHARTS
                    summaryAsync.when(
                      loading: () => _buildLoadingSkeleton(context),
                      error: (err, _) => ErrorStateView(
                        message: 'Unable to reach LeukQuant dashboard service.',
                        onRetry: () => ref.invalidate(overviewSummaryProvider),
                      ),
                      data: (result) => switch (result) {
                        ApiSuccess<OverviewSummary>(:final data) =>
                          _buildDashboard(context, data, colors, isReducedMotion),

                        ApiEmpty<OverviewSummary>() => _buildEmptyDashboard(context, colors, isReducedMotion),

                        ApiUnauthorized<OverviewSummary>() => const ErrorStateView(
                          message: 'Your session has expired. Please sign in again.',
                        ),

                        ApiPermissionDenied<OverviewSummary>() => const ErrorStateView(
                          message: 'Access restricted. You do not have permission to view the dashboard.',
                        ),

                        ApiRateLimited<OverviewSummary>() => ErrorStateView(
                          message: 'Too many requests. Please wait a moment and try again.',
                          onRetry: () => ref.invalidate(overviewSummaryProvider),
                        ),

                        ApiValidationError<OverviewSummary>(:final message) ||
                        ApiError<OverviewSummary>(:final message) => ErrorStateView(
                          message: message,
                          onRetry: () => ref.invalidate(overviewSummaryProvider),
                        ),

                        ApiServerError<OverviewSummary>(:final message) => ErrorStateView(
                          message: 'The LeukQuant service encountered a temporary issue. $message',
                          onRetry: () => ref.invalidate(overviewSummaryProvider),
                        ),

                        ApiServiceUnavailable<OverviewSummary>(:final message) => ErrorStateView(
                          message: message,
                          onRetry: () => ref.invalidate(overviewSummaryProvider),
                        ),
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    OverviewSummary summary,
    AppColorScheme colors,
    bool isReducedMotion,
  ) {
    return ResponsiveLayout(
      builder: (context, category, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SecurityPostureHero(
              isBackendConnected: true,
              hasActiveIncident: (summary.criticalIncidentsCount ?? 0) > 0,
              lastTelemetryTime: summary.lastEventTimestamp,
              region: summary.deploymentRegion,
            ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0, duration: 350.ms),

            const SizedBox(height: 14),

            // 4 Glass Metric Cards (2x2 Grid)
            Row(
              children: [
                Expanded(
                  child: AnimatedMetricCard(
                    title: 'Critical Alerts',
                    count: summary.criticalIncidentsCount ?? summary.stats?.criticalAlerts,
                    subtitle: 'Priority alerts',
                    icon: Icons.shield_outlined,
                    accentColor: colors.critical,
                    isPending: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedMetricCard(
                    title: 'Attacks Today',
                    count: summary.stats?.attacksToday ?? summary.highRiskEventsCount,
                    subtitle: 'Daily volume',
                    icon: Icons.warning_amber_rounded,
                    accentColor: colors.high,
                    isPending: false,
                  ),
                ),
              ],
            ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 50.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: AnimatedMetricCard(
                    title: 'Active Threats',
                    count: summary.activeThreatsCount ?? summary.stats?.activeThreats,
                    subtitle: 'Ongoing sweeps',
                    icon: Icons.hub_outlined,
                    accentColor: colors.brandPrimary,
                    isPending: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedMetricCard(
                    title: 'Blocked IPs',
                    count: summary.blockedIPsCount ?? summary.stats?.blockedIPs,
                    subtitle: 'Perimeter dropped',
                    icon: Icons.block_rounded,
                    accentColor: colors.brandSecondary,
                    isPending: false,
                  ),
                ),
              ],
            ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 90.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),

            const SizedBox(height: 14),

            RecommendedActionCard(
              title: summary.recommendedActionTitle ?? 'Security posture nominal',
              description: summary.recommendedActionDescription ?? 'No critical recommendations at this time.',
              onAction: () => context.go('/incidents'),
            ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 130.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),

            const SizedBox(height: 14),

            SecurityActivityLineChart(
              dataPoints: summary.activityTrendData,
            ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 170.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),

            const SizedBox(height: 14),

            ThreatDistributionDonutChart(
              threatData: summary.threatDistribution,
            ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 210.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),

            const SizedBox(height: 14),

            ProtocolActivityBarChart(
              protocolData: summary.protocolActivity,
            ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 250.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),

            const SizedBox(height: 14),

            RecentActivityList(
              activities: summary.recentActivities,
              isBackendConnected: true,
            ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 290.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),
          ],
        );
      },
    );
  }

  Widget _buildEmptyDashboard(
    BuildContext context,
    AppColorScheme colors,
    bool isReducedMotion,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SecurityPostureHero(
          isBackendConnected: false,
          hasActiveIncident: false,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'Critical Incidents',
                subtitle: 'Active tickets',
                icon: Icons.shield_outlined,
                accentColor: colors.critical,
                isPending: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedMetricCard(
                title: 'High-Risk Events',
                subtitle: 'High alerts',
                icon: Icons.warning_amber_rounded,
                accentColor: colors.high,
                isPending: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'Active Deployments',
                subtitle: 'Protected fleets',
                icon: Icons.hub_outlined,
                accentColor: colors.brandPrimary,
                isPending: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedMetricCard(
                title: 'Last Event',
                subtitle: 'Ingress time',
                icon: Icons.access_time_rounded,
                accentColor: colors.brandSecondary,
                isPending: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SecurityActivityLineChart(dataPoints: null),
        const SizedBox(height: 16),
        const ThreatDistributionDonutChart(threatData: null),
        const SizedBox(height: 16),
        const ProtocolActivityBarChart(protocolData: null),
      ],
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return const Column(
      children: [
        ShimmerSkeleton(height: 160, borderRadius: 28),
        SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: ShimmerSkeleton(height: 120, borderRadius: 24)),
            SizedBox(width: 12),
            Expanded(child: ShimmerSkeleton(height: 120, borderRadius: 24)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: ShimmerSkeleton(height: 120, borderRadius: 24)),
            SizedBox(width: 12),
            Expanded(child: ShimmerSkeleton(height: 120, borderRadius: 24)),
          ],
        ),
        SizedBox(height: 14),
        ShimmerSkeleton(height: 180, borderRadius: 24),
      ],
    );
  }
}
