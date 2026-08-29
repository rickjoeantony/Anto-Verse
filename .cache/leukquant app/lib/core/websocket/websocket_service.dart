// lib/core/websocket/websocket_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../features/events/domain/security_event.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';

/// Connection states for real-time WebSocket telemetry.
enum WsConnectionState {
  /// No connection or explicitly disconnected (Offline)
  disconnected,

  /// Establishing WebSocket handshake
  connecting,

  /// WebSocket is open and streaming telemetry
  connected,

  /// Lost connection; auto-reconnecting with backoff
  reconnecting,

  /// Token expired and refresh failed — user session expired
  sessionExpired,
}

/// WebSocket state notifier managing middle-man-3 real-time telemetry stream.
///
/// SECURITY & PRIVACY CONTRACT:
/// - Connects to WS_BASE_URL + /api/ws?token=<jwt> using in-memory 15-min JWT.
/// - NEVER logs the full WebSocket URL or token parameter anywhere.
/// - Automatically dedupes events by ID.
/// - On 401/expiry: calls POST /api/auth/refresh to rotate JWT, then reconnects.
/// - If refresh fails, disconnects and transitions to sessionExpired state.
/// - URL with token is NEVER written to SharedPreferences or disk.
class WebSocketNotifier extends StateNotifier<WsConnectionState> {
  final Ref _ref;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isDisposed = false;

  // In-memory set for deduplicating recent 200 events by ID
  final Set<String> _recentEventIds = {};

  // Broadcast stream controller for newly received live SecurityEvents
  final _eventStreamController = StreamController<SecurityEvent>.broadcast();
  Stream<SecurityEvent> get eventStream => _eventStreamController.stream;

  WebSocketNotifier(this._ref) : super(WsConnectionState.disconnected);

  /// Connect to the middle-man-3 WebSocket endpoint.
  Future<void> connect() async {
    if (_isDisposed) {
      state = WsConnectionState.disconnected;
      return;
    }

    if (!AppConfig.isConfigured || AppConfig.wsBaseUrl.isEmpty) {
      state = WsConnectionState.disconnected;
      return;
    }

    final token = _ref.read(inMemoryTokenProvider);
    if (token == null || token.isEmpty) {
      state = WsConnectionState.disconnected;
      return;
    }

    if (state == WsConnectionState.connected || state == WsConnectionState.connecting) {
      return;
    }

    state = _reconnectAttempts > 0
        ? WsConnectionState.reconnecting
        : WsConnectionState.connecting;

    try {
      // Build WebSocket URL with query parameter token
      final wsUri = Uri.parse('${AppConfig.wsBaseUrl}/api/ws?token=$token');

      // CRITICAL SECURITY RULE: NEVER log the full URL or token
      if (kDebugMode) {
        debugPrint('[WebSocket] -> Connecting to ${AppConfig.wsBaseUrl}/api/ws?token=[REDACTED]');
      }

      _channel = WebSocketChannel.connect(wsUri);
      await _channel!.ready;

      state = WsConnectionState.connected;
      _reconnectAttempts = 0;

      if (kDebugMode) {
        debugPrint('[WebSocket] <- Connected to telemetry stream');
      }

      _subscription = _channel!.stream.listen(
        _handleIncomingMessage,
        onError: (err) => _handleDisconnect(error: err),
        onDone: () => _handleDisconnect(),
      );
    } catch (e) {
      _handleDisconnect(error: e);
    }
  }

  void _handleIncomingMessage(dynamic rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage.toString());
      if (decoded is Map<String, dynamic>) {
        final Map<String, dynamic> eventData =
            (decoded['data'] is Map<String, dynamic>)
                ? decoded['data']
                : (decoded['event'] is Map<String, dynamic> ? decoded['event'] : decoded);

        final event = SecurityEvent.fromJson(eventData);

        // Deduplicate: ring-buffer of last 200 event IDs
        if (!_recentEventIds.contains(event.id)) {
          _recentEventIds.add(event.id);
          if (_recentEventIds.length > 200) {
            _recentEventIds.remove(_recentEventIds.first);
          }
          _eventStreamController.add(event);
        }
      }
    } catch (_) {
      // Discard invalid telemetry frame silently
    }
  }

  void _handleDisconnect({dynamic error}) async {
    state = WsConnectionState.disconnected;
    _cleanSubscription();

    // Check if disconnection was due to token expiry/auth error
    final isAuthError = error != null && error.toString().contains('401');

    if (isAuthError) {
      // Attempt token refresh
      final apiClient = _ref.read(apiClientProvider);
      final newJwt = await apiClient.refreshJwt();
      if (newJwt != null && !_isDisposed) {
        // Reconnect with new token
        unawaited(connect());
        return;
      } else {
        state = WsConnectionState.sessionExpired;
        return;
      }
    }

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed || !AppConfig.isConfigured) return;
    if (state == WsConnectionState.sessionExpired) return;

    final token = _ref.read(inMemoryTokenProvider);
    if (token == null) return;

    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    // Exponential backoff: 2s, 4s, 8s, 16s up to 30s max
    final delaySeconds = (_reconnectAttempts * 2).clamp(2, 30);
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isDisposed) connect();
    });
  }

  void _cleanSubscription() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  /// Disconnect explicitly (e.g. on user logout).
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    _cleanSubscription();
    state = WsConnectionState.disconnected;
  }

  @override
  void dispose() {
    _isDisposed = true;
    disconnect();
    _eventStreamController.close();
    super.dispose();
  }
}

/// Global provider for WebSocket connection state.
final webSocketProvider =
    StateNotifierProvider<WebSocketNotifier, WsConnectionState>((ref) {
  return WebSocketNotifier(ref);
});

/// Stream provider for live inbound security events.
final liveEventsStreamProvider = StreamProvider<SecurityEvent>((ref) {
  final notifier = ref.watch(webSocketProvider.notifier);
  return notifier.eventStream;
});
