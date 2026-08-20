// lib/features/reports/presentation/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/loading_state_view.dart';
import '../providers/reports_provider.dart';
import 'widgets/report_card.dart';

/// Reports screen providing overview of real enterprise generated reports.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final asyncReports = ref.watch(reportsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const LeukQuantAppBar(
        title: 'Reports',
        subtitle: 'Executive & Audit Exports',
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(reportsProvider);
          },
          child: asyncReports.when(
            loading: () => const LoadingStateView(message: 'Retrieving generated audit reports...'),
            error: (err, _) => ErrorStateView(
              message: 'Unable to load reports from backend service.',
              onRetry: () => ref.invalidate(reportsProvider),
            ),
            data: (reports) {
              if (reports.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 40),
                    const EmptyStateView(
                      title: 'No Reports Generated Yet',
                      description:
                          'Verified security briefs and audit export bundles will appear here once compiled by the reporting engine.',
                      icon: Icons.description_outlined,
                    ).animate().fadeIn(duration: 400.ms),
                  ],
                );
              }

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return ReportCard(report: reports[index])
                      .animate()
                      .fadeIn(duration: 350.ms, delay: (index * 50).ms)
                      .slideY(begin: 0.08, end: 0, duration: 350.ms);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
