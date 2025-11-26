import 'package:dio/dio.dart';

/// API 설정 클래스
class ApiConfig {
  /// Dio 인스턴스 생성
  static Dio createDio() {
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

    dio.interceptors.add(LogInterceptor(
      responseBody: true,
      requestBody: true,
      requestHeader: true,
    ));

    return dio;
  }
}

