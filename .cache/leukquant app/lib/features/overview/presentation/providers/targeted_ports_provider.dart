// lib/features/overview/presentation/providers/targeted_ports_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/port_attack_summary.dart';

/// Provider that fetches targeted decoy ports analytics from staging backend.
final targetedPortsProvider = FutureProvider.autoDispose<List<PortAttackSummary>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get<dynamic>('/api/port-attack-stats');
    final data = response.data;
    final List<PortAttackSummary> list = [];

    if (data is List) {
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          list.add(PortAttackSummary.fromJson(item));
        }
      }
    } else if (data is Map<String, dynamic> && data['ports'] is List) {
      for (final item in data['ports'] as List) {
        if (item is Map<String, dynamic>) {
          list.add(PortAttackSummary.fromJson(item));
        }
      }
    }
    return list;
  } catch (_) {
    return const [];
  }
});
