// lib/widgets/bottom_nav_bar.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';

/// Global bottom navigation bar for the app shell.
class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  static const _navItems = [
    {'label': 'Home', 'icon': Icons.home_rounded, 'path': '/overview'},
    {'label': 'Events', 'icon': Icons.stream_rounded, 'path': '/events'},
    {'label': 'Incidents', 'icon': Icons.shield_rounded, 'path': '/incidents'},
    {'label': 'Reports', 'icon': Icons.description_rounded, 'path': '/reports'},
    {'label': 'More', 'icon': Icons.more_horiz_rounded, 'path': '/more'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final router = GoRouter.of(context);
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = _navItems.indexWhere((i) => location.startsWith(i['path'] as String));
    if (currentIndex == -1) currentIndex = 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        height: 68,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xCC0E1829) : const Color(0xE6FFFFFF),
          borderRadius: BorderRadius.circular(34),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.85),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : const Color(0x18007AFF),
              blurRadius: 32,
              spreadRadius: -2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Row(
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final selected = index == currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => router.go(item['path'] as String),
                    borderRadius: BorderRadius.circular(24),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 21,
                          color: selected ? colors.brandPrimary : colors.textSecondary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? colors.brandPrimary : colors.textSecondary,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
