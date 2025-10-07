# 🐕 강아지 감정 및 슬개골 탈구 감지 시스템

캡스톤 디자인 프로젝트 - AI 파트

## 📁 프로젝트 구조

```
📦 Capstone Design
├── 📁 common/                           # 공통 유틸리티 모듈
│   ├── models/
│   │   └── dog_detection.py             # YOLO11 강아지 탐지
│   ├── data_processing/                 # 데이터 전처리 (향후 확장)
│   ├── utils/                           # 유틸리티 함수 (향후 확장)
│   └── schemas/                         # 데이터 스키마 (향후 확장)
├── 📁 dog_emotion_prediction/           # 감정 탐지 모델
│   └── emotion_model.py                 # 관절 기반 감정 분석
├── 📁 dog_patella_idslocation_detection/ # 슬개골 탈구 모델
│   └── patella_model.py                 # 뒷다리 관절 분석
├── 📁 Capstone_back/                    # FastAPI 백엔드
│   ├── main.py                          # API 서버
│   └── ai_service.py                    # AI 모듈 연동
├── 📁 DogPose_Official/                 # 파인튜닝된 YOLO11 모델
│   └── yolo11n_dog24/weights/best.pt    # 학습된 모델
├── 📄 ai_core_module.py                 # AI 통합 모듈
├── 📄 dog_skeleton_visualizer.py        # 관절 시각화 (개발용)
└── 📄 extract_validation_keypoints.py   # 검증 데이터 처리
```

## 🎯 주요 기능

### 1. 강아지 탐지 및 키포인트 추출
- **모델**: YOLO11 파인튜닝 (24개 → 20개 키포인트)
- **키포인트**: 코, 귀, 어깨, 발목, 꼬리 등 주요 관절
- **입력**: 이미지/영상
- **출력**: JSON 형태 관절 데이터

### 2. 감정 분석
- **위치**: `dog_emotion_prediction/emotion_model.py`
- **입력**: 관절 JSON 데이터
- **분석**: 꼬리, 귀, 자세 기반 감정 추론
- **출력**: 기쁨, 경계, 두려움, 편안함 등

### 3. 슬개골 탈구 위험도 분석
- **위치**: `dog_patella_idslocation_detection/patella_model.py`
- **입력**: 관절 JSON 데이터
- **분석**: 뒷다리 관절 각도 및 정렬 상태
- **출력**: 위험도 등급 및 권고사항

## 🔄 데이터 플로우

```
카메라/영상 → 강아지 탐지 → 관절 추출 → JSON 저장 → AI 분석 → 결과 출력
     ↓              ↓            ↓           ↓          ↓
  실시간 스트림   YOLO11 모델   키포인트    표준 형태   감정+슬개골
```

## 📊 데이터 형식

### 키포인트 JSON 구조
```json
{
  "dog_id_20241008": {
    "metadata": {
      "fps": 30,
      "total_frames": 900,
      "duration": 30.0,
      "processed_at": "2024-10-08T00:24:16"
    },
    "frames": {
      "frame_000001": {
        "timestamp": 0.033,
        "confidence": 0.89,
        "keypoints": {
          "nose": {"x": 320, "y": 240, "confidence": 0.95},
          "left_f_wrist": {"x": 280, "y": 350, "confidence": 0.88},
          "tail_s": {"x": 150, "y": 200, "confidence": 0.82}
        }
      }
    }
  }
}
```

### 분석 결과 형식
```json
{
  "dog_id": "dog_20241008",
  "emotion_analysis": {
    "primary_emotion": "happy",
    "confidence": 0.85,
    "emotion_scores": {"happy": 0.85, "calm": 0.10, "alert": 0.05}
  },
  "patella_analysis": {
    "risk_level": "low",
    "left_leg": {"risk": 0.15, "grade": 0},
    "right_leg": {"risk": 0.08, "grade": 0},
    "recommendations": ["정기적인 운동", "체중 관리"]
  }
}
```

## 🚀 사용 방법

### 강아지 탐지
```python
from common.models.dog_detection import DogDetector

detector = DogDetector('DogPose_Official/yolo11n_dog24/weights/best.pt')
result = detector.detect(image)
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

### API 서버 실행
```bash
cd Capstone_back
uvicorn main:app --reload
```

## 🔗 API 엔드포인트

```
POST /ai/detect              # 이미지 강아지 탐지
POST /ai/process-video        # 영상 처리 + 분석
GET  /ai/analysis/{dog_id}    # 분석 결과 조회  
GET  /ai/health-summary/{dog_id} # 건강 요약
GET  /ai/status              # AI 서비스 상태
```

## 👥 팀 역할

### 🤖 AI 파트 (현재)
- ✅ YOLO11 강아지 탐지 모델 파인튜닝
- ✅ 20개 키포인트 정의 및 추출
- ✅ 감정 분석 모델 기초 구조
- ✅ 슬개골 탈구 모델 기초 구조  
- ✅ 공통 모듈 및 유틸리티
- ⏳ 실제 AI 모델 훈련 (데이터 수집 후)

### 🔧 백엔드 파트
- ✅ FastAPI 서버 구조
- ✅ AI 모듈 연동 인터페이스
- ⏳ 실시간 영상 녹화 시스템
- ⏳ 데이터베이스 연동
- ⏳ 파일 저장 관리

### 🎨 프론트엔드 파트
- ⏳ 사용자 인터페이스
- ⏳ 실시간 모니터링 화면
- ⏳ 결과 시각화
- ⏳ 대시보드

## ⚙️ 환경 설정

### 필수 패키지
```bash
pip install ultralytics opencv-python fastapi uvicorn numpy
```

### YOLO11 모델
- 파인튜닝된 모델: `DogPose_Official/yolo11n_dog24/weights/best.pt`
- 베이스 모델: YOLO11n-pose
- 키포인트: 24개 → 20개 매핑

## 📝 개발 노트

### 완료된 작업
- [x] YOLO11 모델 파인튜닝 (Dog-Pose 데이터셋)
- [x] 20개 키포인트 매핑 정의
- [x] 관절 연결 시각화
- [x] AI 코어 모듈 구조
- [x] FastAPI 백엔드 연동
- [x] 감정 분석 알고리즘 기초
- [x] 슬개골 분석 알고리즘 기초

### 진행 중인 작업
- [ ] 실제 데이터 수집 및 라벨링
- [ ] 감정 분석 모델 훈련
- [ ] 슬개골 탈구 모델 훈련
- [ ] 실시간 영상 처리 최적화

### 향후 계획
- [ ] 모델 성능 평가 및 개선
- [ ] 추가 감정 상태 분류
- [ ] 다양한 견종 대응
- [ ] 배포 환경 최적화

## 🤝 협업 가이드

### Git 브랜치 전략
- `main`: 안정 버전
- `AI/feature-name`: AI 파트 개발
- `backend/feature-name`: 백엔드 개발
- `frontend/feature-name`: 프론트엔드 개발

### 커밋 컨벤션
- `feat:` 새로운 기능
- `fix:` 버그 수정
- `docs:` 문서 수정
- `refactor:` 코드 리팩토링
- `test:` 테스트 추가/수정

## 📞 연락처

AI 파트 담당자: [팀원명]
백엔드 파트 담당자: [팀원명]
프론트엔드 파트 담당자: [팀원명]