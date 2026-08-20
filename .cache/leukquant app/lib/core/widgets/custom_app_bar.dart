// lib/core/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/theme_controller.dart';
import 'leukquant_logo.dart';

/// Highly premium, reorganized enterprise AppBar with prominent LeukQuant logo.
class LeukQuantAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBottomBorder;

  const LeukQuantAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.showBottomBorder = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leadingWidth: leading != null ? 60 : 64,
      leading: leading ??
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF10172A),
                            const Color(0xFF0A0E1A),
                          ]
                        : [
                            const Color(0xFFEFF6FF),
                            const Color(0xFFDBEAFE),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? colors.brandPrimary.withValues(alpha: 0.4)
                        : colors.brandPrimary.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? colors.brandPrimary.withValues(alpha: 0.2)
                          : const Color(0x182563EB),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: LeukQuantLogo(height: 30),
                ),
              ),
            ),
          ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.4,
              fontSize: 17.5,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ),
        ],
      ),
      actions: [
        // Theme Switcher Button with animated rotation & scale
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: 'Toggle Theme',
            style: IconButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF0E1424) : const Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isDark
                      ? colors.brandPrimary.withValues(alpha: 0.3)
                      : colors.border.withValues(alpha: 0.9),
                  width: 1,
                ),
              ),
            ),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: child.key == const ValueKey('dark')
                    ? Tween<double>(begin: 0.75, end: 1.0).animate(anim)
                    : Tween<double>(begin: 0.25, end: 0.0).animate(anim),
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark ? 'dark' : 'light'),
                color: isDark ? const Color(0xFFFBBF24) : colors.brandPrimary,
                size: 19,
              ),
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
        ),

        // Quick Workspace & Settings Button
        Container(
          margin: const EdgeInsets.only(right: 14),
          child: IconButton(
            tooltip: 'Workspace & Settings',
            style: IconButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF0E1424) : const Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isDark
                      ? colors.brandPrimary.withValues(alpha: 0.3)
                      : colors.border.withValues(alpha: 0.9),
                  width: 1,
                ),
              ),
            ),
            icon: Icon(
              Icons.tune_rounded,
              color: colors.textSecondary,
              size: 19,
            ),
            onPressed: () => context.go('/more'),
          ),
        ),

        if (actions != null) ...actions!,
      ],
      bottom: showBottomBorder
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            colors.brandPrimary.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0.08),
                            Colors.transparent,
                          ]
                        : [
                            colors.brandPrimary.withValues(alpha: 0.3),
                            colors.border,
                            colors.border.withValues(alpha: 0.2),
                          ],
                  ),
                ),
                height: 1.2,
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 64 : 58);
}
