// lib/features/settings/presentation/widgets/theme_selector_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/glass/glass_card.dart';

/// Theme selector with Light / Dark / System options in frosted glass.
class ThemeSelectorTile extends ConsumerWidget {
  const ThemeSelectorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeModeProvider);

    return GlassCard(
      borderRadius: 24.0,
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.palette_outlined, size: 18, color: colors.brandPrimary),
              ),
              const SizedBox(width: 10),
              Text(
                'Appearance & Theme',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3-Way iOS Segment Selector
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  context,
                  label: 'System',
                  icon: Icons.brightness_auto_outlined,
                  isSelected: currentTheme == ThemeMode.system,
                  onTap: () =>
                      ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThemeOption(
                  context,
                  label: 'Light',
                  icon: Icons.light_mode_outlined,
                  isSelected: currentTheme == ThemeMode.light,
                  onTap: () =>
                      ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThemeOption(
                  context,
                  label: 'Dark',
                  icon: Icons.dark_mode_outlined,
                  isSelected: currentTheme == ThemeMode.dark,
                  onTap: () =>
                      ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.brandPrimary.withValues(alpha: isDark ? 0.25 : 0.14)
              : (isDark ? const Color(0x22FFFFFF) : const Color(0x0D000000)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colors.brandPrimary.withValues(alpha: isDark ? 0.6 : 0.5)
                : colors.border.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? colors.brandPrimary : colors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colors.brandPrimary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
