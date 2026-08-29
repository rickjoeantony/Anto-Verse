import '../../../core/services/notification_service.dart';
// lib/features/events/providers/events_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/websocket/websocket_service.dart';
import '../domain/security_event.dart';
import '../domain/severity_level.dart';

/// State notifier managing paginated and live security events from GET /api/dashboard/events?limit=50.
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

  /// Initial load: GET /api/dashboard/events?limit=50
  Future<void> fetchInitialEvents() async {
    state = const AsyncValue.loading();
    _currentPage = 1;
    _hasMore = true;

    try {
      final response = await _apiClient.getDashboardEvents(limit: 50, page: 1);

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

  /// Load next page when scrolling near end
  Future<void> fetchNextPage() async {
    if (!_hasMore || _isLoadingMore || state.isLoading) return;

    _isLoadingMore = true;
    final nextPage = _currentPage + 1;

    try {
      final response = await _apiClient.getDashboardEvents(limit: 50, page: nextPage);

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
      // Keep existing list on page fetch failure
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Mark event reviewed via PATCH /api/events/:id
  Future<bool> markReviewed(String eventId, bool reviewed) async {
    try {
      await _apiClient.patchEvent(eventId, {'reviewed': reviewed});
      final currentList = state.valueOrNull ?? [];
      state = AsyncValue.data(
        currentList.map((e) => e.id == eventId ? e.copyWith(reviewed: reviewed) : e).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Prepend live event from WebSocket and notify user on mobile
  void prependLiveEvent(SecurityEvent liveEvent) {
    final currentList = state.valueOrNull ?? [];
    if (!currentList.any((e) => e.id == liveEvent.id)) {
      state = AsyncValue.data([liveEvent, ...currentList]);
      // Trigger instant mobile push/local notification for live attack
      NotificationService.instance.showAttackNotification(liveEvent);
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

/// Protocol / Vector filter provider (e.g. 'SSH', 'HTTP', 'DDoS', 'SQLi', 'DNS')
final eventProtocolFilterProvider = StateProvider<String?>((ref) => null);

/// Filtered events provider
final filteredEventsProvider = Provider<AsyncValue<List<SecurityEvent>>>((ref) {
  final asyncEvents = ref.watch(eventsNotifierProvider);
  final query = ref.watch(eventSearchQueryProvider).trim().toLowerCase();
  final severityFilter = ref.watch(eventSeverityFilterProvider);
  final protocolFilter = ref.watch(eventProtocolFilterProvider);

  return asyncEvents.whenData((events) {
    return events.where((event) {
      // 1. Severity filter
      if (severityFilter != null && event.severity != severityFilter) {
        return false;
      }

      // 2. Protocol / Vector / Service filter
      if (protocolFilter != null) {
        final pf = protocolFilter.toLowerCase();
        final rawType = event.type.toLowerCase();
        final rawProto = event.protocol.toLowerCase();
        final rawClass = event.classification.toLowerCase();
        final rawHoneypot = event.honeypot.toLowerCase();
        final rawPort = event.destinationPort.toLowerCase();

        bool matches = false;
        if (pf == 'ssh') {
          matches = rawType.contains('ssh') || rawType.contains('brute_force') || rawProto.contains('ssh') || rawPort == '22' || rawHoneypot.contains('ssh');
        } else if (pf == 'http' || pf == 'https' || pf == 'web') {
          matches = rawType.contains('http') || rawType.contains('credential') || rawType.contains('stuffing') || rawType.contains('xss') || rawPort == '80' || rawPort == '443' || rawProto.contains('http');
        } else if (pf == 'ddos') {
          matches = rawType.contains('ddos') || rawType.contains('udp') || rawProto.contains('udp');
        } else if (pf == 'sqli' || pf == 'sql') {
          matches = rawType.contains('injection') || rawType.contains('sql') || rawPort == '3306' || rawPort == '5432';
        } else if (pf == 'dns') {
          matches = rawType.contains('dns') || rawProto.contains('dns') || rawPort == '53';
        } else {
          matches = rawType.contains(pf) || rawProto.contains(pf) || rawClass.contains(pf) || rawHoneypot.contains(pf);
        }

        if (!matches) {
          return false;
        }
      }

      // 3. Text Search Query
      if (query.isNotEmpty) {
        final matchesId = event.id.toLowerCase().contains(query);
        final matchesType = event.type.toLowerCase().contains(query);
        final matchesClassification = event.classification.toLowerCase().contains(query);
        final matchesIp = event.sourceIp.toLowerCase().contains(query);
        final matchesCountry = event.country.toLowerCase().contains(query);
        final matchesHoneypot = event.honeypot.toLowerCase().contains(query);
        final matchesProtocol = event.protocol.toLowerCase().contains(query);
        final matchesPort = event.destinationPort.toLowerCase().contains(query);

        return matchesId || matchesType || matchesClassification || matchesIp || matchesCountry || matchesHoneypot || matchesProtocol || matchesPort;
      }

      return true;
    }).toList();
  });
});