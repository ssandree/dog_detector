/// 날짜별 일일 리포트 데이터 맵
/// 날짜 형식: 'YYYY-MM-DD'
final Map<String, Map<String, dynamic>> mockDailyReports = {
  // 오늘 (다양한 감정, 긍정적)
  _formatDate(DateTime.now()): {
    'date': _formatDate(DateTime.now()),
    'events': [
      {'time': '08:30', 'type': '꼬리 흔들기', 'emotion': '행복', 'severity': 'HIGH'},
      {'time': '10:15', 'type': '안정적인 호흡', 'emotion': '편안', 'severity': 'LOW'},
      {'time': '14:20', 'type': '낑낑거림 감지', 'emotion': '불안', 'severity': 'MEDIUM'},
      {'time': '16:45', 'type': '놀이 활동', 'emotion': '행복', 'severity': 'HIGH'},
      {'time': '19:00', 'type': '휴식', 'emotion': '편안', 'severity': 'LOW'},
    ],
    'chartData': [
      {'hour': '08', 'activity': 5, 'barkCount': 0},
      {'hour': '10', 'activity': 3, 'barkCount': 0},
      {'hour': '14', 'activity': 7, 'barkCount': 1},
      {'hour': '16', 'activity': 9, 'barkCount': 0},
      {'hour': '19', 'activity': 2, 'barkCount': 0},
    ],
    'aiComment': '오늘은 전반적으로 긍정적인 감정이 우세했어요. 행복한 활동이 많았습니다! 🐕',
  },
  
  // 어제 (부정적 감정 다수)
  _formatDate(DateTime.now().subtract(const Duration(days: 1))): {
    'date': _formatDate(DateTime.now().subtract(const Duration(days: 1))),
    'events': [
      {'time': '09:10', 'type': '낑낑거림 감지', 'emotion': '불안', 'severity': 'MEDIUM'},
      {'time': '11:30', 'type': '짖음 감지', 'emotion': '화남', 'severity': 'HIGH'},
      {'time': '15:22', 'type': '하울링 감지', 'emotion': '공포', 'severity': 'HIGH'},
      {'time': '17:45', 'type': '공격적 행동', 'emotion': '공격성', 'severity': 'HIGH'},
      {'time': '20:00', 'type': '불안 행동', 'emotion': '불안', 'severity': 'MEDIUM'},
    ],
    'chartData': [
      {'hour': '09', 'activity': 8, 'barkCount': 2},
      {'hour': '11', 'activity': 12, 'barkCount': 5},
      {'hour': '15', 'activity': 15, 'barkCount': 8},
      {'hour': '17', 'activity': 18, 'barkCount': 10},
      {'hour': '20', 'activity': 10, 'barkCount': 3},
    ],
    'aiComment': '어제는 부정적인 감정이 많이 감지되었어요. 스트레스 요인을 확인해보세요 🐕',
  },
  
  // 그저께 (탐지 결과 없음)
  _formatDate(DateTime.now().subtract(const Duration(days: 2))): {
    'date': _formatDate(DateTime.now().subtract(const Duration(days: 2))),
    'detectionStatus': '탐지 결과 없음',
    'events': [],
    'chartData': [],
    'aiComment': '탐지된 행동이 없었습니다.',
  },
  
  // 2일 전 (혼합) - 그저께를 탐지 결과 없음으로 변경했으므로 이전 데이터를 2일 전으로 이동
  _formatDate(DateTime.now().subtract(const Duration(days: 3))): {
    'date': _formatDate(DateTime.now().subtract(const Duration(days: 3))),
    'events': [
      {'time': '07:20', 'type': '산책 전 기대', 'emotion': '행복', 'severity': 'MEDIUM'},
      {'time': '10:00', 'type': '낑낑거림', 'emotion': '불안', 'severity': 'LOW'},
      {'time': '13:15', 'type': '편안한 휴식', 'emotion': '편안', 'severity': 'LOW'},
      {'time': '16:30', 'type': '짖음', 'emotion': '화남', 'severity': 'MEDIUM'},
      {'time': '18:45', 'type': '놀이', 'emotion': '행복', 'severity': 'MEDIUM'},
    ],
    'chartData': [
      {'hour': '07', 'activity': 6, 'barkCount': 0},
      {'hour': '10', 'activity': 4, 'barkCount': 1},
      {'hour': '13', 'activity': 2, 'barkCount': 0},
      {'hour': '16', 'activity': 8, 'barkCount': 2},
      {'hour': '18', 'activity': 7, 'barkCount': 0},
    ],
    'aiComment': '감정이 다양하게 나타났어요. 전반적으로 안정적인 하루였습니다 🐕',
  },
  
  // 4일 전 (매우 긍정적) - 날짜 조정
  _formatDate(DateTime.now().subtract(const Duration(days: 4))): {
    'date': _formatDate(DateTime.now().subtract(const Duration(days: 4))),
    'events': [
      {'time': '08:00', 'type': '활발한 놀이', 'emotion': '행복', 'severity': 'HIGH'},
      {'time': '10:30', 'type': '안정적인 상태', 'emotion': '편안', 'severity': 'LOW'},
      {'time': '12:00', 'type': '식사 후 만족', 'emotion': '행복', 'severity': 'MEDIUM'},
      {'time': '15:00', 'type': '산책 즐거움', 'emotion': '행복', 'severity': 'HIGH'},
      {'time': '17:30', 'type': '편안한 휴식', 'emotion': '편안', 'severity': 'LOW'},
      {'time': '19:00', 'type': '놀이 활동', 'emotion': '행복', 'severity': 'MEDIUM'},
    ],
    'chartData': [
      {'hour': '08', 'activity': 8, 'barkCount': 0},
      {'hour': '10', 'activity': 3, 'barkCount': 0},
      {'hour': '12', 'activity': 5, 'barkCount': 0},
      {'hour': '15', 'activity': 9, 'barkCount': 0},
      {'hour': '17', 'activity': 2, 'barkCount': 0},
      {'hour': '19', 'activity': 6, 'barkCount': 0},
    ],
    'aiComment': '3일 전은 매우 긍정적인 하루였어요! 행복한 활동이 많았습니다 🎉',
  },
  
  // 5일 전 (매우 부정적) - 날짜 조정
  _formatDate(DateTime.now().subtract(const Duration(days: 5))): {
    'date': _formatDate(DateTime.now().subtract(const Duration(days: 5))),
    'events': [
      {'time': '09:00', 'type': '하울링', 'emotion': '공포', 'severity': 'HIGH'},
      {'time': '11:20', 'type': '공격적 행동', 'emotion': '공격성', 'severity': 'HIGH'},
      {'time': '13:45', 'type': '짖음', 'emotion': '화남', 'severity': 'HIGH'},
      {'time': '15:30', 'type': '불안 행동', 'emotion': '불안', 'severity': 'HIGH'},
      {'time': '18:00', 'type': '하울링', 'emotion': '공포', 'severity': 'MEDIUM'},
      {'time': '20:15', 'type': '공격성', 'emotion': '공격성', 'severity': 'HIGH'},
    ],
    'chartData': [
      {'hour': '09', 'activity': 15, 'barkCount': 8},
      {'hour': '11', 'activity': 20, 'barkCount': 12},
      {'hour': '13', 'activity': 18, 'barkCount': 10},
      {'hour': '15', 'activity': 22, 'barkCount': 15},
      {'hour': '18', 'activity': 16, 'barkCount': 9},
      {'hour': '20', 'activity': 19, 'barkCount': 11},
    ],
    'aiComment': '5일 전은 부정적인 감정이 많이 감지되었어요. 전문가 상담을 권장합니다 🐕',
  },
  
  // 6일 전 (중간)
  _formatDate(DateTime.now().subtract(const Duration(days: 6))): {
    'date': _formatDate(DateTime.now().subtract(const Duration(days: 6))),
    'events': [
      {'time': '08:15', 'type': '기대감', 'emotion': '행복', 'severity': 'MEDIUM'},
      {'time': '10:00', 'type': '낑낑거림', 'emotion': '불안', 'severity': 'LOW'},
      {'time': '12:30', 'type': '편안함', 'emotion': '편안', 'severity': 'LOW'},
      {'time': '14:00', 'type': '짖음', 'emotion': '화남', 'severity': 'LOW'},
      {'time': '16:45', 'type': '놀이', 'emotion': '행복', 'severity': 'MEDIUM'},
    ],
    'chartData': [
      {'hour': '08', 'activity': 5, 'barkCount': 0},
      {'hour': '10', 'activity': 3, 'barkCount': 1},
      {'hour': '12', 'activity': 2, 'barkCount': 0},
      {'hour': '14', 'activity': 4, 'barkCount': 1},
      {'hour': '16', 'activity': 6, 'barkCount': 0},
    ],
    'aiComment': '6일 전은 전반적으로 안정적인 하루였어요 🐕',
  },
  
  // 추가 날짜들 (다양한 패턴)
  ..._generateAdditionalDates(),
};

