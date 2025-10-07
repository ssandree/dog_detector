# Common 모듈 - 공통 유틸리티

이 폴더는 강아지 감정 탐지 및 슬개골 탈구 감지 시스템의 공통 유틸리티들을 포함합니다.

## 📁 폴더 구조

```
common/
├── README.md                    # 이 파일
├── __init__.py                  # 모듈 초기화
├── models/                      # 공통 모델 유틸리티
│   ├── __init__.py
│   └── dog_detection.py         # 강아지 탐지 (YOLO11)
├── data_processing/             # 데이터 전처리
│   ├── __init__.py
│   ├── keypoint_extractor.py    # 관절 추출
│   ├── video_processor.py       # 영상 처리
│   └── data_formatter.py        # 데이터 포맷 변환
├── utils/                       # 유틸리티 함수
│   ├── __init__.py
│   ├── file_handler.py          # 파일 입출력
│   └── config.py                # 설정 관리
└── schemas/                     # 데이터 스키마
    ├── __init__.py
    ├── keypoint_schema.py       # 키포인트 데이터 구조
    └── analysis_schema.py       # 분석 결과 구조
```

## 🎯 모델별 위치

### 감정 탐지 모델
- **위치**: `dog_emotion_prediction/emotion_model.py`
- **기능**: 관절 데이터 기반 감정 분석

### 슬개골 탈구 탐지 모델  
- **위치**: `dog_patella_idslocation_detection/patella_model.py`
- **기능**: 뒷다리 관절 분석으로 탈구 위험도 평가

### 강아지 탐지 모델
- **위치**: `common/models/dog_detection.py`
- **기능**: YOLO11 기반 강아지 탐지 및 키포인트 추출

## 🚀 주요 기능

### 1. 강아지 탐지 (common/models/dog_detection.py)
- YOLO11 기반 강아지 탐지
- 20개 키포인트 추출
- 실시간 처리 지원

### 2. 데이터 처리 (data_processing/)
- 영상 → 관절 데이터 추출
- JSON 형태 데이터 변환
- 전처리 파이프라인

### 3. 유틸리티 (utils/)
- 파일 입출력 헬퍼
- 설정 관리
- 공통 함수들

## 📊 데이터 형식

### 키포인트 JSON 구조
```json
{
  "dog_id": {
    "metadata": {
      "fps": 30,
      "total_frames": 900,
      "duration": 30.0
    },
    "frames": {
      "frame_000001": {
        "timestamp": 0.033,
        "keypoints": {
          "nose": {"x": 320, "y": 240, "confidence": 0.95},
          "left_f_wrist": {"x": 280, "y": 350, "confidence": 0.88}
        }
      }
    }
  }
}
```

## 🔧 사용 방법

### 기본 사용법
```python
from common.models.dog_detection import DogDetector
from common.data_processing.keypoint_extractor import KeypointExtractor

# 강아지 탐지
detector = DogDetector('path/to/model.pt')
result = detector.detect(image)

# 관절 추출
extractor = KeypointExtractor()
keypoints = extractor.extract_from_video('video.mp4')
```

### 감정 분석
```python
from dog_emotion_prediction.emotion_model import EmotionDetector

emotion_detector = EmotionDetector()
emotion_result = emotion_detector.analyze_emotion(keypoint_data)
```

### 슬개골 분석
```python
from dog_patella_idslocation_detection.patella_model import PatellaDetector

patella_detector = PatellaDetector()
patella_result = patella_detector.analyze_patella_risk(keypoint_data)
```

## ⚙️ 설정

모델 경로 및 설정은 `utils/config.py`에서 관리합니다.

## 📝 Git 구조

### AI 파트 담당
- `common/` - 공통 유틸리티 및 데이터 처리
- `dog_emotion_prediction/` - 감정 탐지 모델
- `dog_patella_idslocation_detection/` - 슬개골 탈구 모델
- `ai_core_module.py` - AI 통합 모듈
- `DogPose_Official/` - 파인튜닝된 YOLO11 모델

### 백엔드 파트
- `Capstone_back/` - FastAPI 백엔드
- `ai_service.py` - AI 모듈 연동 서비스

### 협업 플로우
1. AI 파트: 모델 개발 및 공통 모듈 관리
2. 백엔드 파트: API 서버 및 데이터베이스
3. 프론트엔드 파트: 사용자 인터페이스