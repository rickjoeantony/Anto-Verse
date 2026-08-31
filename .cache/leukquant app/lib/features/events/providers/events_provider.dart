// lib/features/events/providers/events_provider.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/websocket/websocket_service.dart';
import '../presentation/widgets/full_screen_critical_alert_dialog.dart';
import '../domain/security_event.dart';
import '../domain/severity_level.dart';

/// State notifier managing paginated and live security events from GET /api/dashboard/events.
class EventsNotifier extends StateNotifier<AsyncValue<List<SecurityEvent>>> {
  final ApiClient _apiClient;
  final Ref _ref;
  StreamSubscription<SecurityEvent>? _wsSubscription;
  Timer? _pollingTimer;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  EventsNotifier(this._apiClient, this._ref) : super(const AsyncValue.loading()) {
    fetchInitialEvents();

    // 1. Establish live WebSocket telemetry stream
    final wsNotifier = _ref.read(webSocketProvider.notifier);
    wsNotifier.connect();

    _wsSubscription = wsNotifier.eventStream.listen((event) {
      prependLiveEvent(event);
    });

    // 2. Continuous real-time polling sync (every 6 seconds) for immediate alert dispatch
    _startPeriodicPolling();
  }

  void _startPeriodicPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 6), (_) async {
      try {
        final response = await _apiClient.getDashboardEvents(limit: 10, page: 1);
        final data = response.data;
        final List<SecurityEvent> latest = [];

        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              latest.add(SecurityEvent.fromJson(item));
            }
          }
        } else if (data is Map<String, dynamic> && data['events'] is List) {
          for (final item in data['events'] as List) {
            if (item is Map<String, dynamic>) {
              latest.add(SecurityEvent.fromJson(item));
            }
          }
        }

        final currentList = state.valueOrNull ?? [];
        for (final ev in latest.reversed) {
          if (!currentList.any((e) => e.id == ev.id)) {
            prependLiveEvent(ev);
          }
        }
      } catch (_) {
        // Continue polling
      }
    });
  }

  /// Comprehensive initial load: Aggregates all historical attack records across multiple pages and endpoints
  Future<void> fetchInitialEvents() async {
    state = const AsyncValue.loading();
    _currentPage = 1;
    _hasMore = true;

    final Map<String, SecurityEvent> eventsMap = {};

    void parseAndAdd(dynamic data) {
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            final ev = SecurityEvent.fromJson(item);
            eventsMap[ev.id] = ev;
          }
        }
      } else if (data is Map<String, dynamic>) {
        final list = data['events'] ?? data['attacks'] ?? data['data'] ?? data['items'];
        if (list is List) {
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              final ev = SecurityEvent.fromJson(item);
              eventsMap[ev.id] = ev;
            }
          }
        }
      }
    }

    try {
      // Execute multi-source parallel fetch across all historical pages
      final results = await Future.wait([
        _apiClient.getDashboardEvents(limit: 500, page: 1),
        _apiClient.getDashboardEvents(limit: 500, page: 2).catchError((_) => Response(requestOptions: RequestOptions(path: ''))),
        _apiClient.getDashboardAttacks(limit: 500).catchError((_) => Response(requestOptions: RequestOptions(path: ''))),
        _apiClient.getHistoricalEvents(limit: 500, page: 1).catchError((_) => Response(requestOptions: RequestOptions(path: ''))),
        _apiClient.getHistoricalAttacks(limit: 500).catchError((_) => Response(requestOptions: RequestOptions(path: ''))),
      ]);

      for (final res in results) {
        if (res.data != null) {
          parseAndAdd(res.data);
        }
      }

      final allEvents = eventsMap.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      state = AsyncValue.data(allEvents);
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
      final response = await _apiClient.getDashboardEvents(limit: 100, page: nextPage);

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
        final combined = [...currentList];
        for (final item in newEvents) {
          if (!combined.any((e) => e.id == item.id)) {
            combined.add(item);
          }
        }
        combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        state = AsyncValue.data(combined);
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

  /// Prepend live event from WebSocket / polling and trigger real-time mobile notification
  void prependLiveEvent(SecurityEvent liveEvent) {
    final currentList = state.valueOrNull ?? [];
    if (!currentList.any((e) => e.id == liveEvent.id)) {
      state = AsyncValue.data([liveEvent, ...currentList]);
      
      // 1. Hardware audio & system notification
      NotificationService.instance.showAttackNotification(liveEvent);

      // 2. Full-Screen Tactical Alert Modal for Critical Attacks (Threat Level 4-5 / Critical Severity / Abuse > 75)
      final isCritical = liveEvent.severity == SeverityLevel.critical ||
          liveEvent.threatLevel >= 4 ||
          liveEvent.abuseScore >= 75 ||
          liveEvent.type.toLowerCase().contains('brute') ||
          liveEvent.type.toLowerCase().contains('injection');

      if (isCritical) {
        final context = rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          FullScreenCriticalAlertDialog.show(context, liveEvent);
        }
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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

/// Filter state providers
final eventSeverityFilterProvider = StateProvider<SeverityLevel?>((ref) => null);
final eventProtocolFilterProvider = StateProvider<String?>((ref) => null);
final eventSearchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered events provider
final filteredEventsProvider = Provider<AsyncValue<List<SecurityEvent>>>((ref) {
  final eventsAsync = ref.watch(eventsNotifierProvider);
  final severityFilter = ref.watch(eventSeverityFilterProvider);
  final protocolFilter = ref.watch(eventProtocolFilterProvider);
  final searchQuery = ref.watch(eventSearchQueryProvider).toLowerCase().trim();

  return eventsAsync.whenData((events) {
    return events.where((event) {
      // Severity Filter
      if (severityFilter != null && event.severity != severityFilter) {
        return false;
      }

      // Protocol Filter
      if (protocolFilter != null &&
          event.protocol.toLowerCase() != protocolFilter.toLowerCase() &&
          event.destinationPort != protocolFilter) {
        return false;
      }

      // Search Query Filter
      if (searchQuery.isNotEmpty) {
        final matchesIp = event.sourceIp.toLowerCase().contains(searchQuery);
        final matchesCountry = event.country.toLowerCase().contains(searchQuery);
        final matchesType = event.type.toLowerCase().contains(searchQuery);
        final matchesPayload = event.payload.toLowerCase().contains(searchQuery);
        final matchesUser = event.credentials.any((c) => c.username.toLowerCase().contains(searchQuery));

        if (!matchesIp && !matchesCountry && !matchesType && !matchesPayload && !matchesUser) {
          return false;
        }
      }

      return true;
    }).toList();
  });
});