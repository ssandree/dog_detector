// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../storage/app_prefs_provider.dart';
import 'api_endpoints.dart';

final apiDioProvider = Provider<Dio>((ref) {
  final prefs = ref.watch(appPrefsProvider);
  final token = prefs.value?.accessToken;

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.mainBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty)
          "Authorization": "Bearer $token",
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
    ),
  );

  return dio;
});

final inferenceDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.inferenceBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),

      headers: {
        "X-API-Key": "idontwantdoganymore",
        "Content-Type": "multipart/form-data",
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
    ),
  );

  return dio;
});
