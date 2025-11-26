import 'dart:io';
import 'package:dio/dio.dart';
import '../../models/event_info.dart';
import '../../exceptions.dart';
import '../../config/api_config.dart';
import 'event_service.dart';

/// Remote 이벤트 서비스 구현체
/// 실제 API 호출하는 구현체
class RemoteEventService implements EventService {
  final Dio _dio;

  RemoteEventService() : _dio = ApiConfig.createDio();

  @override
  Future<List<EventInfo>> getPetEvents({
    required int petId,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/pets/$petId/events',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => EventInfo.fromJson(json)).toList();
      } else {
        throw NetworkException('이벤트 목록을 불러오는데 실패했습니다');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, '이벤트 목록을 불러오는데 실패했습니다');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '이벤트 목록을 불러오는데 실패했습니다',
        e,
      );
    }
  }

  /// DioException을 AppException으로 변환
  AppException _handleDioError(DioException e, String defaultMessage) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException('서버 연결 시간이 초과되었습니다', e);
    } else if (e.type == DioExceptionType.connectionError) {
      return NetworkException('서버에 연결할 수 없습니다', e);
    } else if (e.response != null) {
      final statusCode = e.response!.statusCode;
      if (statusCode == 401) {
        return AuthException('인증이 필요합니다. 다시 로그인해주세요', e);
      } else if (statusCode == 404) {
        return NetworkException('요청한 리소스를 찾을 수 없습니다', e);
      } else if (statusCode == 422) {
        // Validation Error
        final detail = e.response?.data['detail'] as List?;
        final errorMessage = detail?.isNotEmpty == true
            ? detail![0]['msg'] as String? ?? '입력값을 확인해주세요'
            : '입력값을 확인해주세요';
        return ValidationException(errorMessage);
      } else if (statusCode! >= 500) {
        return NetworkException('서버 오류가 발생했습니다', e);
      }
    }
    return NetworkException(defaultMessage, e);
  }
}

