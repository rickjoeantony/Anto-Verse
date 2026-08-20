// lib/core/widgets/glass_bottom_nav.dart

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Navigation item definition for GlassBottomNav.
class GlassNavItem {
  final IconData icon;
  final String label;
  final bool hasBadge;

  const GlassNavItem({
    required this.icon,
    required this.label,
    this.hasBadge = false,
  });
}

/// Ultra-resilient, futuristic floating glass bottom navigation dock.
/// Features rich spring transitions, icon scaling micro-animations, and full active pill coverage.
class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final List<GlassNavItem> items;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final navHeight = 74.0;
    final pillHeight = 54.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, math.max(10.0, bottomInset)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: navHeight,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xEB000000) // True OLED Pitch Black Glass
              : const Color(0xF5FFFFFF), // Crisp Clean Glass
          borderRadius: BorderRadius.circular(34),
          border: Border.all(
            color: isDark
                ? colors.brandPrimary.withValues(alpha: 0.3)
                : colors.brandPrimary.withValues(alpha: 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.65)
                  : const Color(0x1F2563EB),
              blurRadius: 36,
              spreadRadius: -2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / items.length;
                final pillWidth = tabWidth - 6.0;

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Spring Animated Active Glass Capsule
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      left: currentIndex * tabWidth + 3.0,
                      top: (navHeight - pillHeight) / 2,
                      child: Container(
                        width: pillWidth,
                        height: pillHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    colors.brandPrimary.withValues(alpha: 0.32),
                                    colors.brandPrimary.withValues(alpha: 0.12),
                                  ]
                                : [
                                    colors.brandPrimary.withValues(alpha: 0.20),
                                    colors.brandPrimary.withValues(alpha: 0.06),
                                  ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: colors.brandPrimary.withValues(alpha: isDark ? 0.55 : 0.4),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.brandPrimary.withValues(alpha: isDark ? 0.25 : 0.14),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Destination Tabs Row with Rich Micro-Interactions
                    Row(
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        final isSelected = index == currentIndex;

                        return Expanded(
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onItemSelected(index);
                            },
                            borderRadius: BorderRadius.circular(24),
                            splashColor: colors.brandPrimary.withValues(alpha: 0.1),
                            highlightColor: Colors.transparent,
                            child: SizedBox(
                              height: navHeight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          AnimatedScale(
                                            scale: isSelected ? 1.18 : 1.0,
                                            duration: const Duration(milliseconds: 240),
                                            curve: Curves.easeOutBack,
                                            child: Icon(
                                              item.icon,
                                              size: 22,
                                              color: isSelected
                                                  ? (isDark ? colors.brandPrimary : colors.brandPrimaryDark)
                                                  : colors.textSecondary.withValues(alpha: 0.75),
                                            ),
                                          ),
                                          if (item.hasBadge && !isSelected)
                                            Positioned(
                                              top: -2,
                                              right: -3,
                                              child: Container(
                                                width: 7,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                  color: colors.warning,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: colors.warning.withValues(alpha: 0.6),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 220),
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                          color: isSelected
                                              ? (isDark ? colors.brandPrimary : colors.brandPrimaryDark)
                                              : colors.textSecondary,
                                          fontFamily: 'sans-serif',
                                          letterSpacing: 0.2,
                                        ),
                                        child: Text(
                                          item.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      // Active Glowing Micro Indicator
                                      AnimatedOpacity(
                                        opacity: isSelected ? 1.0 : 0.0,
                                        duration: const Duration(milliseconds: 200),
                                        child: Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: colors.brandPrimary,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: colors.brandPrimary.withValues(alpha: 0.8),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
