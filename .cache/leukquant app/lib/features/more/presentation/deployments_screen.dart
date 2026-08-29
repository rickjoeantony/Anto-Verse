// lib/features/more/presentation/deployments_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state_view.dart';

/// Screen displaying customer-friendly protected deployment sensor status.
///
/// NOTE: The middle-man-3 backend currently does not provide a dedicated /api/deployments endpoint.
/// Displays honest status: "Deployment status awaiting backend service."
class DeploymentsScreen extends ConsumerWidget {
  const DeploymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const LeukQuantAppBar(
        title: 'Deployments',
        subtitle: 'Protected Cloud & On-Premises Sensors',
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: EmptyStateView(
            icon: Icons.hub_outlined,
            title: 'Deployment status awaiting backend service.',
            description:
                'Ghost-Net sensor orchestration and deployment cluster metrics will appear here once the middle-man-3 deployment management service is online.',
          ),
        ),
      ),
    );
  }
}
