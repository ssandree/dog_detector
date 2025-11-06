final mockDailyReport = {
  'date': '2025-10-11',
  'events': [
    {'time': '09:10', 'type': '낑낑거림 감지', 'emotion': '불안', 'severity': 'MEDIUM'},
    {'time': '15:22', 'type': '하울링 감지', 'emotion': '공포', 'severity': 'HIGH'},
  ],
  'chartData': [
    {'hour': '00', 'activity': 3, 'barkCount': 0},
    {'hour': '12', 'activity': 8, 'barkCount': 2},
    {'hour': '18', 'activity': 10, 'barkCount': 4},
  ],
  'aiComment': '오늘은 낮 시간대에 불안 행동이 두 차례 감지되었어요. 오후 산책을 조금 줄여보세요 🐕',
};

/// 주 시작 날짜를 키로 하는 주간 리포트 데이터 맵
/// 날짜 형식: 'YYYY-MM-DD' (주 시작일, 월요일)
final Map<String, Map<String, dynamic>> mockWeeklyReports = {
  // 이번 주 (2025-10-06 ~ 2025-10-12)
  '2025-10-06': {
    'startDate': '2025-10-06',
    'endDate': '2025-10-12',
    'trend': '지난주보다 하울링 빈도가 12% 감소했습니다 🎉',
    'dailyStats': [
      {'date': '10-06', 'bark': 10, 'howl': 2},
      {'date': '10-07', 'bark': 8, 'howl': 1},
      {'date': '10-08', 'bark': 5, 'howl': 0},
      {'date': '10-09', 'bark': 3, 'howl': 1},
      {'date': '10-10', 'bark': 7, 'howl': 3},
    ],
    'emotionBreakdown': {
      '행복': 89,
      '편안': 67,
      '불안': 54,
      '화남': 45,
      '공포': 30,
      '공격성': 20,
    },
  },
  // 1주 전 (2025-09-29 ~ 2025-10-05)
  '2025-09-29': {
    'startDate': '2025-09-29',
    'endDate': '2025-10-05',
    'trend': '이번 주는 전반적으로 안정적인 패턴을 보였습니다.',
    'dailyStats': [
      {'date': '09-29', 'bark': 12, 'howl': 3},
      {'date': '09-30', 'bark': 9, 'howl': 2},
      {'date': '10-01', 'bark': 6, 'howl': 1},
      {'date': '10-02', 'bark': 4, 'howl': 0},
      {'date': '10-03', 'bark': 8, 'howl': 2},
    ],
    'emotionBreakdown': {
      '행복': 95,
      '편안': 72,
      '불안': 48,
      '화남': 38,
      '공포': 25,
      '공격성': 18,
    },
  },
  // 2주 전 (2025-09-22 ~ 2025-09-28)
  '2025-09-22': {
    'startDate': '2025-09-22',
    'endDate': '2025-09-28',
    'trend': '주말에 활동량이 증가했습니다.',
    'dailyStats': [
      {'date': '09-22', 'bark': 15, 'howl': 4},
      {'date': '09-23', 'bark': 11, 'howl': 3},
      {'date': '09-24', 'bark': 7, 'howl': 1},
      {'date': '09-25', 'bark': 5, 'howl': 2},
      {'date': '09-26', 'bark': 9, 'howl': 3},
    ],
    'emotionBreakdown': {
      '행복': 82,
      '편안': 65,
      '불안': 58,
      '화남': 42,
      '공포': 32,
      '공격성': 22,
    },
  },
  // 3주 전 (2025-09-15 ~ 2025-09-21)
  '2025-09-15': {
    'startDate': '2025-09-15',
    'endDate': '2025-09-21',
    'trend': '평일에는 안정적이었으나 주말에 긴장감이 있었습니다.',
    'dailyStats': [
      {'date': '09-15', 'bark': 13, 'howl': 2},
      {'date': '09-16', 'bark': 10, 'howl': 1},
      {'date': '09-17', 'bark': 6, 'howl': 0},
      {'date': '09-18', 'bark': 4, 'howl': 1},
      {'date': '09-19', 'bark': 8, 'howl': 2},
    ],
    'emotionBreakdown': {
      '행복': 88,
      '편안': 70,
      '불안': 52,
      '화남': 40,
      '공포': 28,
      '공격성': 19,
    },
  },
  // 4주 전 (2025-09-08 ~ 2025-09-14)
  '2025-09-08': {
    'startDate': '2025-09-08',
    'endDate': '2025-09-14',
    'trend': '전반적으로 긍정적인 감정이 우세했습니다.',
    'dailyStats': [
      {'date': '09-08', 'bark': 11, 'howl': 2},
      {'date': '09-09', 'bark': 9, 'howl': 1},
      {'date': '09-10', 'bark': 5, 'howl': 0},
      {'date': '09-11', 'bark': 3, 'howl': 1},
      {'date': '09-12', 'bark': 7, 'howl': 2},
    ],
    'emotionBreakdown': {
      '행복': 91,
      '편안': 68,
      '불안': 50,
      '화남': 43,
      '공포': 29,
      '공격성': 21,
    },
  },
  // 5주 전 (2025-09-01 ~ 2025-09-07)
  '2025-09-01': {
    'startDate': '2025-09-01',
    'endDate': '2025-09-07',
    'trend': '이번 주는 활동량이 많았습니다.',
    'dailyStats': [
      {'date': '09-01', 'bark': 14, 'howl': 3},
      {'date': '09-02', 'bark': 12, 'howl': 2},
      {'date': '09-03', 'bark': 8, 'howl': 1},
      {'date': '09-04', 'bark': 6, 'howl': 2},
      {'date': '09-05', 'bark': 10, 'howl': 3},
    ],
    'emotionBreakdown': {
      '행복': 85,
      '편안': 63,
      '불안': 56,
      '화남': 44,
      '공포': 31,
      '공격성': 23,
    },
  },
};

/// 기본 주간 리포트 (이번 주)
/// 하위 호환성을 위해 유지
final mockWeeklyReport = mockWeeklyReports['2025-10-06']!;

final mockMonthlyReport = {
  'year': 2025,
  'month': 10,
  'totalEvents': 342,
  'emotionBreakdown': {
    '행복': 342,
    '편안': 267,
    '불안': 198,
    '화남': 165,
    '공포': 120,
    '공격성': 85,
  },
  'trend': '이번 달은 전반적으로 안정적인 감정 상태를 유지했습니다.',
  'weeklyBreakdown': [
    {'week': 1, 'totalEvents': 85, 'positiveRatio': 0.52},
    {'week': 2, 'totalEvents': 92, 'positiveRatio': 0.48},
    {'week': 3, 'totalEvents': 88, 'positiveRatio': 0.45},
    {'week': 4, 'totalEvents': 77, 'positiveRatio': 0.51},
  ],
  // calendarData는 분리됨: data/calendar_data_mock.dart의 mockCalendarData를 사용
};