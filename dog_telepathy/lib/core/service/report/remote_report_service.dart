import 'package:dio/dio.dart';
import '../../exceptions.dart';
import '../../config/api_config.dart';
import 'report_service.dart';

class RemoteReportService implements ReportService {
  final Dio _dio;
  final int petId;

  RemoteReportService(this.petId) : _dio = ApiConfig.createDio();

  @override
  Future<Map<String, dynamic>> getDailyReport(DateTime date) async {
    try {
      final dateStr = _format(date);

      // 1) 기존 생성된 리포트 조회
      final response = await _dio.get('/reports/$petId');
      final List<dynamic> list = response.data;

      final existing = list.firstWhere(
        (r) => r['report_date'] == dateStr,
        orElse: () => null,
      );

      if (existing != null) {
        return _convert(existing);
      }

      // 2) 없으면 생성 API 호출
      final created = await _dio.post(
        '/reports/generate',
        queryParameters: {
          'pet_id': petId,
          'target_date': dateStr,
        },
      );

      return _convert(created.data);

    } on DioException catch (e) {
      throw _handleDioError(e, "리포트를 불러오는데 실패했습니다");
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
      if (code == 401) return AuthException("인증이 필요합니다", e);
      if (code == 404) return NetworkException("리포트를 찾을 수 없습니다", e);
      if (code != null && code >= 500) {
        return NetworkException("서버 오류가 발생했습니다", e);
      }
    }
    return NetworkException(defaultMessage, e);
  }
}
