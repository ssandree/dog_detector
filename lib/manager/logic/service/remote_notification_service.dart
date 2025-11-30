import 'package:dio/dio.dart';

import '../../../core/config/api_config.dart';
import '../../../core/error/exceptions.dart';
import '../model/notification_models.dart';
import 'notification_service.dart';

class RemoteNotificationService implements NotificationService {
  RemoteNotificationService() : _dio = ApiConfig.createDio();

  final Dio _dio;

  @override
  Future<NotificationSettings> fetchSettings() async {
    try {
      final response = await _dio.get('/notifications/settings');
      return NotificationSettings.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
    } on DioException catch (e) {
      throw _handleError(e, '알림 설정을 불러오는데 실패했습니다');
    }
  }

  @override
  Future<NotificationSettings> updateSettings(NotificationSettings settings) async {
    try {
      final response = await _dio.put(
        '/notifications/settings',
        data: settings.toJson(),
      );
      return NotificationSettings.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
    } on DioException catch (e) {
      throw _handleError(e, '알림 설정을 저장하지 못했습니다');
    }
  }

  @override
  Future<void> registerFcmToken(String token) async {
    try {
      await _dio.put(
        '/users/fcm-token',
        data: {'token': token},
      );
    } on DioException catch (e) {
      throw _handleError(e, 'FCM 토큰 등록에 실패했습니다');
    }
  }

  @override
  Future<List<NotificationMessage>> fetchMessages() async {
    try {
      final response = await _dio.get('/notifications/messages');
      final data = response.data as List<dynamic>? ?? const [];
      return data
          .map((item) =>
              NotificationMessage.fromJson(item as Map<String, dynamic>? ?? const {}))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, '알림 목록을 불러오지 못했습니다');
    }
  }

  @override
  Future<void> toggleNotification(bool enabled) async {
    try {
      await _dio.put(
        '/users/notification',
        data: {'enabled': enabled},
      );
    } on DioException catch (e) {
      throw _handleError(e, '알림 설정을 변경하지 못했습니다');
    }
  }

  AppException _handleError(DioException e, String defaultMessage) {
    if (e.response != null) {
      final status = e.response!.statusCode ?? 0;
      if (status == 401) return AuthException('인증이 만료되었습니다', e);
      if (status == 404) return NetworkException('리소스를 찾지 못했습니다', e);
      if (status == 422) return ValidationException('입력값을 확인해주세요', e);
      if (status >= 500) return NetworkException('서버 오류가 발생했습니다', e);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException('서버 응답이 지연되고 있습니다', e);
    }
    if (e.type == DioExceptionType.connectionError) {
      return NetworkException('네트워크 연결에 실패했습니다', e);
    }
    return NetworkException(defaultMessage, e);
  }
}
