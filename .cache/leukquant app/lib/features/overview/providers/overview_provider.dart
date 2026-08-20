// lib/features/overview/providers/overview_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/overview_summary.dart';

/// Provider for overview metrics and health summary connected to real staging API.
final overviewSummaryProvider = FutureProvider<OverviewSummary>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get<Map<String, dynamic>>('/api/dashboard/stats');
    if (response.data != null) {
      return OverviewSummary.fromJson(response.data!);
    }
  } catch (_) {
    // Return calm awaiting state if backend stats endpoint is pending/offline
  }

  return OverviewSummary.awaitingBackend();
});
