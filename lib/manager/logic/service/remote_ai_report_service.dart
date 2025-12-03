import 'package:dio/dio.dart';
import '../../../core/error/exceptions.dart';
import 'report_ai_service.dart';

class RemoteReportService implements ReportService {
  final Dio _dio;
  final int petId;

  RemoteReportService(this.petId, this._dio);

  @override
  Future<Map<String, dynamic>> getDailyReport(DateTime date) async {
    try {
      final dateStr = _format(date);

      // API 명세에 따르면 POST /reports/generate만 호출하면 됩니다.
      // 서버가 내부적으로 기존 리포트 존재 여부를 확인하고,
      // 존재하면 기존 리포트를 반환하고, 없으면 새로 생성합니다.
      final response = await _dio.post(
        '/reports/generate',
        queryParameters: {
          'pet_id': petId,
          'target_date': dateStr,
        },
      );

      if (response.statusCode == 200) {
        return _convert(response.data as Map<String, dynamic>);
      } else {
        throw NetworkException('리포트를 불러오는데 실패했습니다');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, "리포트를 불러오는데 실패했습니다");
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        "리포트를 불러오는데 실패했습니다",
        e,
      );
    }
  }

  String _format(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Map<String, dynamic> _convert(Map<String, dynamic> json) {
    return {
      "date": json["report_date"],
      "summary": json["summary_text"],
    };
  }

  AppException _handleDioError(DioException e, String defaultMessage) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException("서버 응답이 없습니다", e);
    }
    if (e.type == DioExceptionType.connectionError) {
      return NetworkException("서버에 연결할 수 없습니다", e);
    }
    if (e.response != null) {
      final code = e.response!.statusCode;
      if (code == 401) {
        return AuthException("인증이 필요합니다. 다시 로그인해주세요", e);
      }
      if (code == 404) {
        // 리포트가 없는 경우를 명확히 구분하기 위해 특별한 예외 사용
        final detail = e.response?.data['detail'] as String?;
        final message = detail ?? "리포트를 찾을 수 없습니다";
        return NetworkException(message, e);
      }
      if (code == 422) {
        // Validation Error
        final detail = e.response?.data['detail'] as List?;
        final errorMessage = detail?.isNotEmpty == true
            ? detail![0]['msg'] as String? ?? '입력값을 확인해주세요'
            : '입력값을 확인해주세요';
        return ValidationException(errorMessage);
      }
      if (code != null && code >= 500) {
        return NetworkException("서버 오류가 발생했습니다", e);
      }
    }
    return NetworkException(defaultMessage, e);
  }
}
