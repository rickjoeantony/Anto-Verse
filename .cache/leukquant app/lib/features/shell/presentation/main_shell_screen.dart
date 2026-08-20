// lib/features/shell/presentation/main_shell_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_bottom_nav.dart';
import '../../../core/widgets/leukquant_logo.dart';
import '../../../core/widgets/responsive_layout.dart';

/// Shell providing 4-tab customer navigation (Floating Glass Bottom Nav on mobile, Rail on wide screens).
class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final currentIndex = navigationShell.currentIndex;

    const navItems = [
      GlassNavItem(icon: Icons.home_rounded, label: 'Home'),
      GlassNavItem(icon: Icons.stream_rounded, label: 'Events', hasBadge: true),
      GlassNavItem(icon: Icons.shield_rounded, label: 'Incidents', hasBadge: true),
      GlassNavItem(icon: Icons.more_horiz_rounded, label: 'More'),
    ];

    return ResponsiveLayout(
      builder: (context, category, constraints) {
        // Desktop / Wide landscape (>= 900px) -> Navigation Rail
        if (category == ScreenCategory.desktopWide) {
          return Scaffold(
            backgroundColor: colors.background,
            body: Row(
              children: [
                NavigationRail(
                  backgroundColor: colors.surface,
                  selectedIndex: currentIndex,
                  onDestinationSelected: _onDestinationSelected,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: LeukQuantLogo(height: 32),
                  ),
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: IconThemeData(color: colors.brandPrimary),
                  selectedLabelTextStyle: TextStyle(
                    color: colors.brandPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  destinations: navItems.map((item) {
                    return NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.icon, color: colors.brandPrimary),
                      label: Text(item.label),
                    );
                  }).toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        // Phone & Tablet (< 900px) -> Floating Glass Bottom Nav inside SafeArea
        return Scaffold(
          backgroundColor: colors.background,
          extendBody: true,
          body: navigationShell,
          bottomNavigationBar: GlassBottomNav(
            currentIndex: currentIndex,
            onItemSelected: _onDestinationSelected,
            items: navItems,
          ),
        );
      },
    );
  }
}
