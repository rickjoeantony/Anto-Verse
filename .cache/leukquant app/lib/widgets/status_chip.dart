import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A rounded chip used to display status information.
///
/// The [status] string is shown as the label. The [color] determines the
/// background colour of the chip. If [color] is null, the chip will use the
/// secondary colour from the app theme.
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
    final bg = color ?? appColors.brandSecondary;
    final txt = textColor ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: txt,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
