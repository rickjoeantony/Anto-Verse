// lib/core/network/network_status_provider.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_state_provider.dart';
import '../config/app_config.dart';
import '../websocket/websocket_service.dart';

/// Physical network connectivity state (Wi-Fi/Cellular)
enum PhysicalNetworkStatus {
  available,
  unavailable,
}

/// Middle-Man-3 API reachability state
enum ApiReachability {
  unconfigured,
  reachable,
  unreachable,
}

/// Unified App Connection States as specified in RULE 5
enum AppConnectionState {
  notConfigured,
  networkOffline,
  backendUnavailable,
  sessionExpired,
  rateLimited,
  connected,
  syncing,
  live,
}

/// Legacy/Badge compatibility enum
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

/// One consistent status source provider across the entire application (RULE 5).
final appConnectionStateProvider = Provider<AppConnectionState>((ref) {
  if (!AppConfig.isConfigured) {
    return AppConnectionState.notConfigured;
  }

  final isNetworkAvailable = ref.watch(isNetworkAvailableProvider);
  if (!isNetworkAvailable) {
    return AppConnectionState.networkOffline;
  }

  final authState = ref.watch(authProvider);
  if (authState.isRateLimited) {
    return AppConnectionState.rateLimited;
  }
  if (authState.isSessionExpired) {
    return AppConnectionState.sessionExpired;
  }

  final apiReachability = ref.watch(apiReachabilityProvider);
  if (apiReachability == ApiReachability.unreachable) {
    return AppConnectionState.backendUnavailable;
  }

  final wsState = ref.watch(webSocketProvider);
  if (wsState == WsConnectionState.connected) {
    return AppConnectionState.live;
  }
  if (wsState == WsConnectionState.connecting || wsState == WsConnectionState.reconnecting) {
    return AppConnectionState.syncing;
  }

  return AppConnectionState.connected;
});

/// Unified backend badge provider separating physical network from API and WebSocket health.
final backendStatusBadgeProvider = Provider<BackendStatusBadge>((ref) {
  final appState = ref.watch(appConnectionStateProvider);
  switch (appState) {
    case AppConnectionState.notConfigured:
      return BackendStatusBadge.notConfigured;
    case AppConnectionState.networkOffline:
      return BackendStatusBadge.networkOffline;
    case AppConnectionState.backendUnavailable:
      return BackendStatusBadge.backendUnavailable;
    case AppConnectionState.live:
      return BackendStatusBadge.live;
    case AppConnectionState.syncing:
    case AppConnectionState.connected:
    case AppConnectionState.rateLimited:
    case AppConnectionState.sessionExpired:
      return BackendStatusBadge.syncing;
  }
});
