final mockPet = [
   {
      'id': 1,
      'name': '도도',
      'breed': '말티푸',
      'age': 4,
      'gender': 'male',
      'photoUrl': 'https://your-s3-url.com/pets/dodo_profile.png',
      'registeredAt': '2025-10-11T09:00:00Z'
   },
   {
      'id': 2,
      'name': '말랑이',
      'breed': '비숑프리제',
      'age': 5,
      'gender': 'female',
      'photoUrl': 'https://your-s3-url.com/pets/dodo_profile.png',
      'registeredAt': '2025-10-23T10:10:00Z'
   }
];

// 홈 대시보드용 mock 데이터
final mockEmotionData = [
  {'emotion': '행복', 'percentage': 45, 'color': '#71AF46'},
  {'emotion': '평온', 'percentage': 30, 'color': '#8FC760'},
  {'emotion': '불안', 'percentage': 15, 'color': '#D9967A'},
  {'emotion': '외로움', 'percentage': 10, 'color': '#ECAB96'},
];

final mockAIRecommendations = [
  {
    'title': '산책하기 좋은 시간이에요 🚶‍♀️',
    'description': '현재 기온이 적당하고 습도가 낮아 산책하기 최적의 조건입니다.',
    'priority': 'high',
    'icon': '🚶‍♀️'
  },
  {
    'title': '간식량 조절이 필요해요 🍪',
    'description': '오늘 불안 행동이 평소보다 20% 증가했습니다. 간식을 조금 줄여보세요.',
    'priority': 'medium',
    'icon': '🍪'
  },
  {
    'title': '충분한 휴식이 필요해요 😴',
    'description': '최근 활동량이 평소보다 높아 피로감이 보입니다. 충분한 휴식을 취해주세요.',
    'priority': 'low',
    'icon': '😴'
  }
];

final mockWeatherData = [
  {
    'date': '어제',
    'temperature': '18°C',
    'condition': '맑음',
    'icon': '☀️',
    'comment': '활동량이 평소보다 15% 높았어요',
    'color': '#71AF46'
  },
  {
    'date': '오늘',
    'temperature': '15°C',
    'condition': '흐림',
    'icon': '☁️',
    'comment': '기온이 내려가서 산책 시 조심하세요 🌡️',
    'color': '#8FC760'
  },
  {
    'date': '내일',
    'temperature': '12°C',
    'condition': '비',
    'icon': '🌧️',
    'comment': '실내 활동을 권장합니다',
    'color': '#D9967A'
  },
  {
    'date': '모레',
    'temperature': '20°C',
    'condition': '맑음',
    'icon': '☀️',
    'comment': '산책하기 좋은 날씨예요!',
    'color': '#71AF46'
  }
];
