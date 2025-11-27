// event_mock.dart

/// GET /pets/{pet_id}/events 응답 Mock 데이터
final List<Map<String, dynamic>> mockEventList = [
  {
    "event_id": 101,
    "pet_id": 1,
    "device_id": 1,
    "start_time": "2025-11-25T10:21:00Z",
    "end_time": "2025-11-25T10:21:35Z",
    "video_duration_sec": 35,
    "video_url": "https://mock.server/videos/event101.mp4",
    "thumbnail_url": "https://mock.server/thumbnails/event101.jpg",
    "detected_features": "꼬리 흔들기, 산책 후 휴식",
    "final_emotion": "행복",
    "patella_analysis_result": "정상",
  },
  {
    "event_id": 102,
    "pet_id": 1,
    "device_id": 1,
    "start_time": "2025-11-25T12:07:00Z",
    "end_time": "2025-11-25T12:07:45Z",
    "video_duration_sec": 45,
    "video_url": "https://mock.server/videos/event102.mp4",
    "thumbnail_url": "https://mock.server/thumbnails/event102.jpg",
    "detected_features": "귀 핥기, 가벼운 불안 반응",
    "final_emotion": "불안",
    "patella_analysis_result": "경고: 슬개골 탈구 의심",
  },
  {
    "event_id": 103,
    "pet_id": 2,
    "device_id": 2,
    "start_time": "2025-11-25T14:30:00Z",
    "end_time": "2025-11-25T14:30:50Z",
    "video_duration_sec": 50,
    "video_url": "https://mock.server/videos/event103.mp4",
    "thumbnail_url": "https://mock.server/thumbnails/event103.jpg",
    "detected_features": "노즈워크, 탐색 행동",
    "final_emotion": "평온",
    "patella_analysis_result": "정상",
  },
  {
    "event_id": 104,
    "pet_id": 1,
    "device_id": 1,
    "start_time": "2025-11-25T16:12:00Z",
    "end_time": "2025-11-25T16:12:30Z",
    "video_duration_sec": 30,
    "video_url": "https://mock.server/videos/event104.mp4",
    "thumbnail_url": "https://mock.server/thumbnails/event104.jpg",
    "detected_features": "낯선 소리에 반응하며 귀를 세움",
    "final_emotion": "경계",
    "patella_analysis_result": "정상",
  },
  {
    "event_id": 105,
    "pet_id": 2,
    "device_id": 2,
    "start_time": "2025-11-25T18:55:00Z",
    "end_time": "2025-11-25T18:55:40Z",
    "video_duration_sec": 40,
    "video_url": "https://mock.server/videos/event105.mp4",
    "thumbnail_url": "https://mock.server/thumbnails/event105.jpg",
    "detected_features": "저녁 식사 기다리며 꼬리 흔듦",
    "final_emotion": "기대",
    "patella_analysis_result": "정상",
  },
  {
    "event_id": 106,
    "pet_id": 3,
    "device_id": 1,
    "start_time": "2025-11-25T21:10:00Z",
    "end_time": "2025-11-25T21:10:20Z",
    "video_duration_sec": 20,
    "video_url": "https://mock.server/videos/event106.mp4",
    "thumbnail_url": "https://mock.server/thumbnails/event106.jpg",
    "detected_features": "쿠션 위에서 휴식",
    "final_emotion": "평온",
    "patella_analysis_result": "정상",
  },
];

