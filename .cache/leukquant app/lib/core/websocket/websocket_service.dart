// lib/core/websocket/websocket_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../features/events/domain/security_event.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../services/notification_service.dart';

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

  /// Token expired and refresh failed
  sessionExpired,
}

/// Robust, multi-protocol WebSocket state notifier managing middle-man-3 real-time telemetry.
class WebSocketNotifier extends StateNotifier<WsConnectionState> {
  final Ref _ref;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  bool _isDisposed = false;

  // In-memory set for deduplicating recent 200 events by ID
  final Set<String> _recentEventIds = {};

  // Broadcast stream controller for newly received live SecurityEvents
  final _eventStreamController = StreamController<SecurityEvent>.broadcast();
  Stream<SecurityEvent> get eventStream => _eventStreamController.stream;

  WebSocketNotifier(this._ref) : super(WsConnectionState.disconnected);

  /// Connect to the middle-man-3 WebSocket endpoint with heartbeat & fallback support.
  Future<void> connect() async {
    if (_isDisposed) {
      state = WsConnectionState.disconnected;
      return;
    }

    final rawBase = AppConfig.wsBaseUrl.isNotEmpty
        ? AppConfig.wsBaseUrl
        : (AppConfig.apiBaseUrl.replaceFirst(RegExp(r'^http'), 'ws'));

    if (rawBase.trim().isEmpty) {
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
      final cleanBase = rawBase.endsWith('/') ? rawBase.substring(0, rawBase.length - 1) : rawBase;
      final path = (cleanBase.endsWith('/api/ws') || cleanBase.endsWith('/ws')) ? '' : '/api/ws';
      final token = _ref.read(inMemoryTokenProvider);
      
      // Try URL with token query or clean URL
      final query = (token != null && token.isNotEmpty) ? '?token=$token' : '';
      final wsUri = Uri.parse('$cleanBase$path$query');

      if (kDebugMode) {
        debugPrint('[WebSocket] -> Connecting to $cleanBase$path');
      }

      // Connect with ticket subprotocols
      final protocols = (token != null && token.isNotEmpty)
          ? ['leukquant-ticket', token]
          : null;

      final ioCustomChannel = IOWebSocketChannel.connect(
        wsUri,
        protocols: protocols,
        pingInterval: const Duration(seconds: 15),
      );

      _channel = ioCustomChannel;
      await _channel!.ready;

      state = WsConnectionState.connected;
      _reconnectAttempts = 0;

      if (kDebugMode) {
        debugPrint('[WebSocket] <- Live connection established to telemetry stream');
      }

      // Start 15s application-layer heartbeat
      _startHeartbeat();

      _subscription = _channel!.stream.listen(
        _handleIncomingMessage,
        onError: (err) => _handleDisconnect(error: err),
        onDone: () => _handleDisconnect(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WebSocket] Handshake failed: $e. Retrying in background...');
      }
      _handleDisconnect(error: e);
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (state == WsConnectionState.connected && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
        } catch (_) {}
      }
    });
  }

  void _handleIncomingMessage(dynamic rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage.toString());
      if (decoded is Map<String, dynamic>) {
        final type = decoded['type']?.toString().toLowerCase();

        // Discard heartbeat / status frames
        if (type == 'ping' || type == 'pong' || type == 'heartbeat' || type == 'status' || type == 'connected') {
          return;
        }

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
          
          // Trigger immediate audio & push notification
          NotificationService.instance.showAttackNotification(event);
        }
      }
    } catch (_) {
      // Discard invalid telemetry frame silently
    }
  }

  void _handleDisconnect({dynamic error}) async {
    state = WsConnectionState.disconnected;
    _cleanSubscription();

    final isAuthError = error != null && error.toString().contains('401');

    if (isAuthError) {
      final apiClient = _ref.read(apiClientProvider);
      final newJwt = await apiClient.refreshJwt();
      if (newJwt != null && !_isDisposed) {
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
    if (_isDisposed) return;
    if (state == WsConnectionState.sessionExpired) return;

    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    final delaySeconds = (_reconnectAttempts * 2).clamp(2, 20);
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isDisposed) connect();
    });
  }

  void _cleanSubscription() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  /// Disconnect explicitly
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