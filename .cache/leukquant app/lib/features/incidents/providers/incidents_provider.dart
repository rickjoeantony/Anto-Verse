// lib/features/incidents/providers/incidents_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/api_result.dart';
import '../../events/domain/severity_level.dart';
import '../../events/providers/events_provider.dart';
import '../domain/incident.dart';

/// Provider deriving "High-Risk Activity" incidents ONLY from verified events with threatLevel >= 4.
///
/// NOTE: Backend currently has NO /api/incidents endpoint.
/// Incidents are labeled honestly as "Derived from verified events".
/// If no events with threatLevel >= 4 exist, returns ApiServiceUnavailable('Incident service awaiting backend endpoint.').
final incidentsProvider =
    FutureProvider<ApiResult<List<Incident>>>((ref) async {
  final eventsAsync = ref.watch(eventsNotifierProvider);

  return eventsAsync.when(
    loading: () => ApiEmpty(),
    error: (err, _) => ApiServiceUnavailable('Incident service awaiting backend endpoint.'),
    data: (events) {
      final highRiskEvents = events.where((e) => e.threatLevel >= 4).toList();

      if (highRiskEvents.isEmpty) {
        return ApiServiceUnavailable('Incident service awaiting backend endpoint.');
      }

      final List<Incident> derivedIncidents = highRiskEvents.map((e) {
        return Incident(
          id: 'INC-${e.id}',
          title: '${e.type} (High-Risk Ingress)',
          description: 'High-risk interaction originating from ${e.sourceIp} (${e.country}) targeting honeypot ${e.honeypot}. [Derived from verified events]',
          severity: e.threatLevel == 5 ? SeverityLevel.critical : SeverityLevel.high,
          status: e.reviewed ? 'Reviewed & Resolved' : 'Active Investigation',
          assignee: 'SOC Operations Tier 2',
          scope: 'Perimeter Sensor Cluster (${e.honeypot})',
          recommendedAction: e.recommendedAction,
          createdAt: e.timestamp,
          timeline: [
            IncidentTimelineStage(
              stage: 'Sensor Probe Intercepted',
              description: 'Observed interaction on protocol ${e.protocol} from ${e.sourceIp}.',
              timestamp: '${e.timestamp.toIso8601String().substring(11, 16)} UTC',
              isCompleted: true,
            ),
            IncidentTimelineStage(
              stage: 'Severity Assessment',
              description: 'Telemetry classified at threat level ${e.threatLevel}/5 with abuse score ${e.abuseScore.toStringAsFixed(0)}%.',
              timestamp: 'Immediate',
              isCompleted: true,
            ),
            IncidentTimelineStage(
              stage: 'Perimeter Rule',
              description: e.recommendedAction,
              timestamp: 'Enforced',
              isCompleted: true,
            ),
          ],
        );
      }).toList();

      return ApiSuccess(derivedIncidents);
    },
  );
});
