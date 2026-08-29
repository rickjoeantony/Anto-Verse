// lib/core/widgets/severity_badge.dart

import 'package:flutter/material.dart';
import '../../features/events/domain/severity_level.dart';
import '../theme/app_colors.dart';
import 'glass/liquid_glass_badge.dart';

/// Enterprise Liquid Glass severity badge with glowing indicator dot and accessible contrast.
class SeverityBadge extends StatelessWidget {
  final SeverityLevel severity;
  final bool compact;
  final String? customLabel;

  const SeverityBadge({
    super.key,
    required this.severity,
    this.compact = false,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = _getSeverityColor(colors);
    final label = customLabel ?? severity.displayName;

    return LiquidGlassBadge(
      label: label,
      color: color,
      isUppercase: true,
      fontSize: compact ? 10.5 : 11.5,
      cornerRadius: 10.0,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
    );
  }

  Color _getSeverityColor(AppColorScheme colors) {
    switch (severity) {
      case SeverityLevel.critical:
        return colors.critical;
      case SeverityLevel.high:
        return colors.high;
      case SeverityLevel.warning:
        return colors.warning;
      case SeverityLevel.info:
      case SeverityLevel.low:
        return colors.brandPrimary;
      case SeverityLevel.healthy:
      case SeverityLevel.success:
        return colors.success;
    }
  }
}
