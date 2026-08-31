// lib/features/overview/presentation/threat_map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/api_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../events/presentation/widgets/event_details_sheet.dart';
import '../../events/providers/events_provider.dart';
import '../domain/overview_summary.dart';
import '../providers/overview_provider.dart';
import 'widgets/leaflet_threat_map.dart';

/// Fullscreen Immersive Global Threat Attack Map & Cyber Command Center
class ThreatMapScreen extends ConsumerStatefulWidget {
  const ThreatMapScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const ThreatMapScreen()),
    );
  }

  @override
  ConsumerState<ThreatMapScreen> createState() => _ThreatMapScreenState();
}

class _ThreatMapScreenState extends ConsumerState<ThreatMapScreen> {
  String _selectedProtocol = 'ALL';
  final List<String> _protocols = ['ALL', 'SSH', 'HTTP', 'REDIS', 'RDP', 'TCP', 'POSTGRES'];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final events = ref.watch(eventsNotifierProvider).valueOrNull ?? [];
    final summaryResult = ref.watch(overviewSummaryProvider).valueOrNull;
    final origins = (summaryResult is ApiSuccess<OverviewSummary>)
        ? summaryResult.data.stats?.origins
        : null;

    final activeEvents = events.where((e) {
      if (_selectedProtocol == 'ALL') return true;
      return e.protocol.toUpperCase() == _selectedProtocol.toUpperCase();
    }).toList();

    final criticalCount = activeEvents.where((e) => e.threatLevel >= 4).length;
    final blockedCount = activeEvents.where((e) => e.isBlocked).length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070A11) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.brandPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Global Threat War Room',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF30D158),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${events.length} Historical & Live Telemetry Vectors',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textSecondary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.brandPrimary),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(eventsNotifierProvider.notifier).fetchInitialEvents();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Live Stats Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: [
                  _buildStatPill('TOTAL ATTACKS', '${events.length}', colors.brandPrimary, colors),
                  const SizedBox(width: 8),
                  _buildStatPill('HIGH SEVERITY', '$criticalCount', colors.critical, colors),
                  const SizedBox(width: 8),
                  _buildStatPill('BLOCKED IPS', '$blockedCount', colors.success, colors),
                ],
              ),
            ),

            // 2. Protocol Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _protocols.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final proto = _protocols[index];
                    final isSelected = _selectedProtocol == proto;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedProtocol = proto);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.brandPrimary : colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? colors.brandPrimary : colors.border.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Text(
                          proto,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : colors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 3. Leaflet OpenStreetMap World Viewport (Main Viewport)
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                child: GlassCard(
                  borderRadius: 24.0,
                  padding: const EdgeInsets.all(4.0),
                  child: LeafletThreatMap(
                    events: activeEvents,
                    origins: origins,
                    isInteractive: true,
                    selectedProtocol: _selectedProtocol,
                    onSelectEvent: (event) {
                      EventDetailsSheet.show(context, event);
                    },
                  ),
                ),
              ),
            ),

            // 4. Live Interception Stream / Ticker Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: [
                  Icon(Icons.radar_rounded, size: 15, color: colors.brandPrimary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'All Attack Vectors (${activeEvents.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.brandPrimary,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tap to inspect',
                    style: TextStyle(fontSize: 11, color: colors.textSecondary.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),

            // 5. Complete Attack History List
            Expanded(
              flex: 3,
              child: activeEvents.isEmpty
                  ? Center(
                      child: Text(
                        'No attack vectors found for $_selectedProtocol',
                        style: TextStyle(color: colors.textSecondary, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: activeEvents.length,
                      itemBuilder: (context, index) {
                        final e = activeEvents[index];
                        final isCrit = e.threatLevel >= 4;
                        return GestureDetector(
                          onTap: () => EventDetailsSheet.show(context, e),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: colors.surfaceMuted.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (isCrit ? colors.critical : colors.brandPrimary).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: isCrit ? colors.critical : colors.brandPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${e.sourceIp} (${e.country}) → ${e.honeypot}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: colors.textPrimary,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      Text(
                                        '${e.protocol} Port ${e.destinationPort} · Threat Level ${e.threatLevel}/5 · ${e.timestamp.toLocal().toString().split(".")[0]}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: e.isBlocked
                                        ? colors.success.withValues(alpha: 0.12)
                                        : colors.warning.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    e.isBlocked ? 'BLOCKED' : 'TRAPPED',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: e.isBlocked ? colors.success : colors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color accent, AppColorScheme colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: accent,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
