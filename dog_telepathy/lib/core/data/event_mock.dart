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
];
