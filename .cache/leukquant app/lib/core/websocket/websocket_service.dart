// lib/core/websocket/websocket_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../features/events/domain/security_event.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';

/// Connection states for real-time WebSocket telemetry.
enum WsConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// WebSocket state notifier managing subprotocol ticket authentication,
/// auto-reconnect backoff, and event deduplication.
class WebSocketNotifier extends StateNotifier<WsConnectionState> {
  final Ref _ref;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isDisposed = false;

  // In-memory set for deduplicating recent 200 events
  final Set<String> _recentEventIds = {};

  // Broadcast stream controller for newly received live SecurityEvents
  final _eventStreamController = StreamController<SecurityEvent>.broadcast();
  Stream<SecurityEvent> get eventStream => _eventStreamController.stream;

  WebSocketNotifier(this._ref) : super(WsConnectionState.disconnected);

  /// Connect to middle-man-3 staging WebSocket using Subprotocol Ticket Authentication.
  Future<void> connect() async {
    if (_isDisposed || !AppConfig.isConfigured || AppConfig.wsBaseUrl.isEmpty) {
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
      final apiClient = _ref.read(apiClientProvider);

      // Step 1: Request short-lived single-use ticket via REST API
      final ticketResponse = await apiClient.post<Map<String, dynamic>>('/api/auth/ws-ticket');
      final ticket = ticketResponse.data?['ticket']?.toString() ??
          ticketResponse.data?['data']?['ticket']?.toString();

      if (ticket == null || ticket.isEmpty) {
        _scheduleReconnect();
        return;
      }

      // Step 2: Connect using Sec-WebSocket-Protocol subprotocol ticket authentication
      // Ticket is NOT sent in URL query parameters to avoid proxy/server log exposure.
      final wsUri = Uri.parse('${AppConfig.wsBaseUrl}/api/ws');
      _channel = WebSocketChannel.connect(
        wsUri,
        protocols: ['leukquant-ticket', ticket],
      );

      await _channel!.ready;
      state = WsConnectionState.connected;
      _reconnectAttempts = 0;

      _subscription = _channel!.stream.listen(
        _handleIncomingMessage,
        onError: (err) {
          _handleDisconnect();
        },
        onDone: () {
          _handleDisconnect();
        },
      );
    } catch (e) {
      _handleDisconnect();
    }
  }

  void _handleIncomingMessage(dynamic rawMessage) {
    try {
      final Map<String, dynamic> json = jsonDecode(rawMessage.toString());
      final eventType = json['type']?.toString();

      if (eventType == 'SECURITY_EVENT' || json.containsKey('event') || json.containsKey('classification')) {
        final Map<String, dynamic> eventData =
            (json['data'] is Map<String, dynamic>)
                ? json['data']
                : (json['event'] is Map<String, dynamic> ? json['event'] : json);

        final event = SecurityEvent.fromJson(eventData);

        // Deduplicate
        if (!_recentEventIds.contains(event.id)) {
          _recentEventIds.add(event.id);
          if (_recentEventIds.length > 200) {
            _recentEventIds.remove(_recentEventIds.first);
          }
          _eventStreamController.add(event);
        }
      }
    } catch (_) {
      // Ignored malformed telemetry frames safely
    }
  }

  void _handleDisconnect() {
    state = WsConnectionState.disconnected;
    _cleanSubscription();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed || !AppConfig.isConfigured) return;

    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    // Exponential backoff: 2s, 4s, 8s, 16s up to 30s max
    final delaySeconds = (_reconnectAttempts * 2).clamp(2, 30);
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isDisposed) {
        connect();
      }
    });
  }

  void _cleanSubscription() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  /// Disconnect stream explicitly (e.g. on user logout)
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
