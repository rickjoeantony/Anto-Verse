// lib/features/events/providers/events_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/websocket/websocket_service.dart';
import '../domain/security_event.dart';
import '../domain/severity_level.dart';

/// State notifier managing paginated and live security events.
class EventsNotifier extends StateNotifier<AsyncValue<List<SecurityEvent>>> {
  final ApiClient _apiClient;
  final Ref _ref;
  StreamSubscription<SecurityEvent>? _wsSubscription;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  EventsNotifier(this._apiClient, this._ref) : super(const AsyncValue.loading()) {
    fetchInitialEvents();

    // Listen to live WebSocket events and prepend deduplicated events
    final wsNotifier = _ref.read(webSocketProvider.notifier);
    _wsSubscription = wsNotifier.eventStream.listen((event) {
      prependLiveEvent(event);
    });
  }

  /// Initial load or pull-to-refresh
  Future<void> fetchInitialEvents() async {
    state = const AsyncValue.loading();
    _currentPage = 1;
    _hasMore = true;

    try {
      final response = await _apiClient.get<dynamic>(
        '/api/dashboard/events',
        queryParameters: {'page': 1, 'limit': 25},
      );

      final List<SecurityEvent> events = [];
      final data = response.data;

      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            events.add(SecurityEvent.fromJson(item));
          }
        }
      } else if (data is Map<String, dynamic> && data['events'] is List) {
        for (final item in data['events'] as List) {
          if (item is Map<String, dynamic>) {
            events.add(SecurityEvent.fromJson(item));
          }
        }
      }

      state = AsyncValue.data(events);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Load next page when user scrolls near the end of the list
  Future<void> fetchNextPage() async {
    if (!_hasMore || _isLoadingMore || state.isLoading) return;

    _isLoadingMore = true;
    final nextPage = _currentPage + 1;

    try {
      final response = await _apiClient.get<dynamic>(
        '/api/dashboard/events',
        queryParameters: {'page': nextPage, 'limit': 25},
      );

      final List<SecurityEvent> newEvents = [];
      final data = response.data;

      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            newEvents.add(SecurityEvent.fromJson(item));
          }
        }
      } else if (data is Map<String, dynamic> && data['events'] is List) {
        for (final item in data['events'] as List) {
          if (item is Map<String, dynamic>) {
            newEvents.add(SecurityEvent.fromJson(item));
          }
        }
      }

      if (newEvents.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        final currentList = state.valueOrNull ?? [];
        state = AsyncValue.data([...currentList, ...newEvents]);
      }
    } catch (_) {
      // Retain existing list on page fetch failure
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Prepend live event from WebSocket
  void prependLiveEvent(SecurityEvent liveEvent) {
    final currentList = state.valueOrNull ?? [];
    if (!currentList.any((e) => e.id == liveEvent.id)) {
      state = AsyncValue.data([liveEvent, ...currentList]);
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }
}

/// Global provider for paginated & live events
final eventsNotifierProvider =
    StateNotifierProvider<EventsNotifier, AsyncValue<List<SecurityEvent>>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventsNotifier(apiClient, ref);
});

/// Search query provider
final eventSearchQueryProvider = StateProvider<String>((ref) => '');

/// Severity filter provider
final eventSeverityFilterProvider = StateProvider<SeverityLevel?>((ref) => null);

/// Protocol filter provider
final eventProtocolFilterProvider = StateProvider<String?>((ref) => null);

/// Filtered events provider
final filteredEventsProvider = Provider<AsyncValue<List<SecurityEvent>>>((ref) {
  final asyncEvents = ref.watch(eventsNotifierProvider);
  final query = ref.watch(eventSearchQueryProvider).trim().toLowerCase();
  final severityFilter = ref.watch(eventSeverityFilterProvider);
  final protocolFilter = ref.watch(eventProtocolFilterProvider);

  return asyncEvents.whenData((events) {
    return events.where((event) {
      if (severityFilter != null && event.severity != severityFilter) {
        return false;
      }

      if (protocolFilter != null &&
          event.protocol.toLowerCase() != protocolFilter.toLowerCase()) {
        return false;
      }

      if (query.isNotEmpty) {
        final matchesId = event.id.toLowerCase().contains(query);
        final matchesClassification = event.classification.toLowerCase().contains(query);
        final matchesIp = event.sourceIp.toLowerCase().contains(query);
        final matchesCanary = event.canaryReference.toLowerCase().contains(query);
        final matchesProtocol = event.protocol.toLowerCase().contains(query);

        return matchesId || matchesClassification || matchesIp || matchesCanary || matchesProtocol;
      }

      return true;
    }).toList();
  });
});
