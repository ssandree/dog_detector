// lib/manager/logic/provider/ai_report_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../model/ai_report_info.dart';
import '../service/remote_ai_report_service.dart';
import '../service/report_ai_service.dart';

// 모델들을 re-export하여 다른 파일에서도 ai_report_provider를 통해 접근 가능하도록
export '../model/ai_report_info.dart';

/// ReportService provider
final aiReportServiceProvider =
    Provider.family<ReportService, int>((ref, petId) {
  final dio = ref.watch(apiDioProvider);
  return RemoteReportService(petId, dio);
});

/// 날짜별 AI 리포트 Provider
final dailyAiReportProvider =
    FutureProvider.autoDispose.family<DailyAiReport, DailyReportRequest>(
        (ref, request) async {
  try {
    final service = ref.watch(aiReportServiceProvider(request.petId));
    final raw = await service.getDailyReport(request.date);

    final dateValue = raw['date'];
    final parsedDate =
        dateValue is String ? DateTime.tryParse(dateValue) : null;

    String _extractSummary(Map<String, dynamic> json) {
      final summary = json['summary'];
      if (summary is String && summary.isNotEmpty) return summary;
      final summaryText = json['summary_text'];
      if (summaryText is String && summaryText.isNotEmpty) return summaryText;
      return '';
    }

    DateTime? _extractCreatedAt(Map<String, dynamic> json) {
      final createdAt = json['created_at'];
      if (createdAt is String) {
        return DateTime.tryParse(createdAt);
      }
      return null;
    }

    return DailyAiReport(
      petId: request.petId,
      date: parsedDate ?? request.normalizedDate,
      summary: _extractSummary(raw),
      createdAt: _extractCreatedAt(raw),
    );
  } on NetworkException catch (e) {
    // 404 에러 (리포트가 없는 경우) - 빈 리포트 반환
    if (e.toString().contains('404') || e.toString().contains('찾을 수 없습니다')) {
      return DailyAiReport(
        petId: request.petId,
        date: request.normalizedDate,
        summary: '',
        createdAt: null,
      );
    }
    rethrow;
  } catch (e) {
    // 기타 에러도 빈 리포트로 처리하여 무한 호출 방지
    return DailyAiReport(
      petId: request.petId,
      date: request.normalizedDate,
      summary: '',
      createdAt: null,
    );
  }
});

/// 월간 AI 리포트 Provider
final monthlyAiReportProvider =
    FutureProvider.autoDispose.family<MonthlyAiReport?, MonthlyReportRequest>(
        (ref, request) async {
  try {
    final service = ref.watch(aiReportServiceProvider(request.petId));
    final rawList = await service.getMonthlyReport(request.year, request.month);

    if (rawList.isEmpty) {
      return null;
    }

    // 첫 번째 리포트를 사용 (보통 월간 리포트는 하나만 반환됨)
    final raw = rawList[0];

    String _extractSummary(Map<String, dynamic> json) {
      final summary = json['summary_text'];
      if (summary is String && summary.isNotEmpty) {
        return summary;
      }
      return '';
    }

    DateTime? _extractCreatedAt(Map<String, dynamic> json) {
      final createdAt = json['created_at'];
      if (createdAt is String) {
        return DateTime.tryParse(createdAt);
      }
      return null;
    }

    final reportMonth = raw['report_month'] as String? ?? 
        (request.year != null && request.month != null
            ? "${request.year}-${request.month.toString().padLeft(2, '0')}"
            : '');
    final reportId = raw['report_id'] as int? ?? 0;

    return MonthlyAiReport(
      petId: request.petId,
      reportMonth: reportMonth,
      summary: _extractSummary(raw),
      reportId: reportId,
      createdAt: _extractCreatedAt(raw),
    );
  } on NetworkException catch (e) {
    // 404 에러 (리포트가 없는 경우) - null 반환
    if (e.toString().contains('404') || e.toString().contains('찾을 수 없습니다')) {
      return null;
    }
    rethrow;
  } catch (e, _) {
    // 기타 에러도 null로 처리
    return null;
  }
});

/// 위클리 AI 리포트 Provider
final weeklyAiReportProvider =
    FutureProvider.autoDispose.family<WeeklyAiReport?, WeeklyReportRequest>(
        (ref, request) async {
  try {
    final service = ref.watch(aiReportServiceProvider(request.petId));
    final rawList = await service.getWeeklyReport(request.year, request.month, request.week);

    if (rawList.isEmpty) {
      return null;
    }

    // 첫 번째 리포트를 사용 (보통 위클리 리포트는 하나만 반환됨)
    final raw = rawList[0];

    String _extractSummary(Map<String, dynamic> json) {
      final summary = json['summary_text'];
      if (summary is String && summary.isNotEmpty) return summary;
      return '';
    }

    DateTime? _extractCreatedAt(Map<String, dynamic> json) {
      final createdAt = json['created_at'];
      if (createdAt is String) {
        return DateTime.tryParse(createdAt);
      }
      return null;
    }

    DateTime? _parseDate(String? dateStr) {
      if (dateStr == null) return null;
      return DateTime.tryParse(dateStr);
    }

    final startDateStr = raw['start_date'] as String?;
    final endDateStr = raw['end_date'] as String?;
    final startDate = _parseDate(startDateStr);
    final endDate = _parseDate(endDateStr);
    final reportId = raw['report_id'] as int? ?? 0;

    // startDate나 endDate가 없으면 에러
    if (startDate == null || endDate == null) {
      return null;
    }

    return WeeklyAiReport(
      petId: request.petId,
      startDate: startDate,
      endDate: endDate,
      summary: _extractSummary(raw),
      reportId: reportId,
      createdAt: _extractCreatedAt(raw),
    );
  } on NetworkException catch (e) {
    // 404 에러 (리포트가 없는 경우) - null 반환
    if (e.toString().contains('404') || e.toString().contains('찾을 수 없습니다')) {
      return null;
    }
    rethrow;
  } catch (e) {
    // 기타 에러도 null로 처리
    return null;
  }
});

