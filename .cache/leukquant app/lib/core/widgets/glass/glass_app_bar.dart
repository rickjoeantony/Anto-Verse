// lib/core/widgets/glass/glass_app_bar.dart

import 'package:flutter/material.dart';
import 'liquid_glass_app_bar.dart';

/// Legacy wrapper for [LiquidGlassAppBar].
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isScrolled;
  final bool showBack;
  final VoidCallback? onBack;
  final double intensity;
  final double cornerRadius;

  const GlassAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.isScrolled = false,
    this.showBack = false,
    this.onBack,
    this.intensity = 1.0,
    this.cornerRadius = 0.0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return LiquidGlassAppBar(
      title: title,
      subtitle: subtitle,
      leading: leading,
      actions: actions,
      isScrolled: isScrolled,
      showBack: showBack,
      onBack: onBack,
      intensity: intensity,
      cornerRadius: cornerRadius,
    );
  }
}
