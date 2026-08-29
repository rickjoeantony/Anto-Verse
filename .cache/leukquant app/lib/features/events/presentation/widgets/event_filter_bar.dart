// lib/features/events/presentation/widgets/event_filter_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/severity_level.dart';
import '../../providers/events_provider.dart';

/// Clean, luxury iOS filter bar with unified single-row filter stream and disciplined palette.
class EventFilterBar extends ConsumerStatefulWidget {
  const EventFilterBar({super.key});

  @override
  ConsumerState<EventFilterBar> createState() => _EventFilterBarState();
}

class _EventFilterBarState extends ConsumerState<EventFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(eventSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedSeverity = ref.watch(eventSeverityFilterProvider);
    final selectedProtocol = ref.watch(eventProtocolFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search Input (Sleek Apple Inset) ────────────────────────
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) =>
                ref.read(eventSearchQueryProvider.notifier).state = value,
            style: TextStyle(
              fontSize: 13.5,
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Search events by ID, IP, protocol...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: colors.textSecondary.withValues(alpha: 0.60),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 18,
                color: colors.textSecondary.withValues(alpha: 0.65),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _searchController.clear();
                        ref.read(eventSearchQueryProvider.notifier).state = '';
                        setState(() {});
                      },
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 16,
                        color: colors.textSecondary.withValues(alpha: 0.6),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── Unified Minimalist Filter Chips Track ────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // All Filter
              _FilterChip(
                label: 'All Signals',
                isSelected: selectedSeverity == null && selectedProtocol == null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(eventSeverityFilterProvider.notifier).state = null;
                  ref.read(eventProtocolFilterProvider.notifier).state = null;
                },
              ),

              // Severity Category Divider
              _FilterDivider(isDark: isDark),

              // Critical
              _FilterChip(
                label: 'Critical',
                dotColor: colors.critical,
                isSelected: selectedSeverity == SeverityLevel.critical,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(eventSeverityFilterProvider.notifier).state =
                      selectedSeverity == SeverityLevel.critical
                          ? null
                          : SeverityLevel.critical;
                },
              ),

              // High
              _FilterChip(
                label: 'High',
                dotColor: colors.high,
                isSelected: selectedSeverity == SeverityLevel.high,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(eventSeverityFilterProvider.notifier).state =
                      selectedSeverity == SeverityLevel.high
                          ? null
                          : SeverityLevel.high;
                },
              ),

              // Warning
              _FilterChip(
                label: 'Warning',
                dotColor: colors.warning,
                isSelected: selectedSeverity == SeverityLevel.warning,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(eventSeverityFilterProvider.notifier).state =
                      selectedSeverity == SeverityLevel.warning
                          ? null
                          : SeverityLevel.warning;
                },
              ),

              // Protocol Category Divider
              _FilterDivider(isDark: isDark),

              // Protocols
              ...['SSH', 'HTTPS', 'PostgreSQL', 'DNS'].map(
                (proto) => _FilterChip(
                  label: proto,
                  isSelected: selectedProtocol == proto,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(eventProtocolFilterProvider.notifier).state =
                        selectedProtocol == proto ? null : proto;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? dotColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.dotColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white.withValues(alpha: 0.16) : Colors.black.withValues(alpha: 0.09))
                : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.white.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.20))
                  : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 5.5,
                  height: 5.5,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: dotColor!.withValues(alpha: 0.7),
                              blurRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? colors.textPrimary
                      : colors.textSecondary.withValues(alpha: 0.75),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDivider extends StatelessWidget {
  final bool isDark;

  const _FilterDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.black.withValues(alpha: 0.08),
    );
  }
}
