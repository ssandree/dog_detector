import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import '../../exceptions.dart';
import '../../models/user_profile.dart';
import 'user_service.dart';

class RemoteUserService implements UserService {
  RemoteUserService() : _dio = ApiConfig.createDio();

  final Dio _dio;

  @override
  Future<UserProfile> fetchCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      return UserProfile.fromJson(
        (response.data as Map<String, dynamic>?) ?? const {},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException e) {
    if (e.response != null) {
      final status = e.response!.statusCode ?? 0;
      if (status == 401) {
        return AuthException('인증이 필요합니다', e);
      }
      if (status == 404) {
        return NetworkException('사용자 정보를 찾을 수 없습니다', e);
      }
      if (status >= 500) {
        return NetworkException('서버 오류가 발생했습니다', e);
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException('서버 응답이 지연되고 있습니다', e);
    }

    if (e.type == DioExceptionType.connectionError) {
      return NetworkException('네트워크 연결에 실패했습니다', e);
    }

    return NetworkException('사용자 정보를 불러오지 못했습니다', e);
  }
}

