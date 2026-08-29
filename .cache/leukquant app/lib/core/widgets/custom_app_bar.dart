// lib/core/widgets/custom_app_bar.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/theme_controller.dart';
import 'leukquant_logo.dart';

/// Ultra-premium Liquid Glass enterprise AppBar matching the reference aesthetic.
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

    return RepaintBoundary(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: colors.glassStrongFill,
              border: showBottomBorder
                  ? Border(
                      bottom: BorderSide(
                        color: colors.glassBorder,
                        width: 1.0,
                      ),
                    )
                  : null,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    // Leading Logo / Custom Leading Widget
                    leading ??
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      colors.brandPrimary.withValues(alpha: 0.35),
                                      const Color(0xFF818CF8).withValues(alpha: 0.15),
                                    ]
                                  : [
                                      const Color(0xFFEFF6FF),
                                      const Color(0xFFDBEAFE),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: colors.glassBorder,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.brandPrimary.withValues(alpha: isDark ? 0.25 : 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: LeukQuantLogo(height: 24),
                          ),
                        ),
                    const SizedBox(width: 12),

                    // Title & Subtitle Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                              letterSpacing: -0.3,
                              fontSize: 17,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),

                    // Actions: Theme Switcher & Settings/Alerts
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: colors.glassCard,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.glassBorder,
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: 'Toggle Theme',
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
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
                                size: 18,
                              ),
                            ),
                            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: colors.glassCard,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.glassBorder,
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: 'Workspace & Settings',
                            icon: Icon(
                              Icons.tune_rounded,
                              color: colors.textPrimary,
                              size: 18,
                            ),
                            onPressed: () => context.go('/more'),
                          ),
                        ),
                        if (actions != null) ...actions!,
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 62 : 56);
}
