// lib/core/network/api_interceptor.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

typedef TokenProvider = String? Function();

/// Security-conscious Dio interceptor:
/// 1. Attaches in-memory Bearer token to every request
/// 2. Never logs token, Authorization header, passwords, or sensitive response bodies
/// 3. Safe endpoint method/path logging only in debug mode
class ApiInterceptor extends Interceptor {
  final TokenProvider _tokenProvider;

  ApiInterceptor({
    required TokenProvider tokenProvider,
  }) : _tokenProvider = tokenProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Do not send Authorization header on /api/auth/login
    if (options.path.contains('/api/auth/login')) {
      if (kDebugMode) {
        debugPrint('[API] -> ${options.method} ${options.path}');
      }
      return handler.next(options);
    }

    // Attach in-memory JWT if available — never persisted to disk
    final token = _tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Safe request logging: method + path only. NO token, NO Authorization header, NO body.
    if (kDebugMode) {
      debugPrint('[API] -> ${options.method} ${options.path}');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Safe response logging: status code + path only. NO response body.
    if (kDebugMode) {
      debugPrint('[API] <- ${response.statusCode} ${response.requestOptions.path}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Safe error logging: status code + path only. NO request/response bodies.
    if (kDebugMode) {
      debugPrint('[API] !! Error ${err.response?.statusCode} ${err.requestOptions.path}');
    }
    handler.next(err);
  }
}
