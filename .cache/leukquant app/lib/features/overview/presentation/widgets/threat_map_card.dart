// lib/features/overview/presentation/widgets/threat_map_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/glass_card.dart';
import '../../../events/providers/events_provider.dart';
import '../../domain/overview_summary.dart';
import '../../providers/overview_provider.dart';
import '../threat_map_screen.dart';
import 'leaflet_threat_map.dart';

/// Enhanced interactive Leaflet cyber threat map card on the overview dashboard.
class ThreatMapCard extends ConsumerWidget {
  const ThreatMapCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final events = ref.watch(eventsNotifierProvider).valueOrNull ?? [];
    final summaryAsync = ref.watch(overviewSummaryProvider);
    final summaryResult = summaryAsync.valueOrNull;
    final origins = (summaryResult is ApiSuccess<OverviewSummary>)
        ? summaryResult.data.stats?.origins
        : null;

    final uniqueCountries = <String, int>{};
    for (final e in events) {
      final country = e.country.isNotEmpty ? e.country : 'Unknown';
      uniqueCountries[country] = (uniqueCountries[country] ?? 0) + 1;
    }

    final topOrigins = uniqueCountries.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlassCard(
      borderRadius: 24.0,
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Full-Screen Button
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.public_rounded, size: 19, color: colors.brandPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Global Threat Intelligence Map',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Leaflet OpenStreetMap · Real Geolocation',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colors.textSecondary.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              // Open Fullscreen War Room Button
              IconButton.filledTonal(
                tooltip: 'Open War Room',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ThreatMapScreen.show(context);
                },
                icon: const Icon(Icons.fullscreen_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: colors.brandPrimary.withValues(alpha: 0.12),
                  foregroundColor: colors.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Real Leaflet Threat Map Viewport (Cyber Dark Canvas)
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF060B14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF00D4FF).withValues(alpha: 0.25),
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: LeafletThreatMap(
              events: events,
              origins: origins,
              isInteractive: true,
            ),
          ),
          const SizedBox(height: 12),

          // Top Ingress Origins Tags + Live Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Attack Vectors',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.brandPrimary,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                '${events.length} Interceptions Logged',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: topOrigins.take(5).map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined, size: 12, color: colors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.key} · ${entry.value}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
