import '../../../../core/data/report_mock.dart';

/// 캘린더 데이터 계산 유틸리티 클래스
/// 날짜별 감정 비율 및 상태를 계산하는 로직을 담당
class CalendarDataCalculator {
  CalendarDataCalculator._(); // private 생성자로 인스턴스화 방지

  // ========== 상수 ==========
  /// 부정 감정 리스트
  static const List<String> _negativeEmotions = [
    '불안',
    '화남',
    '공포',
    '공격성',
  ];
  
  /// 심각도별 가중치
  static const Map<String, double> _severityWeights = {
    'LOW': 0.3,
    'MEDIUM': 0.6,
    'HIGH': 1.0,
  };

  /// 하루 이벤트 데이터 기반 부정 감정 비율 계산
  /// 
  /// [events]: 이벤트 리스트 (각 이벤트는 'emotion', 'severity' 키를 가진 Map)
  /// 반환값: 0.0 ~ 1.0 사이의 부정 감정 비율
  static double _calculateNegativeRatio(List<dynamic> events) {
    if (events.isEmpty) return 0.0;

    double total = 0;
    double negativeScore = 0;

    for (final e in events) {
      final severity = e['severity'] ?? 'MEDIUM';
      final weight = _severityWeights[severity] ?? 0.6;
      total += 1;
      if (_negativeEmotions.contains(e['emotion'])) {
        negativeScore += weight;
      }
    }

    // 0~1 사이 비율로 반환
    return (negativeScore / total).clamp(0.0, 1.0);
  }

  /// 현재 월의 모든 날짜에 대해 감정 비율 및 상태를 계산
  /// 
  /// [focusedDay]: 현재 포커스된 날짜 (월 기준)
  /// [mockDailyReports]: 일일 리포트 데이터 맵
  /// 
  /// 반환값: 날짜별 감정 비율 맵 (키: 'MM-dd' 형식, 값: 비율 또는 -1.0(탐지 결과 없음))
  static Map<String, double> calculateEmotionRatios({
    required DateTime focusedDay,
    required Map<String, dynamic> mockDailyReports,
  }) {
    final weeklyRatios = <String, double>{};
    
    // 현재 월의 모든 날짜에 대해 비율 계산
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    final endDate = today.isBefore(lastDayOfMonth) ? today : lastDayOfMonth;
    
    // 각 날짜에 대해 mockDailyReports에서 데이터 가져와서 비율 계산
    for (var date = firstDayOfMonth; 
        date.isBefore(endDate.add(const Duration(days: 1))); 
        date = date.add(const Duration(days: 1))) {
      final dateKey = '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final fullDateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // mockDailyReports에서 해당 날짜의 데이터 찾기
      if (mockDailyReports.containsKey(fullDateKey)) {
        final reportData = mockDailyReports[fullDateKey]!;
        
        // '탐지 결과 없음' 상태 확인
        final detectionStatus = reportData['detectionStatus'] as String?;
        if (detectionStatus == '탐지 결과 없음') {
          weeklyRatios[dateKey] = -1.0; // 특수 값으로 표시 (연한 회색으로 표시됨)
        } else {
          final events = reportData['events'] as List<dynamic>? ?? [];
          final ratio = _calculateNegativeRatio(events);
          weeklyRatios[dateKey] = ratio;
        }
      } else {
        // 데이터가 없으면 기본 비율 (0.3)
        weeklyRatios[dateKey] = 0.3;
      }
    }
    
    return weeklyRatios;
  }
}

