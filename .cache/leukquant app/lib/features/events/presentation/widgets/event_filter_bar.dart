import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/severity_level.dart';
import '../../providers/events_provider.dart';

/// Clean enterprise filter bar for search, severity, and protocol filtering.
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
    final theme = Theme.of(context);
    final selectedSeverity = ref.watch(eventSeverityFilterProvider);
    final selectedProtocol = ref.watch(eventProtocolFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        TextField(
          controller: _searchController,
          onChanged: (value) => ref.read(eventSearchQueryProvider.notifier).state = value,
          decoration: InputDecoration(
            hintText: 'Search events by ID, IP, protocol...',
            prefixIcon: Icon(Icons.search_rounded, size: 20, color: colors.textSecondary),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, size: 18, color: colors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(eventSearchQueryProvider.notifier).state = '';
                      setState(() {});
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        // Severity Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                'Severity: ',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              _buildSeverityChip(
                label: 'All',
                isSelected: selectedSeverity == null,
                onSelected: () =>
                    ref.read(eventSeverityFilterProvider.notifier).state = null,
              ),
              _buildSeverityChip(
                label: 'Critical',
                isSelected: selectedSeverity == SeverityLevel.critical,
                color: colors.critical,
                onSelected: () => ref
                    .read(eventSeverityFilterProvider.notifier)
                    .state = SeverityLevel.critical,
              ),
              _buildSeverityChip(
                label: 'High',
                isSelected: selectedSeverity == SeverityLevel.high,
                color: colors.high,
                onSelected: () => ref
                    .read(eventSeverityFilterProvider.notifier)
                    .state = SeverityLevel.high,
              ),
              _buildSeverityChip(
                label: 'Warning',
                isSelected: selectedSeverity == SeverityLevel.warning,
                color: colors.warning,
                onSelected: () => ref
                    .read(eventSeverityFilterProvider.notifier)
                    .state = SeverityLevel.warning,
              ),
              _buildSeverityChip(
                label: 'Info',
                isSelected: selectedSeverity == SeverityLevel.info,
                color: colors.brandPrimary,
                onSelected: () => ref
                    .read(eventSeverityFilterProvider.notifier)
                    .state = SeverityLevel.info,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Protocol Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                'Protocol: ',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              _buildProtocolChip(
                label: 'All',
                isSelected: selectedProtocol == null,
                onSelected: () =>
                    ref.read(eventProtocolFilterProvider.notifier).state = null,
              ),
              ...['SSH', 'HTTPS', 'PostgreSQL', 'DNS'].map(
                (proto) => _buildProtocolChip(
                  label: proto,
                  isSelected: selectedProtocol == proto,
                  onSelected: () => ref
                      .read(eventProtocolFilterProvider.notifier)
                      .state = selectedProtocol == proto ? null : proto,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeverityChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onSelected,
  }) {
    final colors = AppColors.of(context);
    final activeColor = color ?? colors.brandPrimary;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: activeColor.withOpacity(0.18),
        checkmarkColor: activeColor,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? activeColor : colors.textSecondary,
        ),
        side: BorderSide(
          color: isSelected ? activeColor : colors.border,
          width: 1,
        ),
        backgroundColor: colors.surfaceMuted,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildProtocolChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: colors.brandSecondary.withOpacity(0.18),
        checkmarkColor: colors.brandSecondary,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? colors.brandSecondary : colors.textSecondary,
        ),
        side: BorderSide(
          color: isSelected ? colors.brandSecondary : colors.border,
          width: 1,
        ),
        backgroundColor: colors.surfaceMuted,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
