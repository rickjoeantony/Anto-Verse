import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass/liquid_glass_badge.dart';

/// A rounded Liquid Glass chip used to display status information.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.color,
    this.textColor,
  });

  final String status;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final effectiveColor = color ?? appColors.brandSecondary;
    return LiquidGlassBadge(
      label: status,
      color: textColor ?? effectiveColor,
      showDot: true,
      fontSize: 11.0,
      cornerRadius: 12.0,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }
}
