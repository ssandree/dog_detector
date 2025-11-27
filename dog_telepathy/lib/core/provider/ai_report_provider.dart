import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../service/ai_report/mock_ai_report_service.dart';
import '../service/ai_report/remote_ai_report_service.dart';
import '../service/ai_report/report_ai_service.dart';

/// 하루 AI 리포트 요청 파라미터
class DailyReportRequest {
  final int petId;
  final DateTime date;

  const DailyReportRequest({
    required this.petId,
    required this.date,
  });

  DateTime get normalizedDate => DateTime(date.year, date.month, date.day);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyReportRequest &&
        other.petId == petId &&
        other.normalizedDate == normalizedDate;
  }

  @override
  int get hashCode => Object.hash(
        petId,
        normalizedDate.year,
        normalizedDate.month,
        normalizedDate.day,
      );
}

/// AI 리포트 응답 모델
class DailyAiReport {
  final int petId;
  final DateTime date;
  final String summary;

  const DailyAiReport({
    required this.petId,
    required this.date,
    required this.summary,
  });

  bool get hasSummary => summary.trim().isNotEmpty;
}

/// ReportService provider (환경에 따라 Mock/Remote 선택)
final aiReportServiceProvider =
    Provider.family<ReportService, int>((ref, petId) {
  const useMock = bool.fromEnvironment('USE_MOCK_AI_REPORT', defaultValue: false);
  return useMock
      ? MockReportService()
      : RemoteReportService(petId);
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

    return DailyAiReport(
      petId: request.petId,
      date: parsedDate ?? request.normalizedDate,
      summary: _extractSummary(raw),
    );
  } on NetworkException catch (e) {
    // 404 에러 (리포트가 없는 경우) - 빈 리포트 반환
    if (e.toString().contains('404') || e.toString().contains('찾을 수 없습니다')) {
      return DailyAiReport(
        petId: request.petId,
        date: request.normalizedDate,
        summary: '',
      );
    }
    rethrow;
  } catch (e) {
    // 기타 에러도 빈 리포트로 처리하여 무한 호출 방지
    return DailyAiReport(
      petId: request.petId,
      date: request.normalizedDate,
      summary: '',
    );
  }
});

