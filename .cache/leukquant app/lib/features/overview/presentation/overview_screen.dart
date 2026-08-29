import '../../../core/services/notification_service.dart';
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
import '../../events/domain/security_event.dart';
import '../../events/domain/severity_level.dart';
import '../../events/presentation/widgets/full_screen_critical_alert_dialog.dart';
import '../../settings/providers/settings_provider.dart';
import '../domain/overview_summary.dart';
import '../providers/overview_provider.dart';
import '../../events/providers/events_provider.dart';
import '../../settings/presentation/widgets/user_avatar_widget.dart';
import '../../settings/presentation/widgets/edit_profile_sheet.dart';
import 'widgets/analytics_charts.dart';
import 'widgets/recent_activity_list.dart';
import 'widgets/recommended_action_card.dart';

/// Clean Warm Minimalist Security Overview Screen for LeukQuant.
String _formatRelativeTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

String _formatEventType(String raw) {
  final lower = raw.toLowerCase().trim();
  switch (lower) {
    case 'ddos':
      return 'DDoS Attack';
    case 'credential_stuffing':
      return 'Credential Stuffing';
    case 'brute_force':
      return 'Brute Force SSH';
    case 'injection':
    case 'sqli':
      return 'SQL Injection';
    case 'xss':
      return 'XSS Attack';
    case 'ssh':
      return 'SSH Access';
    case 'rdp':
      return 'RDP Brute Force';
    case 'ftp':
      return 'FTP Probe';
    case 'dns':
      return 'DNS Query';
    default:
      return raw.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }
}

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
            await ref.read(eventsNotifierProvider.notifier).fetchInitialEvents();
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
                        // Circular Profile Cyber Avatar with Live Pulse Ring
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            EditProfileSheet.show(context, profile);
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              UserAvatarWidget(
                                avatarKey: profile.avatar,
                                name: userName,
                                size: 48,
                                showGlow: true,
                              ),
                              // Online glowing beacon
                              Positioned(
                                bottom: -1,
                                right: -1,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF30D158),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF0B1020) : Colors.white,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF30D158).withValues(alpha: 0.6),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons: Theme Toggle + Notifications Bell
                        Row(
                          children: [
                            // Tactile Theme Mode Toggle Glass Pill
                            Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: colors.surfaceMuted,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colors.border,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    tooltip: 'Switch Theme',
                                    icon: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      transitionBuilder: (child, anim) => RotationTransition(
                                        turns: anim,
                                        child: FadeTransition(opacity: anim, child: child),
                                      ),
                                      child: Icon(
                                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                        key: ValueKey(isDark),
                                        color: isDark ? const Color(0xFFFFD60A) : colors.brandPrimary,
                                        size: 19,
                                      ),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      ref.read(themeModeProvider.notifier).toggleTheme();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Incidents Alert Bell with Live Glowing Dot
                            Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: colors.surfaceMuted,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colors.border,
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
                                    onPressed: () async {
                                      HapticFeedback.heavyImpact();
                                      await NotificationService.instance.sendTestNotification();

                                      final testEvent = SecurityEvent(
                                        id: 'crit-${DateTime.now().millisecondsSinceEpoch}',
                                        timestamp: DateTime.now(),
                                        sourceIp: '185.220.101.5',
                                        country: 'United States',
                                        countryCode: 'US',
                                        honeypot: 'SSH Decoy',
                                        protocol: 'SSH',
                                        destinationPort: '2222',
                                        threatLevel: 5,
                                        abuseScore: 98.5,
                                        reviewed: false,
                                        credentials: const [],
                                        type: 'CRITICAL SSH BRUTE FORCE INGRESS',
                                        payload: 'ssh root@sensor -p 2222 [48 Dictionary attempts/sec]',
                                        canaryReference: '',
                                        recommendedAction: 'Isolate source IP and blacklist across routing tables.',
                                        classificationReasons: const ['Rapid successive auth failure', 'Root user targeting'],
                                      );

                                      if (context.mounted) {
                                        FullScreenCriticalAlertDialog.show(context, testEvent);
                                      }
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

            RepaintBoundary(
              child: SecurityActivityLineChart(
                dataPoints: summary.activityTrendData,
              ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 170.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),
            ),

            const SizedBox(height: 14),

            RepaintBoundary(
              child: ThreatDistributionDonutChart(
                threatData: summary.threatDistribution,
              ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 210.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),
            ),

            const SizedBox(height: 14),

            RepaintBoundary(
              child: ProtocolActivityBarChart(
                protocolData: summary.protocolActivity,
              ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 250.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),
            ),

            const SizedBox(height: 14),

            RepaintBoundary(
              child: RecentActivityList(
                activities: () {
                  final live = ref.watch(eventsNotifierProvider).valueOrNull ?? [];
                  if (live.isNotEmpty) {
                    return live.take(5).map((e) {
                      final timeStr = _formatRelativeTime(e.timestamp);
                      return OverviewActivityItem(
                        id: e.id,
                        title: _formatEventType(e.type.isNotEmpty ? e.type : e.classification),
                        protocol: e.protocol,
                        timestamp: timeStr,
                        severity: e.severity,
                        description: '${e.sourceIp} â€¢ ${e.country}',
                      );
                    }).toList();
                  }
                  return summary.recentActivities;
                }(),
                isBackendConnected: true,
              ).animate(target: isReducedMotion ? 0 : 1).fadeIn(duration: 400.ms, delay: 290.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),
            ),
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
        const RepaintBoundary(child: SecurityActivityLineChart(dataPoints: null)),
        const SizedBox(height: 16),
        const RepaintBoundary(child: ThreatDistributionDonutChart(threatData: null)),
        const SizedBox(height: 16),
        const RepaintBoundary(child: ProtocolActivityBarChart(protocolData: null)),
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
