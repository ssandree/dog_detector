final mockDailyReport = {
  "date": "2025-10-11",
  "events": [
    {"time": "09:10", "type": "낑낑거림 감지", "emotion": "불안", "severity": "MEDIUM"},
    {"time": "15:22", "type": "하울링 감지", "emotion": "불안", "severity": "HIGH"},
  ],
  "chartData": [
    {"hour": "00", "activity": 3, "barkCount": 0},
    {"hour": "12", "activity": 8, "barkCount": 2},
    {"hour": "18", "activity": 10, "barkCount": 4},
  ],
  "aiComment": "오늘은 낮 시간대에 불안 행동이 두 차례 감지되었어요. 오후 산책을 조금 줄여보세요 🐕",
};

final mockWeeklyReport = {
  "startDate": "2025-10-06",
  "endDate": "2025-10-12",
  "trend": "지난주보다 하울링 빈도가 12% 감소했습니다 🎉",
  "dailyStats": [
    {"date": "10-06", "bark": 10, "howl": 2},
    {"date": "10-07", "bark": 8, "howl": 1},
    {"date": "10-08", "bark": 5, "howl": 0},
    {"date": "10-09", "bark": 3, "howl": 1},
    {"date": "10-10", "bark": 7, "howl": 3},
  ]
};
