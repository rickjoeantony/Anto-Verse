// lib/features/overview/providers/overview_provider.dart

import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/api_result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../events/domain/security_event.dart';
import '../../events/domain/severity_level.dart';
import '../../events/providers/events_provider.dart';
import '../domain/overview_summary.dart';

String _formatRelativeTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

String _formatEventType(String raw) {
  final lower = raw.toLowerCase().trim();
  switch (lower) {
    case 'ddos':
      return 'DDoS Attack';
    case 'credential_stuffing':
      return 'Credential Stuffing';
    case 'brute_force':
      return 'Brute Force SSH';
    case 'injection':
    case 'sqli':
      return 'SQL Injection';
    case 'xss':
      return 'XSS Attack';
    case 'ssh':
      return 'SSH Access';
    case 'rdp':
      return 'RDP Brute Force';
    case 'ftp':
      return 'FTP Probe';
    case 'dns':
      return 'DNS Query';
    default:
      return raw.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }
}

String _canonicalPortKey(String raw) {
  final lower = raw.toLowerCase().trim();
  if (lower.contains('ssh') || lower.contains('brute_force') || lower == '22') {
    return 'SSH';
  }
  if (lower.contains('http') || lower.contains('credential') || lower.contains('stuffing') || lower == '80') {
    return 'HTTP';
  }
  if (lower.contains('ddos') || lower.contains('udp') || lower.contains('flood')) {
    return 'DDoS';
  }
  if (lower.contains('injection') || lower.contains('sql') || lower == '3306' || lower == '5432') {
    return 'SQLi';
  }
  if (lower.contains('xss') || lower.contains('https') || lower == '443') {
    return 'XSS';
  }
  if (lower.contains('rdp') || lower == '3389') {
    return 'RDP';
  }
  if (lower.contains('ftp') || lower == '21') {
    return 'FTP';
  }
  if (lower.contains('dns') || lower == '53') {
    return 'DNS';
  }
  return raw.toUpperCase();
}

/// Provider for overview metrics and health summary connected to GET /api/dashboard/stats
/// and dynamically enriched with 100% REAL live telemetry events from GET /api/dashboard/events.
final overviewSummaryProvider =
    FutureProvider<ApiResult<OverviewSummary>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final eventsAsync = ref.watch(eventsNotifierProvider);

  try {
    final response = await apiClient.getDashboardStats();
    if (response.data != null) {
      var summary = OverviewSummary.fromJson(response.data!);

      // Resolve real live events: either from events notifier or direct API fetch
      List<SecurityEvent> liveEvents = eventsAsync.valueOrNull ?? [];
      if (liveEvents.isEmpty) {
        try {
          final eventsResponse = await apiClient.getDashboardEvents(limit: 50, page: 1);
          final data = eventsResponse.data;
          if (data is List) {
            liveEvents = data
                .whereType<Map<String, dynamic>>()
                .map((json) => SecurityEvent.fromJson(json))
                .toList();
          } else if (data is Map<String, dynamic> && data['events'] is List) {
            liveEvents = (data['events'] as List)
                .whereType<Map<String, dynamic>>()
                .map((json) => SecurityEvent.fromJson(json))
                .toList();
          }
        } catch (_) {
          // Keep liveEvents empty if backend endpoint is unreachable
        }
      }

      if (liveEvents.isNotEmpty) {
        // 1. Real Recent Activities List (Take top 5 real events)
        final recentActivities = liveEvents.take(5).map((e) {
          final timeStr = _formatRelativeTime(e.timestamp);
          return OverviewActivityItem(
            id: e.id,
            title: _formatEventType(e.type.isNotEmpty ? e.type : e.classification),
            protocol: e.protocol,
            timestamp: timeStr,
            severity: e.severity,
            description: '${e.sourceIp} â€¢ ${e.country}',
          );
        }).toList();

        // 2. Real Attacks Today Count
        final now = DateTime.now();
        final attacksToday = liveEvents.where((e) {
          final local = e.timestamp.toLocal();
          return local.year == now.year &&
                 local.month == now.month &&
                 local.day == now.day;
        }).length;

        // 3. Real 24h Activity Trend Curve (6 4-hour buckets based strictly on actual event timestamps)
        final buckets = List<double>.filled(6, 0.0);
        for (final ev in liveEvents) {
          final diffHours = now.difference(ev.timestamp).inHours;
          if (diffHours >= 0 && diffHours < 24) {
            final bucketIdx = (5 - (diffHours ~/ 4)).clamp(0, 5);
            buckets[bucketIdx] += 1.0;
          }
        }

        // 4. Real Protocol Activity (Strictly real protocols recorded, grouped canonically)
        final realProtocols = <String, double>{};
        for (final ev in liveEvents) {
          final rawKey = ev.type.isNotEmpty ? ev.type : ev.protocol;
          final key = _canonicalPortKey(rawKey);
          realProtocols[key] = (realProtocols[key] ?? 0.0) + 1.0;
        }

        // 5. Real Threat Level Distribution
        final realThreats = <String, double>{};
        for (final ev in liveEvents) {
          final lvlKey = ev.threatLevel.toString();
          realThreats[lvlKey] = (realThreats[lvlKey] ?? 0.0) + 1.0;
        }

        final realCriticalAlerts = liveEvents.where((e) => e.severity == SeverityLevel.critical || e.threatLevel == 5).length;
        final totalCount = math.max(summary.totalAttacksCount ?? 0, liveEvents.length);

        summary = summary.copyWith(
          recentActivities: recentActivities,
          activityTrendData: buckets,
          protocolActivity: realProtocols.isNotEmpty ? realProtocols : summary.protocolActivity,
          threatDistribution: realThreats.isNotEmpty ? realThreats : summary.threatDistribution,
          totalAttacksCount: totalCount,
          highRiskEventsCount: attacksToday > 0 ? attacksToday : (summary.highRiskEventsCount ?? 0),
          criticalIncidentsCount: realCriticalAlerts > 0 ? realCriticalAlerts : summary.criticalIncidentsCount,
        );
      }

      return ApiSuccess(summary);
    }
    return ApiEmpty();
  } on ApiException catch (e) {
    if (e.isSessionExpired) return ApiUnauthorized();
    if (e.isPermissionDenied) return ApiPermissionDenied();
    if (e.isRateLimited) return ApiRateLimited();
    if (e.isRequestError) return ApiValidationError(e.message);
    if (e.isServerError) return ApiServerError(e.message);
    if (e.isOffline || e.errorType == ApiErrorCode.backendUnavailable) {
      return ApiServiceUnavailable('Awaiting backend data');
    }
    return ApiError(e.message);
  } catch (e) {
    return ApiError('Awaiting backend data');
  }
});