// lib/core/network/api_interceptor.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

typedef TokenProvider = String? Function();
typedef SessionExpiredCallback = void Function();

/// Security-conscious Dio interceptor:
/// 1. Attaches in-memory Bearer token
/// 2. Sanitizes headers & bodies to prevent credential logging
/// 3. Intercepts 401 responses to trigger graceful re-login
class ApiInterceptor extends Interceptor {
  final TokenProvider _tokenProvider;
  final SessionExpiredCallback? _onSessionExpired;

  ApiInterceptor({
    required TokenProvider tokenProvider,
    SessionExpiredCallback? onSessionExpired,
  })  : _tokenProvider = tokenProvider,
        _onSessionExpired = onSessionExpired;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1. Attach in-memory JWT if available
    final token = _tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 2. Safe request logging in debug mode (NO credentials, NO JWT logging)
    if (kDebugMode) {
      debugPrint('[API] -> ${options.method} ${options.path}');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[API] <- ${response.statusCode} ${response.requestOptions.path}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[API] !! Error ${err.response?.statusCode} ${err.requestOptions.path}');
    }

    // Trigger session expired callback on 401 (excluding the login endpoint itself)
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/api/auth/login')) {
      _onSessionExpired?.call();
    }

    handler.next(err);
  }
}
