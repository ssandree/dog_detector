// report_mock.dart

/// 특정 pet_id의 리포트 전체 리스트
final Map<int, List<Map<String, dynamic>>> mockReportList = {
  1: [
    {
      "report_id": 501,
      "pet_id": 1,
      "report_date": "2025-11-23",
      "summary_text": "초코는 오늘 산책도 하고 충분한 휴식을 취했습니다. 전체적으로 긍정적인 감정 상태를 보였습니다.",
      "created_at": "2025-11-23T20:11:00Z"
    },
    {
      "report_id": 502,
      "pet_id": 1,
      "report_date": "2025-11-24",
      "summary_text": "초코는 오후에 다소 불안한 행동을 보였지만, 전반적으로 안정적이었습니다.",
      "created_at": "2025-11-24T20:11:00Z"
    },
  ],

  2: [
    {
      "report_id": 601,
      "pet_id": 2,
      "report_date": "2025-11-23",
      "summary_text": "몽이는 활발하게 움직이며 에너지 넘치는 하루를 보냈습니다.",
      "created_at": "2025-11-23T19:50:00Z"
    },
    {
      "report_id": 602,
      "pet_id": 2,
      "report_date": "2025-11-24",
      "summary_text": "몽이는 낮 동안 평온한 감정 상태를 유지했습니다.",
      "created_at": "2025-11-24T19:50:00Z"
    },
  ],
};

/// 날짜 단위 기본 mock (일일 조회용)
final Map<String, dynamic> mockDailyReport = {
  "report_id": 999,
  "pet_id": 0,
  "report_date": "2025-11-25",
  "summary_text": "기본 Mock 리포트입니다. 감정 분석 데이터가 충분하지 않습니다.",
  "created_at": "2025-11-25T12:00:00Z"
};

/// date string → report map
final Map<String, Map<String, dynamic>> mockDailyReports = {
  "2025-11-23": {
    "report_id": 700,
    "pet_id": 1,
    "report_date": "2025-11-23",
    "summary_text": "Mock 일일 리포트: 산책 + 간식 = 행복지수 상승!",
    "created_at": "2025-11-23T21:00:00Z",
  },
};
