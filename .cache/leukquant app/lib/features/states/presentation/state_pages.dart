// lib/features/states/presentation/state_pages.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/states/states.dart';

/// 1. Empty State Full Screen Page
class EmptyStatePage extends StatelessWidget {
  const EmptyStatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: LeukQuantAppBar(
        title: 'Empty State',
        subtitle: 'Telemetry Monitoring',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: EmptyStateView(
          title: 'No Honeypot Triggers Recorded',
          description: 'No threat actors have engaged with your decoy fleet in the selected observation window. All sensor endpoints remain silent and armed.',
          badgeLabel: 'DECOYS STANDING BY',
          actionLabel: 'Deploy New Canary',
          onAction: () => context.push('/states/form-validation'),
          secondaryActionLabel: 'Refresh Mesh',
          onSecondaryAction: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Decoy mesh queried: 0 active intrusions recorded.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 2. Loading State Full Screen Page
class LoadingStatePage extends StatelessWidget {
  const LoadingStatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: LeukQuantAppBar(
        title: 'Loading State',
        subtitle: 'Telemetry Synchronization',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: const SafeArea(
        child: LoadingStateView(
          title: 'Synchronizing Honeytoken Mesh',
          message: 'Connecting to LeukQuant distributed SOC cluster, streaming active decoy status, and computing risk heatmaps...',
          activeStepIndex: 1,
        ),
      ),
    );
  }
}

/// 3. Error State Full Screen Page
class ErrorStatePage extends StatelessWidget {
  const ErrorStatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: LeukQuantAppBar(
        title: 'Error State',
        subtitle: 'SOC Service Failure',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ErrorStateView(
          title: 'Decoy Cluster Unreachable',
          message: 'The telemetry aggregator node in cluster [us-east-1] did not return a heartbeat within the 8,000ms threshold.',
          errorCode: 'ERR_CLUSTER_TIMEOUT_504',
          technicalDetails: 'POST /v2/telemetry/nodes/heartbeat HTTP/2\nStatus: 504 Gateway Timeout\nOrigin: cloud-ingress-02.leukquant.internal\nTLS: TLS_AES_256_GCM_SHA384 (TLSv1.3)\nTraceID: lkq-tx-9942a1-bf89\nRetry-After: 15s',
          retryLabel: 'Reconnect to Fleet',
          onRetry: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Re-initiating TLS handshake with cluster node...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          secondaryActionLabel: 'SOC Escalation',
          onSecondaryAction: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Escalation ticket #SOC-8821 opened.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 4. No Internet Full Screen Page
class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: LeukQuantAppBar(
        title: 'No Internet',
        subtitle: 'Network Connection Lost',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: NoInternetStateView(
          title: 'No Internet Connection',
          message: 'Unable to reach the LeukQuant cloud monitoring network. Local decoy caches are being utilized.',
          cachedItemsInfo: '54 incidents, 12 decoys & audit logs available offline.',
          onCheckConnection: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Checking connectivity... Connection still offline.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onOpenOfflineVault: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Viewing local encrypted SQLite cache.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 5. Slow Network Full Screen Page
class SlowNetworkPage extends StatelessWidget {
  const SlowNetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: LeukQuantAppBar(
        title: 'Slow Network',
        subtitle: 'High Latency Telemetry',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SlowNetworkStateView(
          title: 'High Network Latency Detected',
          message: 'Your current connection RTT is significantly higher than optimal. Decoy live packets may drop.',
          rttLatency: '2,140 ms',
          packetLoss: '28.4%',
          onRetry: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Re-measuring round-trip ping time...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onToggleLowBandwidth: (enabled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(enabled ? 'Low-bandwidth mode enabled.' : 'Normal streaming mode enabled.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 6. No Search Results Full Screen Page
class NoSearchResultsPage extends StatelessWidget {
  const NoSearchResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: LeukQuantAppBar(
        title: 'No Search Results',
        subtitle: 'Threat Filter Matrix',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: NoSearchResultsStateView(
          title: 'No Matching Threat Events',
          message: 'No honeytokens or intrusion records matched the applied query filters.',
          searchQuery: 'CVE-2024-38077 / RDP-CANARY',
          suggestions: const [
            'All Critical CVEs',
            'SSH Decoys',
            'SQL Injection Canaries',
            'Port 445 SMB Probes',
            'AWS STS Honeytokens',
          ],
          onSelectSuggestion: (suggestion) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Applied filter: "$suggestion"'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onClearSearch: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Search filters reset to global fleet default.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 7. Permission Denied Full Screen Page
class PermissionDeniedPage extends StatelessWidget {
  const PermissionDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: LeukQuantAppBar(
        title: 'Permission Denied',
        subtitle: 'RBAC Access Gate',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: PermissionDeniedStateView(
          title: 'Access Restricted: SOC Clearance Required',
          message: 'Provisioning live decoy nodes and updating cryptographic canary certificates requires Level 3 Decoy Commander credentials.',
          currentRole: 'SOC Analyst (Level 1)',
          requiredRole: 'SOC Decoy Commander (Level 3)',
          onRequestElevation: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Elevation request sent to Enterprise Security Administrator.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onReturn: () => context.pop(),
        ),
      ),
    );
  }
}

/// 8. Session Expired Full Screen Page
class SessionExpiredPage extends StatelessWidget {
  const SessionExpiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: LeukQuantAppBar(
        title: 'Session Expired',
        subtitle: 'Enterprise Security Lock',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SessionExpiredStateView(
          title: 'Authentication Session Expired',
          message: 'Your cryptographic identity token has expired due to 30 minutes of inactivity. Please re-authenticate to decrypt real-time logs.',
          sessionExpiryReason: 'JWT Signature Expired • IdP Inactivity Enforcement',
          onReauthenticate: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Simulating Biometric / SSO Re-authentication... Session refreshed!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onSwitchAccount: () => context.go('/login'),
        ),
      ),
    );
  }
}

/// 9. Form Validation Full Screen Page
class FormValidationPage extends StatelessWidget {
  const FormValidationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: LeukQuantAppBar(
        title: 'Form Validation',
        subtitle: 'Decoy Provisioning Rules',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: FormValidationStateView(
            onSubmitSuccess: (payload) {
              context.push('/states/success');
            },
          ),
        ),
      ),
    );
  }
}

/// 10. Success State Full Screen Page
class SuccessStatePage extends StatelessWidget {
  const SuccessStatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: LeukQuantAppBar(
        title: 'Success State',
        subtitle: 'Decoy Provisioned',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SuccessStateView(
          title: 'Decoy Node Provisioned Successfully',
          message: 'Decoy node [dc-prod-auth-decoy] is active, bound to honeypot routing tables, and reporting zero latency overhead.',
          badgeLabel: 'DEPLOYMENT CONFIRMED • ACTIVE',
          summaryMetrics: const {
            'Decoy Host': 'dc-prod-auth-decoy',
            'Subnet': '10.24.180.12/24',
            'Emulated Service': 'SSH (Port 2222)',
            'Canary Token': 'LKQ-CANARY-SECRET-9941X',
            'Latency': '12.8 ms',
            'Signature': 'Ed25519 Verified',
          },
          primaryActionLabel: 'View Decoy Fleet',
          onPrimaryAction: () => context.go('/more/deployments'),
          secondaryActionLabel: 'Return to Overview',
          onSecondaryAction: () => context.go('/overview'),
        ),
      ),
    );
  }
}
