// lib/core/widgets/glass/liquid_glass_bottom_nav.dart

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

/// Navigation item definition for LiquidGlassBottomNav.
class LiquidGlassNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool hasBadge;

  const LiquidGlassNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.hasBadge = false,
  });
}

// Backward compatibility alias
typedef GlassNavItem = LiquidGlassNavItem;

/// Ultra-smooth, professional Floating Liquid Glass Bottom Navigation Dock.
///
/// Features:
/// - Smooth organic translucency without harsh artificial lines
/// - Hardware-accelerated 24px dual-axis frosted blur optimized for 60-120fps on all devices
/// - Natural curved liquid pill with subtle ambient glow
/// - Tactile haptic feedback on tab selection
class LiquidGlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final List<LiquidGlassNavItem> items;
  final double cornerRadius;
  final double intensity;

  const LiquidGlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
    this.cornerRadius = 32.0,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const navHeight = 68.0;
    const pillHeight = 50.0;

    final clampedIntensity = intensity.clamp(0.0, 1.0);
    final effectiveBlur = 24.0 * clampedIntensity;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, math.max(12.0, bottomInset)),
      child: RepaintBoundary(
        child: Container(
          height: navHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cornerRadius),
            boxShadow: [
              // Ambient soft shadow
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.50 * clampedIntensity)
                    : const Color(0xFF1E40AF).withValues(
                        alpha: 0.10 * clampedIntensity,
                      ),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              // Soft edge glow
              BoxShadow(
                color: colors.glassEdgeGlow.withValues(
                  alpha: colors.glassEdgeGlow.a * clampedIntensity,
                ),
                blurRadius: 14,
                spreadRadius: -2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cornerRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: effectiveBlur,
                sigmaY: effectiveBlur,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xC7172033),
                            const Color(0xA8172033),
                          ]
                        : [
                            const Color(0xD8FFFFFF),
                            const Color(0xB8FFFFFF),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(cornerRadius),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.75),
                    width: 1.0,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tabWidth = constraints.maxWidth / items.length;
                    final pillWidth = tabWidth - 6.0;

                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // ── Smooth Organic Sliding Liquid Glass Pill ───────────
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          left: currentIndex * tabWidth + 3.0,
                          top: (navHeight - pillHeight) / 2,
                          child: Container(
                            width: pillWidth,
                            height: pillHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        colors.brandPrimary.withValues(alpha: 0.28),
                                        colors.brandPrimary.withValues(alpha: 0.10),
                                      ]
                                    : [
                                        colors.brandPrimary.withValues(alpha: 0.14),
                                        colors.brandPrimary.withValues(alpha: 0.05),
                                      ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark
                                    ? colors.brandPrimary.withValues(alpha: 0.45)
                                    : colors.brandPrimary.withValues(alpha: 0.28),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.brandPrimary.withValues(
                                    alpha: isDark ? 0.25 : 0.10,
                                  ),
                                  blurRadius: 12,
                                  spreadRadius: -1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── Navigation Tabs Row ────────────────────────
                        Row(
                          children: List.generate(items.length, (index) {
                            final item = items[index];
                            final isSelected = index == currentIndex;
                            final iconToDisplay = isSelected ? (item.activeIcon ?? item.icon) : item.icon;

                            final activeIconColor = isDark
                                ? Colors.white
                                : colors.brandPrimary;
                            final inactiveIconColor = isDark
                                ? Colors.white.withValues(alpha: 0.50)
                                : colors.textSecondary;

                            final activeTextColor = isDark
                                ? Colors.white
                                : colors.brandPrimary;
                            final inactiveTextColor = isDark
                                ? Colors.white.withValues(alpha: 0.50)
                                : colors.textSecondary;

                            return Expanded(
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  onItemSelected(index);
                                },
                                borderRadius: BorderRadius.circular(24),
                                splashColor: colors.brandPrimary.withValues(
                                  alpha: 0.06,
                                ),
                                highlightColor: Colors.transparent,
                                child: SizedBox(
                                  height: navHeight,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                        vertical: 4,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Icon with spring scale
                                          Stack(
                                            clipBehavior: Clip.none,
                                            alignment: Alignment.center,
                                            children: [
                                              AnimatedScale(
                                                scale: isSelected ? 1.12 : 1.0,
                                                duration: const Duration(
                                                  milliseconds: 220,
                                                ),
                                                curve: Curves.easeOutBack,
                                                child: Icon(
                                                  iconToDisplay,
                                                  size: 21,
                                                  color: isSelected
                                                      ? activeIconColor
                                                      : inactiveIconColor,
                                                ),
                                              ),

                                              // Notification badge
                                              if (item.hasBadge && !isSelected)
                                                Positioned(
                                                  top: -2,
                                                  right: -3,
                                                  child: Container(
                                                    width: 6.5,
                                                    height: 6.5,
                                                    decoration: BoxDecoration(
                                                      color: colors.critical,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: colors.critical
                                                              .withValues(alpha: 0.7),
                                                          blurRadius: 5,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 3.5),
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? activeTextColor
                                                  : inactiveTextColor,
                                              letterSpacing:
                                                  isSelected ? -0.1 : 0.0,
                                            ),
                                            child: Text(
                                              item.label,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}
