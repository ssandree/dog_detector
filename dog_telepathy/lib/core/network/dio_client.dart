// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../storage/secure_storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://54.206.79.248:8000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // 인증 토큰 자동 추가 인터셉터
  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final storage = SecureStorageService();
          final token = await storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          // 토큰 읽기 실패 시 무시하고 계속 진행
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // 401 에러 시 토큰 삭제
        if (error.response?.statusCode == 401) {
          try {
            final storage = SecureStorageService();
            await storage.deleteToken();
          } catch (e) {
            // 토큰 삭제 실패 시 무시
          }
        }
        handler.next(error);
      },
    ),
  );

  dio.interceptors.add(LogInterceptor(
    responseBody: true,
    requestBody: true,
    requestHeader: true,
  ));

  return dio;
});
