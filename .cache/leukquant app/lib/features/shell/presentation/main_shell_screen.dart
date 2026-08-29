// lib/features/shell/presentation/main_shell_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/glass_bottom_nav.dart';
import '../../../core/widgets/leukquant_logo.dart';
import '../../../core/widgets/responsive_layout.dart';

/// Shell providing 5-tab customer navigation with dreamy ambient background mesh.
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
      GlassNavItem(
        icon: Icons.grid_view_rounded,
        activeIcon: Icons.grid_view_rounded,
        label: 'Overview',
      ),
      GlassNavItem(
        icon: Icons.sensors_rounded,
        activeIcon: Icons.sensors_rounded,
        label: 'Events',
      ),
      GlassNavItem(
        icon: Icons.shield_rounded,
        activeIcon: Icons.shield_rounded,
        label: 'Incidents',
      ),
      GlassNavItem(
        icon: Icons.insert_chart_rounded,
        activeIcon: Icons.insert_chart_rounded,
        label: 'Reports',
      ),
      GlassNavItem(
        icon: Icons.tune_rounded,
        activeIcon: Icons.tune_rounded,
        label: 'More',
      ),
    ];

    return ResponsiveLayout(
      builder: (context, category, constraints) {
        // Desktop / Wide landscape (>= 900px) -> Navigation Rail
        if (category == ScreenCategory.desktopWide) {
          return Scaffold(
            backgroundColor: colors.background,
            body: AmbientBackground(
              child: Row(
                children: [
                  NavigationRail(
                    backgroundColor: Colors.transparent,
                    selectedIndex: currentIndex,
                    onDestinationSelected: _onDestinationSelected,
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: LeukQuantLogo(height: 32),
                    ),
                    labelType: NavigationRailLabelType.all,
                    selectedIconTheme: const IconThemeData(color: Colors.black),
                    selectedLabelTextStyle: const TextStyle(
                      color: Colors.black,
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
                        icon: Icon(item.icon, color: Colors.black.withValues(alpha: 0.6)),
                        selectedIcon: Icon(item.icon, color: Colors.black),
                        label: Text(item.label),
                      );
                    }).toList(),
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(child: navigationShell),
                ],
              ),
            ),
          );
        }

        // Phone & Tablet (< 900px) -> Floating Glass Bottom Nav with Ambient Background
        return Scaffold(
          backgroundColor: colors.background,
          extendBody: true,
          body: AmbientBackground(
            child: navigationShell,
          ),
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
