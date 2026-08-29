// lib/features/reports/presentation/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/api_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/loading_state_view.dart';
import '../domain/report_item.dart';
import '../providers/reports_provider.dart';
import 'widgets/report_card.dart';

/// Reports screen providing overview of real enterprise generated reports.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final asyncReports = ref.watch(reportsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(reportsProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // iOS Large Title Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
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
                      onRetry: () => ref.invalidate(reportsProvider),
                    ),
                  ),
                ],
                data: (result) => _buildSlivers(context, ref, result, colors),
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
    ApiResult<List<ReportItem>> result,
    AppColorScheme colors,
  ) {
    return switch (result) {
      ApiSuccess<List<ReportItem>>(:final data) => [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: ReportCard(report: data[index])
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

      ApiEmpty<List<ReportItem>>() => [
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 40, 24, 130),
              child: EmptyStateView(
                title: 'No reports have been generated yet.',
                description:
                    'Verified security briefs and audit export bundles will appear here once compiled by the reporting engine.',
                icon: Icons.description_outlined,
              ),
            ),
          ),
        ],

      ApiUnauthorized<List<ReportItem>>() => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: 'Your session has expired. Please sign in again.',
              onRetry: () => ref.invalidate(reportsProvider),
            ),
          ),
        ],

      ApiPermissionDenied<List<ReportItem>>() => const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: 'Access restricted. You do not have permission to view reports. Contact your administrator.',
            ),
          ),
        ],

      ApiRateLimited<List<ReportItem>>() => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: 'Too many requests. Please wait a moment and try again.',
              onRetry: () => ref.invalidate(reportsProvider),
            ),
          ),
        ],

      ApiValidationError<List<ReportItem>>(:final message) => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: 'Request error: $message',
              onRetry: () => ref.invalidate(reportsProvider),
            ),
          ),
        ],

      ApiServerError<List<ReportItem>>(:final message) => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: 'The LeukQuant reporting service encountered a temporary issue. $message',
              onRetry: () => ref.invalidate(reportsProvider),
            ),
          ),
        ],

      ApiServiceUnavailable<List<ReportItem>>(:final message) => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: message,
              onRetry: () => ref.invalidate(reportsProvider),
            ),
          ),
        ],

      ApiError<List<ReportItem>>(:final message) => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateView(
              message: message,
              onRetry: () => ref.invalidate(reportsProvider),
            ),
          ),
        ],
    };
  }
}
