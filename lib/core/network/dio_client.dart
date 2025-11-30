// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

final apiDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = ref.read(secureStorageServiceProvider);
        final token = await storage.readToken();

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },

      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final storage = ref.read(secureStorageServiceProvider);
          await storage.deleteToken();
        }
        handler.next(error);
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      responseBody: true,
      requestBody: true,
      requestHeader: true,
    ),
  );

  return dio;
});

final inferenceDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: "http://dog-det.ddns.net:8000",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['X-API-Key'] = 'idontwantdoganymore';
        handler.next(options);
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      responseBody: true,
      requestBody: true,
      requestHeader: true,
    ),
  );

  return dio;
});

final dioProvider = apiDioProvider;
