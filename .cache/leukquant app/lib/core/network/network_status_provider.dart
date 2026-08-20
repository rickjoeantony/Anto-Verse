// lib/core/network/network_status_provider.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../websocket/websocket_service.dart';
import '../../features/auth/providers/auth_state_provider.dart';

/// Physical network connectivity state (Wi-Fi/Cellular)
enum PhysicalNetworkStatus {
  available,
  unavailable,
}

/// Staging API reachability state
enum ApiReachability {
  unconfigured,
  reachable,
  unreachable,
}

/// Composite application & backend state badge
enum BackendStatusBadge {
  notConfigured,
  networkOffline,
  backendUnavailable,
  syncing,
  live,
}

/// Stream provider for physical network connectivity (Wi-Fi/Mobile).
final physicalNetworkStatusProvider = StreamProvider<PhysicalNetworkStatus>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged.map((results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      return PhysicalNetworkStatus.unavailable;
    }
    return PhysicalNetworkStatus.available;
  });
});

/// Boolean provider indicating if the device has physical network access.
final isNetworkAvailableProvider = Provider<bool>((ref) {
  final status = ref.watch(physicalNetworkStatusProvider).valueOrNull;
  return status != PhysicalNetworkStatus.unavailable;
});

/// State provider for tracking middle-man-3 API reachability.
final apiReachabilityProvider = StateProvider<ApiReachability>((ref) {
  if (!AppConfig.isConfigured) {
    return ApiReachability.unconfigured;
  }
  return ApiReachability.reachable;
});

/// Unified backend badge provider separating physical network from API and WebSocket health.
final backendStatusBadgeProvider = Provider<BackendStatusBadge>((ref) {
  if (!AppConfig.isConfigured) {
    return BackendStatusBadge.notConfigured;
  }

  final isNetworkAvailable = ref.watch(isNetworkAvailableProvider);
  if (!isNetworkAvailable) {
    return BackendStatusBadge.networkOffline;
  }

  final apiReachability = ref.watch(apiReachabilityProvider);
  if (apiReachability == ApiReachability.unreachable) {
    return BackendStatusBadge.backendUnavailable;
  }

  final wsState = ref.watch(webSocketProvider);
  if (wsState == WsConnectionState.connected) {
    return BackendStatusBadge.live;
  }

  return BackendStatusBadge.syncing;
});
