// lib/features/reports/presentation/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/loading_state_view.dart';
import '../providers/reports_provider.dart';
import 'widgets/generate_report_sheet.dart';
import 'widgets/report_card.dart';

/// Reports screen providing overview of real enterprise generated reports with on-demand creation.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final asyncReports = ref.watch(reportsNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => GenerateReportSheet.show(context),
        backgroundColor: colors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.bolt_rounded, size: 20),
        label: const Text(
          'Generate Report',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(reportsNotifierProvider.notifier).loadReports();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // iOS Large Title Header with Generate Action
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (Navigator.of(context).canPop()) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: colors.brandPrimary),
                                const SizedBox(width: 4),
                                Text(
                                  'Back',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colors.brandPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reports',
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 32,
                                    color: colors.textPrimary,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Executive briefs and compliance audit bundles',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.textSecondary,
                                    fontSize: 14,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton.filledTonal(
                            tooltip: 'Generate Report',
                            onPressed: () => GenerateReportSheet.show(context),
                            icon: const Icon(Icons.add_rounded, size: 22),
                            style: IconButton.styleFrom(
                              backgroundColor: colors.brandPrimary.withValues(alpha: 0.12),
                              foregroundColor: colors.brandPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Plan Quota & Cooldown Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.brandPrimary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.brandPrimary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.shield_moon_outlined, size: 16, color: colors.brandPrimary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Enterprise Allowance: Unlimited On-Demand Reports · HMAC Verified',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ...asyncReports.when(
                loading: () => [
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: LoadingStateView(message: 'Retrieving generated audit reports...'),
                  ),
                ],
                error: (err, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorStateView(
                      message: 'Unable to load reports from backend service.',
                      onRetry: () => ref.read(reportsNotifierProvider.notifier).loadReports(),
                    ),
                  ),
                ],
                data: (reportsState) {
                  final reports = reportsState.reports;
                  final cooldown = reportsState.cooldown;

                  if (reports.isEmpty) {
                    return [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 40, 24, 130),
                          child: EmptyStateView(
                            title: 'No reports generated yet',
                            description: 'Tap "Generate Report" to compile your first threat intelligence brief.',
                            icon: Icons.description_outlined,
                            actionLabel: 'Generate Report',
                            onAction: () => GenerateReportSheet.show(context),
                          ),
                        ),
                      ),
                    ];
                  }

                  return [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14.0),
                              child: ReportCard(report: reports[index])
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: (index * 40).ms)
                                  .slideY(begin: 0.04, end: 0, duration: 300.ms),
                            );
                          },
                          childCount: reports.length,
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
