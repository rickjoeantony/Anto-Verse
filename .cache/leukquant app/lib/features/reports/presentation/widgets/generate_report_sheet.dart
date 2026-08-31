// lib/features/reports/presentation/widgets/generate_report_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass/liquid_glass_sheet.dart';
import '../../providers/reports_provider.dart';

/// Modal bottom sheet allowing the user to configure and trigger report generation via POST /api/reports/generate.
class GenerateReportSheet extends ConsumerStatefulWidget {
  const GenerateReportSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const GenerateReportSheet(),
    );
  }

  @override
  ConsumerState<GenerateReportSheet> createState() => _GenerateReportSheetState();
}

class _GenerateReportSheetState extends ConsumerState<GenerateReportSheet> {
  String _selectedType = 'weekly';
  String _selectedPeriod = '7d';
  String _selectedFormat = 'PDF';
  bool _isGenerating = false;

  final List<Map<String, String>> _types = [
    {'id': 'weekly', 'name': 'Weekly Threat Brief', 'icon': 'shield'},
    {'id': 'compliance', 'name': 'SOC2 / Compliance Audit', 'icon': 'verified'},
    {'id': 'forensics', 'name': 'Incident Forensics Package', 'icon': 'history'},
  ];

  final List<Map<String, String>> _periods = [
    {'id': '24h', 'name': 'Past 24 Hours'},
    {'id': '7d', 'name': 'Past 7 Days'},
    {'id': '30d', 'name': 'Past 30 Days'},
    {'id': '90d', 'name': 'Quarterly (90 Days)'},
  ];

  final List<String> _formats = ['PDF', 'JSON', 'CSV'];

  Future<void> _handleGenerate() async {
    setState(() => _isGenerating = true);
    HapticFeedback.mediumImpact();

    final success = await ref.read(reportsNotifierProvider.notifier).generateNewReport(
          type: _selectedType,
          period: _selectedPeriod,
          format: _selectedFormat,
        );

    if (mounted) {
      setState(() => _isGenerating = false);
      Navigator.of(context).pop();

      final colors = AppColors.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Report compiled and generated successfully!'
                : 'Report request queued.',
          ),
          backgroundColor: colors.brandPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return LiquidGlassSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.add_chart_rounded, color: colors.brandPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Audit Report',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Trigger on-demand report compilation',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 1. Report Type Selector
          Text(
            'Report Category',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.brandPrimary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          ..._types.map((type) {
            final isSelected = _selectedType == type['id'];
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type['id']!),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.brandPrimary.withValues(alpha: 0.1)
                      : colors.surfaceMuted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? colors.brandPrimary : colors.border.withValues(alpha: 0.5),
                    width: isSelected ? 1.4 : 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 18,
                      color: isSelected ? colors.brandPrimary : colors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        type['name']!,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? colors.textPrimary : colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 14),

          // 2. Time Window / Period
          Text(
            'Coverage Period',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.brandPrimary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _periods.map((period) {
              final isSelected = _selectedPeriod == period['id'];
              return ChoiceChip(
                label: Text(period['name']!),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedPeriod = period['id']!);
                },
                selectedColor: colors.brandPrimary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? colors.brandPrimary : colors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? colors.brandPrimary : colors.border.withValues(alpha: 0.6),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // 3. Format Selector
          Text(
            'Export Format',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.brandPrimary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _formats.map((fmt) {
              final isSelected = _selectedFormat == fmt;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: isSelected ? colors.brandPrimary.withValues(alpha: 0.12) : null,
                      side: BorderSide(
                        color: isSelected ? colors.brandPrimary : colors.border.withValues(alpha: 0.6),
                        width: isSelected ? 1.4 : 0.8,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => setState(() => _selectedFormat = fmt),
                    child: Text(
                      fmt,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? colors.brandPrimary : colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          // Action: Generate Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _handleGenerate,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.bolt_rounded, size: 18),
              label: Text(
                _isGenerating ? 'Compiling Telemetry...' : 'Generate Report Now',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
