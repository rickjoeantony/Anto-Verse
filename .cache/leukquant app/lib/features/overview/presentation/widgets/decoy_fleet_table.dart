// lib/features/overview/presentation/widgets/decoy_fleet_table.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/glass_card.dart';

class DecoyNodeData {
  final String name;
  final String port;
  final String protocol;
  final String isolation;
  final String status;
  final String latency;

  const DecoyNodeData({
    required this.name,
    required this.port,
    required this.protocol,
    required this.isolation,
    required this.status,
    required this.latency,
  });
}

/// Glassmorphic data table displaying active decoy honeypot fleet status.
class DecoyFleetTable extends StatelessWidget {
  final List<DecoyNodeData> nodes;

  const DecoyFleetTable({
    super.key,
    required this.nodes,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GlassCard(
      borderRadius: 24.0,
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Controlled Decoy Fleet Matrix',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Active canary listener nodes & isolation telemetry',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${nodes.length} ACTIVE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: colors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                colors.brandPrimary.withValues(alpha: 0.08),
              ),
              horizontalMargin: 12,
              columnSpacing: 18,
              headingTextStyle: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: colors.textSecondary,
                letterSpacing: 0.4,
              ),
              columns: const [
                DataColumn(label: Text('DECOY SERVICE')),
                DataColumn(label: Text('PORT')),
                DataColumn(label: Text('PROTOCOL')),
                DataColumn(label: Text('ISOLATION')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('LATENCY')),
              ],
              rows: nodes.map((node) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        node.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.brandPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        node.port,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colors.border),
                        ),
                        child: Text(
                          node.protocol,
                          style: TextStyle(fontSize: 10.5, color: colors.textPrimary),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        node.isolation,
                        style: TextStyle(
                          color: colors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colors.success.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          node.status,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: colors.success,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        node.latency,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
