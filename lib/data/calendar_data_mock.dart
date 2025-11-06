// 캘린더 화면용 목업 데이터만 분리

final mockCalendarData = {
  // Top 3 감정 통계
  'rankStats': [
    {'rank': 1, 'emotion': '행복함', 'count': 342, 'bgColor': 'green1', 'borderColor': 'green3'},
    {'rank': 2, 'emotion': '불안함', 'count': 267, 'bgColor': 'coral1', 'borderColor': 'coral3'},
    {'rank': 3, 'emotion': '편안함', 'count': 198, 'bgColor': 'green1', 'borderColor': 'green3'},
  ],
  // 파이 차트 데이터
  'pieChartData': [
    {'emotion': '행복함', 'percentage': 18, 'color': 'green5'},
    {'emotion': '불안함', 'percentage': 25, 'color': 'coral4'},
    {'emotion': '편안함', 'percentage': 22, 'color': 'green3'},
    {'emotion': '불쾌함', 'percentage': 20, 'color': 'coral3'},
    {'emotion': '기타', 'percentage': 15, 'color': 'grey4'},
  ],
  // 감정 비율 바
  'emotionRatio': {
    'negativePercent': 52,
    'positivePercent': 48,
    'negativeColor': 'coral2',
    'positiveColor': 'green2',
  },
  // 건강 알림
  'healthAlert': {
    'message': '이번 달 슬개골 탈구 의심 행동이 32회 감지되었습니다.',
    'detectionCount': '32회',
    'countLabel': '총 감지 횟수',
    'timeSlots': [
      {'time': '오전', 'count': '8회', 'color': 'green5'},
      {'time': '오후', 'count': '15회', 'color': 'coral4'},
      {'time': '저녁', 'count': '9회', 'color': 'green3'},
    ],
    'icon': 'warning_amber_rounded',
    'bgColor': 'green1',
    'iconColor': 'green5',
    'textColor': 'green8',
  },
  // AI 리포트
  'aiReport': {
    'title': 'AI 리포트',
    'subtitle': '이번 달 도도의 종합 분석을 AI가 완료했어요!',
    'statusLabel': '위험',
    'statusColor': 'error',
    'analysisTexts': [
      '월간 감정 분석 결과 불안·불쾌한 감정이 52%로 긍정적인 감정 48%보다 높았습니다.',
      '이번 달 슬개골 탈구 의심 행동이 총 32회 감지되었습니다. 3주차에 집중적으로 나타났으며, 현재 단계는 \'위험\'에 해당합니다. 즉시 전문의 상담이 필요합니다.',
    ],
    'guideItems': [
      '월 30회 이상 감지로 즉시 동물병원 방문이 필요합니다.',
      '3주차 패턴을 보면 특정 활동이나 환경이 원인일 가능성이 높습니다.',
      '수술을 고려해야 할 단계이므로 전문의와 상담하여 치료 계획을 세우세요.',
    ],
  },
  // 월간 트렌드 분석
  'monthlyTrend': {
    'radarEntries': [
      {'value': 4, 'label': '행복함'},
      {'value': 2, 'label': '불안함'},
      {'value': 3, 'label': '편안함'},
      {'value': 2, 'label': '불쾌함'},
      {'value': 4, 'label': '활동량'},
      {'value': 3, 'label': '건강상태'},
    ],
  },
  // 월간 요약
  'monthlySummary': {
    'summaryText': '이번 달은 전반적으로 안정적인 감정 상태를 유지했습니다.',
    'bulletPoints': [
      '행복한 감정이 가장 많이 나타났습니다 (342회)',
      '주간별로 안정적인 패턴을 보였습니다',
      '활동량이 점진적으로 증가하는 추세입니다',
    ],
  },
};