/// GET /pets/{pet_id}/events/daily?date=YYYY-MM-DD 응답 Mock 데이터
/// 오늘 날짜로 동적으로 생성
Map<String, dynamic> getMockDailyEventResponse() {
  final today = DateTime.now();
  final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  
  return {
    "pet_id": 1,
    "date": dateStr,
    "events": [
      {
        "event_id": 201,
        "pet_id": 1,
        "device_id": 1,
        "start_time": "${dateStr}T08:05:00Z",
        "end_time": "${dateStr}T08:05:40Z",
        "video_duration_sec": 40,
        "video_url": "https://mock.server/videos/event201.mp4",
        "thumbnail_url": "https://mock.server/thumbnails/event201.jpg",
        "detected_features": "식사 후 스트레칭",
        "final_emotion": "행복",
        "patella_analysis_result": "정상"
      },
      {
        "event_id": 202,
        "pet_id": 1,
        "device_id": 1,
        "start_time": "${dateStr}T13:20:00Z",
        "end_time": "${dateStr}T13:20:55Z",
        "video_duration_sec": 55,
        "video_url": "https://mock.server/videos/event202.mp4",
        "thumbnail_url": "https://mock.server/thumbnails/event202.jpg",
        "detected_features": "문을 긁으며 대기",
        "final_emotion": "불안",
        "patella_analysis_result": "관찰 필요"
      },
      {
        "event_id": 203,
        "pet_id": 1,
        "device_id": 1,
        "start_time": "${dateStr}T19:45:00Z",
        "end_time": "${dateStr}T19:45:25Z",
        "video_duration_sec": 25,
        "video_url": "https://mock.server/videos/event203.mp4",
        "thumbnail_url": "https://mock.server/thumbnails/event203.jpg",
        "detected_features": "장난감 물고 놀이",
        "final_emotion": "평온",
        "patella_analysis_result": "정상"
      },
      {
        "event_id": 204,
        "pet_id": 1,
        "device_id": 2,
        "start_time": "${dateStr}T21:30:00Z",
        "end_time": "${dateStr}T21:30:50Z",
        "video_duration_sec": 50,
        "video_url": "https://mock.server/videos/event204.mp4",
        "thumbnail_url": "https://mock.server/thumbnails/event204.jpg",
        "detected_features": "야간 순찰, 집 안 배회",
        "final_emotion": "경계",
        "patella_analysis_result": "정상"
      },
      {
        "event_id": 205,
        "pet_id": 1,
        "device_id": 1,
        "start_time": "${dateStr}T23:10:00Z",
        "end_time": "${dateStr}T23:10:20Z",
        "video_duration_sec": 20,
        "video_url": "https://mock.server/videos/event205.mp4",
        "thumbnail_url": "https://mock.server/thumbnails/event205.jpg",
        "detected_features": "잠자리 준비, 이불 파기",
        "final_emotion": "안정",
        "patella_analysis_result": "정상"
      },
    ],
  };
}

/// GET /pets/{pet_id}/events/monthly?year=YYYY&month=MM 응답 Mock 데이터
final Map<String, dynamic> mockMonthlyEventResponse = {
  "pet_id": 1,
  "year": 2025,
  "month": 11,
  "days": {
    "1": {
      "happy": 2,
      "calm": 1,
      "angry": 0,
      "fear": 0,
      "total_events": 3,
      "score": 3
    },
    "2": {
      "happy": 0,
      "calm": 0,
      "angry": 1,
      "fear": 1,
      "total_events": 2,
      "score": -2
    },
    "3": {
      "happy": 1,
      "calm": 0,
      "angry": 0,
      "fear": 0,
      "total_events": 1,
      "score": 1
    },
    "4": {
      "happy": 0,
      "calm": 0,
      "angry": 0,
      "fear": 0,
      "total_events": 0,
      "score": 0
    },
    "5": {
      "happy": 3,
      "calm": 1,
      "angry": 1,
      "fear": 0,
      "total_events": 5,
      "score": 4
    },
    "6": {
      "happy": 1,
      "calm": 2,
      "angry": 0,
      "fear": 0,
      "total_events": 3,
      "score": 3
    },
    "7": {
      "happy": 0,
      "calm": 1,
      "angry": 1,
      "fear": 0,
      "total_events": 2,
      "score": -1
    },
    "8": {
      "happy": 2,
      "calm": 0,
      "angry": 0,
      "fear": 1,
      "total_events": 3,
      "score": 1
    },
    "9": {
      "happy": 0,
      "calm": 0,
      "angry": 0,
      "fear": 0,
      "total_events": 0,
      "score": 0
    },
    "10": {
      "happy": 4,
      "calm": 1,
      "angry": 0,
      "fear": 0,
      "total_events": 5,
      "score": 5
    },
  },
};
