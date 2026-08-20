import 'package:flutter/material.dart';
import '../../features/events/domain/severity_level.dart';
import '../theme/app_colors.dart';

/// Standard enterprise severity badge with accessible contrast.
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

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: compact ? 6 : 7,
            height: compact ? 6 : 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: compact ? 10.5 : 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
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