/// 날짜를 'YYYY-MM-DD' 형식으로 변환하는 헬퍼 함수
String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// 추가 날짜 데이터 생성 (6일 전부터 30일 전까지)
Map<String, Map<String, dynamic>> _generateAdditionalDates() {
  final Map<String, Map<String, dynamic>> additionalDates = {};
  
  // 다양한 감정 패턴 정의
  final patterns = [
    // 패턴 1: 매우 긍정적 (행복 위주)
    {
      'events': [
        {'time': '07:00', 'type': '아침 산책', 'emotion': '행복', 'severity': 'HIGH'},
        {'time': '09:30', 'type': '식사 만족', 'emotion': '행복', 'severity': 'MEDIUM'},
        {'time': '12:00', 'type': '편안한 휴식', 'emotion': '편안', 'severity': 'LOW'},
        {'time': '15:00', 'type': '놀이 활동', 'emotion': '행복', 'severity': 'HIGH'},
        {'time': '18:00', 'type': '저녁 산책', 'emotion': '행복', 'severity': 'MEDIUM'},
      ],
      'chartData': [
        {'hour': '07', 'activity': 7, 'barkCount': 0},
        {'hour': '09', 'activity': 4, 'barkCount': 0},
        {'hour': '12', 'activity': 2, 'barkCount': 0},
        {'hour': '15', 'activity': 8, 'barkCount': 0},
        {'hour': '18', 'activity': 6, 'barkCount': 0},
      ],
      'aiComment': '매우 긍정적인 하루였어요! 행복한 활동이 많았습니다 🎉',
    },
    // 패턴 2: 부정적 (공포, 공격성 위주)
    {
      'events': [
        {'time': '08:00', 'type': '하울링', 'emotion': '공포', 'severity': 'HIGH'},
        {'time': '10:30', 'type': '공격적 행동', 'emotion': '공격성', 'severity': 'HIGH'},
        {'time': '13:00', 'type': '불안 행동', 'emotion': '불안', 'severity': 'HIGH'},
        {'time': '16:00', 'type': '짖음', 'emotion': '화남', 'severity': 'HIGH'},
        {'time': '19:30', 'type': '하울링', 'emotion': '공포', 'severity': 'MEDIUM'},
      ],
      'chartData': [
        {'hour': '08', 'activity': 14, 'barkCount': 7},
        {'hour': '10', 'activity': 19, 'barkCount': 11},
        {'hour': '13', 'activity': 17, 'barkCount': 9},
        {'hour': '16', 'activity': 21, 'barkCount': 13},
        {'hour': '19', 'activity': 15, 'barkCount': 8},
      ],
      'aiComment': '부정적인 감정이 많이 감지되었어요. 전문가 상담을 권장합니다 🐕',
    },
    // 패턴 3: 혼합 (행복, 불안, 편안)
    {
      'events': [
        {'time': '08:30', 'type': '기대감', 'emotion': '행복', 'severity': 'MEDIUM'},
        {'time': '11:00', 'type': '낑낑거림', 'emotion': '불안', 'severity': 'LOW'},
        {'time': '13:30', 'type': '편안함', 'emotion': '편안', 'severity': 'LOW'},
        {'time': '15:30', 'type': '놀이', 'emotion': '행복', 'severity': 'MEDIUM'},
        {'time': '17:00', 'type': '불안', 'emotion': '불안', 'severity': 'MEDIUM'},
      ],
      'chartData': [
        {'hour': '08', 'activity': 6, 'barkCount': 0},
        {'hour': '11', 'activity': 4, 'barkCount': 1},
        {'hour': '13', 'activity': 3, 'barkCount': 0},
        {'hour': '15', 'activity': 7, 'barkCount': 0},
        {'hour': '17', 'activity': 5, 'barkCount': 1},
      ],
      'aiComment': '감정이 다양하게 나타났어요. 전반적으로 안정적인 하루였습니다 🐕',
    },
    // 패턴 4: 화남 위주
    {
      'events': [
        {'time': '09:00', 'type': '짖음', 'emotion': '화남', 'severity': 'HIGH'},
        {'time': '11:30', 'type': '공격적 행동', 'emotion': '공격성', 'severity': 'MEDIUM'},
        {'time': '14:00', 'type': '짖음', 'emotion': '화남', 'severity': 'HIGH'},
        {'time': '16:30', 'type': '불안', 'emotion': '불안', 'severity': 'MEDIUM'},
        {'time': '19:00', 'type': '짖음', 'emotion': '화남', 'severity': 'MEDIUM'},
      ],
      'chartData': [
        {'hour': '09', 'activity': 11, 'barkCount': 6},
        {'hour': '11', 'activity': 9, 'barkCount': 4},
        {'hour': '14', 'activity': 13, 'barkCount': 7},
        {'hour': '16', 'activity': 8, 'barkCount': 3},
        {'hour': '19', 'activity': 10, 'barkCount': 5},
      ],
      'aiComment': '화남과 공격성이 많이 감지되었어요. 스트레스 요인을 확인해보세요 🐕',
    },
    // 패턴 5: 편안 위주
    {
      'events': [
        {'time': '08:00', 'type': '편안한 아침', 'emotion': '편안', 'severity': 'LOW'},
        {'time': '10:00', 'type': '안정적', 'emotion': '편안', 'severity': 'LOW'},
        {'time': '13:00', 'type': '휴식', 'emotion': '편안', 'severity': 'LOW'},
        {'time': '15:00', 'type': '행복한 순간', 'emotion': '행복', 'severity': 'MEDIUM'},
        {'time': '18:00', 'type': '편안한 저녁', 'emotion': '편안', 'severity': 'LOW'},
      ],
      'chartData': [
        {'hour': '08', 'activity': 3, 'barkCount': 0},
        {'hour': '10', 'activity': 2, 'barkCount': 0},
        {'hour': '13', 'activity': 1, 'barkCount': 0},
        {'hour': '15', 'activity': 5, 'barkCount': 0},
        {'hour': '18', 'activity': 2, 'barkCount': 0},
      ],
      'aiComment': '매우 편안하고 안정적인 하루였어요 😊',
    },
  ];
  
  // 7일 전부터 30일 전까지 패턴을 순환하며 데이터 생성
  for (int i = 7; i <= 30; i++) {
    final date = DateTime.now().subtract(Duration(days: i));
    final dateKey = _formatDate(date);
    final patternIndex = (i - 7) % patterns.length;
    final pattern = patterns[patternIndex];
    
    additionalDates[dateKey] = {
      'date': dateKey,
      'events': List<Map<String, dynamic>>.from(pattern['events'] as List),
      'chartData': List<Map<String, dynamic>>.from(pattern['chartData'] as List),
      'aiComment': pattern['aiComment'] as String,
    };
  }
  
  return additionalDates;
}

/// 기본 일일 리포트 (하위 호환성)
final mockDailyReport = mockDailyReports[_formatDate(DateTime.now())] ?? {
  'date': _formatDate(DateTime.now()),
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