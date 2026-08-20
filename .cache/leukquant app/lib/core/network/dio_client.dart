// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';

/// Central Dio instance with the base API URL.
final dio = Dio(
  BaseOptions(
    baseUrl: 'https://apix.leukquant.com',
    connectTimeout: Duration(seconds: 8),
    receiveTimeout: Duration(seconds: 8),
    // Additional default headers can be added here if needed.
  ),
);
