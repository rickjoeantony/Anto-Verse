// lib/features/incidents/providers/incidents_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/api_result.dart';
import '../../events/domain/severity_level.dart';
import '../../events/providers/events_provider.dart';
import '../domain/incident.dart';

/// Provider deriving security incident investigations from all verified attack telemetry events.
final incidentsProvider =
    FutureProvider<ApiResult<List<Incident>>>((ref) async {
  final eventsAsync = ref.watch(eventsNotifierProvider);

  return eventsAsync.when(
    loading: () => ApiEmpty(),
    error: (err, _) => ApiServiceUnavailable('Incident service awaiting backend endpoint.'),
    data: (events) {
      if (events.isEmpty) {
        return ApiEmpty();
      }

      final List<Incident> derivedIncidents = events.map((e) {
        final sev = switch (e.threatLevel) {
          5 => SeverityLevel.critical,
          4 => SeverityLevel.high,
          3 => SeverityLevel.warning,
          2 => SeverityLevel.low,
          _ => e.severity,
        };

        final status = e.reviewed
            ? 'Reviewed & Resolved'
            : (e.isBlocked ? 'Contained & Blocked' : 'Active Investigation');

        return Incident(
          id: 'INC-${e.id}',
          title: '${e.type} (Decoy Ingress)',
          description:
              'Security telemetry interaction originating from ${e.sourceIp} (${e.country}) targeting decoy sensor ${e.honeypot} on port ${e.destinationPort}.',
          severity: sev,
          status: status,
          assignee: 'SOC Autonomous Engine',
          scope: 'Perimeter Sensor Cluster (${e.honeypot})',
          recommendedAction: e.recommendedAction,
          createdAt: e.timestamp,
          sourceIp: e.sourceIp,
          country: e.country,
          targetPort: e.destinationPort,
          protocol: e.protocol,
          payload: e.payload,
          isBlocked: e.isBlocked,
          abuseScore: e.abuseScore,
          timeline: [
            IncidentTimelineStage(
              stage: 'Decoy Trap Interception',
              description:
                  'Attacker ${e.sourceIp} initiated unauthorized ${e.protocol} connection on port ${e.destinationPort}.',
              timestamp: '${e.timestamp.toUtc().toString().substring(11, 16)} UTC',
              isCompleted: true,
            ),
            IncidentTimelineStage(
              stage: 'Behavioral & Payload Analysis',
              description:
                  'Classified at Threat Level ${e.threatLevel}/5 (Abuse Score: ${e.abuseScore.toStringAsFixed(0)}%). Payload: ${e.payload.length > 50 ? "${e.payload.substring(0, 47)}..." : e.payload}',
              timestamp: 'Immediate',
              isCompleted: true,
            ),
            IncidentTimelineStage(
              stage: e.isBlocked ? 'Autonomous Ingress Block' : 'Firewall Containment',
              description: e.isBlocked
                  ? 'Attacker IP ${e.sourceIp} was automatically blocked by honeypot defense.'
                  : e.recommendedAction,
              timestamp: 'Enforced',
              isCompleted: true,
            ),
            IncidentTimelineStage(
              stage: 'Forensic Telemetry Logging',
              description:
                  'Credentials and forensic payload safely isolated and archived for SOC review.',
              timestamp: 'Completed',
              isCompleted: e.reviewed || e.isBlocked,
            ),
          ],
        );
      }).toList();

      return ApiSuccess(derivedIncidents);
    },
  );
});
