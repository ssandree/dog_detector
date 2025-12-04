// lib/manager/logic/service/remote_ai_report_service.dart
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

      // GET /reports/daily/{pet_id}?target_date={date}
      final response = await _dio.get(
        '/reports/daily/$petId',
        queryParameters: {
          'target_date': dateStr,
        },
      );

      if (response.statusCode == 200) {
        // 응답이 배열 형태이므로 첫 번째 요소를 가져옴
        final data = response.data;
        if (data is List && data.isNotEmpty) {
          return _convert(data[0] as Map<String, dynamic>);
        } else if (data is Map<String, dynamic>) {
          // 단일 객체로 반환되는 경우도 처리
          return _convert(data);
        } else {
          // 빈 배열인 경우 - 리포트가 없음
          throw NetworkException("리포트를 찾을 수 없습니다");
        }
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

  @override
  Future<List<Map<String, dynamic>>> getMonthlyReport(int? year, int? month) async {
    try {
      // GET /reports/monthly/{pet_id}?year={year}&month={month}
      final queryParams = <String, dynamic>{};
      if (year != null) {
        queryParams['year'] = year;
      }
      if (month != null) {
        queryParams['month'] = month;
      }

      final response = await _dio.get(
        '/reports/monthly/$petId',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .map((item) => item as Map<String, dynamic>)
              .toList();
        } else {
          return [];
        }
      } else {
        throw NetworkException('월간 리포트를 불러오는데 실패했습니다');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, "월간 리포트를 불러오는데 실패했습니다");
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        "월간 리포트를 불러오는데 실패했습니다",
        e,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWeeklyReport(int? year, int? month, int? week) async {
    try {
      // GET /reports/weekly/{pet_id}?year={year}&month={month}&week={week}
      final queryParams = <String, dynamic>{};
      if (year != null) {
        queryParams['year'] = year;
      }
      if (month != null) {
        queryParams['month'] = month;
      }
      if (week != null) {
        queryParams['week'] = week;
      }

      final response = await _dio.get(
        '/reports/weekly/$petId',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .map((item) => item as Map<String, dynamic>)
              .toList();
        } else {
          return [];
        }
      } else {
        throw NetworkException('위클리 리포트를 불러오는데 실패했습니다');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, "위클리 리포트를 불러오는데 실패했습니다");
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        "위클리 리포트를 불러오는데 실패했습니다",
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
      "summary_text": json["summary_text"], // provider에서 사용
      "created_at": json["created_at"], // provider에서 사용
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
