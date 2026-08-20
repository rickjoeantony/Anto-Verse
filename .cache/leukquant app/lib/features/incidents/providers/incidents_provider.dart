// lib/features/incidents/providers/incidents_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/incident.dart';

/// Provider for real incidents list from staging backend.
final incidentsProvider = FutureProvider<List<Incident>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get<dynamic>('/api/incidents');
    final data = response.data;
    final List<Incident> list = [];

    if (data is List) {
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          list.add(Incident.fromJson(item));
        }
      }
    } else if (data is Map<String, dynamic> && data['incidents'] is List) {
      for (final item in data['incidents'] as List) {
        if (item is Map<String, dynamic>) {
          list.add(Incident.fromJson(item));
        }
      }
    }

    return list;
  } catch (_) {
    // Graceful fallback to empty list (triggers clean "Incident service awaiting backend connection" UI)
    return const [];
  }
});
