// lib/core/widgets/glass/glass_bottom_nav.dart

import 'package:flutter/material.dart';
import 'liquid_glass_bottom_nav.dart';

export 'liquid_glass_bottom_nav.dart' show GlassNavItem, LiquidGlassNavItem;

/// Legacy wrapper for [LiquidGlassBottomNav].
class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final List<LiquidGlassNavItem> items;
  final double cornerRadius;
  final double intensity;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
    this.cornerRadius = 38.0,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBottomNav(
      currentIndex: currentIndex,
      onItemSelected: onItemSelected,
      items: items,
      cornerRadius: cornerRadius,
      intensity: intensity,
    );
  }
}
