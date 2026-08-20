// lib/features/reports/providers/reports_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/report_item.dart';

/// Provider returning real enterprise report items from GET /api/reports.
final reportsProvider = FutureProvider<List<ReportItem>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get<dynamic>('/api/reports');
    final data = response.data;
    final List<ReportItem> list = [];

    if (data is List) {
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          list.add(ReportItem.fromJson(item));
        }
      }
    } else if (data is Map<String, dynamic> && data['reports'] is List) {
      for (final item in data['reports'] as List) {
        if (item is Map<String, dynamic>) {
          list.add(ReportItem.fromJson(item));
        }
      }
    }

    return list;
  } catch (_) {
    return const [];
  }
});
