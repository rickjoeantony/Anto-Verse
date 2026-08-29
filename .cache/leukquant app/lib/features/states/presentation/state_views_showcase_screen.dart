// lib/features/states/presentation/state_views_showcase_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/states/states.dart';

/// Interactive State Views Showcase Screen
/// Allows exploring, previewing, testing, and navigating to all 10 cyber states.
class StateViewsShowcaseScreen extends StatefulWidget {
  final int initialIndex;

  const StateViewsShowcaseScreen({super.key, this.initialIndex = 0});

  @override
  State<StateViewsShowcaseScreen> createState() => _StateViewsShowcaseScreenState();
}

class _StateViewsShowcaseScreenState extends State<StateViewsShowcaseScreen> {
  late int _selectedIndex;
  bool _isCardMode = false;

  final List<({String title, String route, IconData icon, String subtitle})> _statesList = const [
    (title: 'Empty State', route: '/states/empty', icon: Icons.shield_outlined, subtitle: 'Clean slate & no active threats'),
    (title: 'Loading State', route: '/states/loading', icon: Icons.radar_rounded, subtitle: 'Telemetry sync & radar sweep'),
    (title: 'Error State', route: '/states/error', icon: Icons.warning_amber_rounded, subtitle: '504 gateway & diagnostics trace'),
    (title: 'No Internet', route: '/states/no-internet', icon: Icons.wifi_off_rounded, subtitle: 'Offline mode & ping test'),
    (title: 'Slow Network', route: '/states/slow-network', icon: Icons.speed_rounded, subtitle: 'High RTT & bandwidth saver'),
    (title: 'No Search Results', route: '/states/no-search', icon: Icons.search_off_rounded, subtitle: 'Query mismatch & tag suggestions'),
    (title: 'Permission Denied', route: '/states/permission-denied', icon: Icons.lock_person_rounded, subtitle: '403 RBAC gate & role elevation'),
    (title: 'Session Expired', route: '/states/session-expired', icon: Icons.timer_off_rounded, subtitle: 'JWT timeout & biometric unlock'),
    (title: 'Form Validation', route: '/states/form-validation', icon: Icons.rule_folder_outlined, subtitle: 'Live decoy rules & field errors'),
    (title: 'Success State', route: '/states/success', icon: Icons.check_circle_outline_rounded, subtitle: 'Decoy provisioned & verification'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, _statesList.length - 1);
  }

  Widget _buildActiveStateWidget() {
    switch (_selectedIndex) {
      case 0:
        return EmptyStateView(
          isCard: _isCardMode,
          actionLabel: 'Deploy New Canary',
          onAction: () => context.push('/states/form-validation'),
          secondaryActionLabel: 'Test SnackBar',
          onSecondaryAction: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Empty state action triggered successfully!'), behavior: SnackBarBehavior.floating),
            );
          },
        );
      case 1:
        return LoadingStateView(
          isCard: _isCardMode,
          activeStepIndex: 1,
        );
      case 2:
        return ErrorStateView(
          isCard: _isCardMode,
          onRetry: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Re-initiating TLS connection...'), behavior: SnackBarBehavior.floating),
            );
          },
          onSecondaryAction: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Escalation ticket #SOC-8821 opened.'), behavior: SnackBarBehavior.floating),
            );
          },
        );
      case 3:
        return NoInternetStateView(
          isCard: _isCardMode,
          onOpenOfflineVault: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening encrypted offline SQLite storage...'), behavior: SnackBarBehavior.floating),
            );
          },
        );
      case 4:
        return SlowNetworkStateView(
          isCard: _isCardMode,
          onRetry: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Re-measuring round-trip ping time...'), behavior: SnackBarBehavior.floating),
            );
          },
        );
      case 5:
        return NoSearchResultsStateView(
          isCard: _isCardMode,
          searchQuery: 'CVE-2024-38077 / RDP-CANARY',
          onSelectSuggestion: (tag) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Filter set to "$tag"'), behavior: SnackBarBehavior.floating),
            );
          },
          onClearSearch: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search filters cleared.'), behavior: SnackBarBehavior.floating),
            );
          },
        );
      case 6:
        return PermissionDeniedStateView(
          isCard: _isCardMode,
          onRequestElevation: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Request dispatched to SOC Commander.'), behavior: SnackBarBehavior.floating),
            );
          },
          onReturn: () => setState(() => _selectedIndex = 0),
        );
      case 7:
        return SessionExpiredStateView(
          isCard: _isCardMode,
          onReauthenticate: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Biometric auth verified! Session active.'), behavior: SnackBarBehavior.floating),
            );
          },
          onSwitchAccount: () => context.go('/login'),
        );
      case 8:
        return FormValidationStateView(
          isCard: _isCardMode,
          onSubmitSuccess: (payload) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Decoy "${payload['nodeName']}" validated!'),
                backgroundColor: AppColors.of(context).success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      case 9:
        return SuccessStateView(
          isCard: _isCardMode,
          onPrimaryAction: () => context.go('/more/deployments'),
          onSecondaryAction: () => context.go('/overview'),
        );
      default:
        return const Center(child: Text('Unknown State'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentItem = _statesList[_selectedIndex];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: LeukQuantAppBar(
        title: 'State Views & Edge Cases',
        subtitle: 'Enterprise UI System (10 Pages)',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Horizontal State Selector Pills
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _statesList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = _statesList[index];
                  final isSelected = index == _selectedIndex;

                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 14,
                          color: isSelected ? Colors.white : (isDark ? colors.brandPrimary : colors.textPrimary),
                        ),
                        const SizedBox(width: 6),
                        Text(item.title),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: colors.brandPrimary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : colors.textPrimary,
                    ),
                    backgroundColor: colors.surface,
                    side: BorderSide(
                      color: isSelected ? colors.brandPrimary : colors.border,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedIndex = index);
                      }
                    },
                  );
                },
              ),
            ),

            // 2. Control & Quick Actions Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceMuted.withValues(alpha: isDark ? 0.6 : 0.8),
                border: Border(
                  top: BorderSide(color: colors.border.withValues(alpha: 0.6)),
                  bottom: BorderSide(color: colors.border.withValues(alpha: 0.6)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedIndex + 1}. ${currentItem.title}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          currentItem.subtitle,
                          style: TextStyle(fontSize: 11, color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  // Toggle Embed vs Full Preview
                  IconButton(
                    tooltip: _isCardMode ? 'Switch to Full Page Mode' : 'Switch to Card Mode',
                    icon: Icon(
                      _isCardMode ? Icons.aspect_ratio_rounded : Icons.crop_din_rounded,
                      size: 20,
                      color: colors.brandPrimary,
                    ),
                    onPressed: () => setState(() => _isCardMode = !_isCardMode),
                  ),

                  // Open Full Page Route
                  ElevatedButton.icon(
                    onPressed: () => context.push(currentItem.route),
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: const Text('Open Page', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: colors.brandPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Main Live State Preview Area
            Expanded(
              child: Container(
                padding: _isCardMode ? const EdgeInsets.all(16) : EdgeInsets.zero,
                child: _buildActiveStateWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
