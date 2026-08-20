import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';

/// Theme selector with Light / Dark / System options.
class ThemeSelectorTile extends ConsumerWidget {
  const ThemeSelectorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, size: 20, color: colors.brandPrimary),
              const SizedBox(width: 10),
              Text(
                'Theme Mode',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3-Way Segment Selector
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.brandPrimary.withOpacity(0.12)
              : colors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colors.brandPrimary : colors.border,
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
