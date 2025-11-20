# 🤖 AI 모델 배포 가이드 (백엔드 팀원용)

## 📦 AI 시스템 구성 요소

### 1. 필요한 파일들
```
프로젝트/
├── ai_core_module.py           # 핵심 AI 로직
├── API/
│   ├── api_server.py          # FastAPI 서버
│   ├── ai_service.py          # AI 서비스 로직
│   └── requirements.txt       # Python 패키지 목록
├── ai_train/
│   ├── best_dog_emotion_model_f1.pth    # 감정 분석 모델
│   ├── audio_emotion_model.pt           # 음성 감정 모델  
│   └── dog_pose_stats.pt               # 전처리 통계
├── dog_pattela_model/
│   ├── patella_model.pt               # 슬개골 탈구 모델
│   └── patella_stats_seg60.pt         # 슬개골 전처리 통계
└── DogPose_Official/yolo11n_dog24_v242/weights/
    └── best.pt                        # 강아지 포즈 탐지 모델
```

### 2. AI 모델 크기 및 특징
- **총 용량**: 약 500MB~1GB
- **GPU 요구사항**: CPU만으로도 동작 (GPU 있으면 더 빠름)
- **메모리**: 최소 4GB RAM 권장
- **Python 버전**: 3.8+ 

## 🔧 백엔드 서버 설정 가이드

### Step 1: 환경 설정
```bash
# Python 가상환경 생성
python -m venv dog_ai_env
source dog_ai_env/bin/activate  # Linux/Mac
# 또는 dog_ai_env\Scripts\activate  # Windows

# 필수 패키지 설치
pip install -r requirements.txt
pip install fastapi uvicorn python-multipart
```

### Step 2: AI 모델 파일 배치
```bash
# 프로젝트 구조 생성
mkdir -p ai_train dog_pattela_model DogPose_Official/yolo11n_dog24_v242/weights

# 모델 파일들을 각각의 위치에 복사
# (AI 담당자로부터 받은 .pt, .pth 파일들)
```

### Step 3: 서버 실행
```bash
cd API
python api_server.py
```

### Step 4: 동작 확인
- 서버 상태: http://localhost:8000/
- API 문서: http://localhost:8000/docs
- 테스트: POST 요청으로 비디오 분석

## 🌐 배포 옵션

### 옵션 1: 직접 서버 배포
```bash
# PM2로 백그라운드 실행
npm install -g pm2
pm2 start "python api_server.py" --name dog-ai-api

# 또는 systemd 서비스로 등록
```

### 옵션 2: Docker 컨테이너 배포
```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["python", "API/api_server.py"]
```

### 옵션 3: AWS/클라우드 배포
- EC2 인스턴스에 직접 배포
- Docker + ECS 배포  
- Lambda + API Gateway (경량화 필요)

## 📡 백엔드 연동 방법

### 백엔드에서 AI API 호출 예시 (Node.js)
```javascript
const axios = require('axios');

const analyzeVideo = async (videoUrl) => {
  try {
    const response = await axios.post('http://AI_SERVER_IP:8000/api/analyze-video-url', {
      url: videoUrl
    }, { timeout: 60000 });
    
    return {
      emotion: response.data.emotion,      // "편안/안정", "불안/슬픔", "공포", "공격성"
      patella: response.data.patella_status  // "정상", "이상"
    };
  } catch (error) {
    console.error('AI 분석 실패:', error);
    throw error;
  }
};
```

### 백엔드에서 AI API 호출 예시 (Python FastAPI)
```python
import httpx

async def analyze_dog_video(video_url: str):
    async with httpx.AsyncClient(timeout=60.0) as client:
        response = await client.post(
            "http://AI_SERVER_IP:8000/api/analyze-video-url",
            json={"url": video_url}
        )
        return response.json()
```

## ⚠️ 주의사항

1. **네트워크**: AI 서버와 백엔드 서버 간 네트워크 연결 확인
2. **타임아웃**: 비디오 분석은 30-60초 소요 가능
3. **동시성**: 현재는 순차 처리 (개선 가능)
4. **보안**: 프로덕션에서는 API 인증 추가 필요

## 📞 지원 연락처
AI 담당자: [연락처 정보]
- 모델 파일 전달
- 환경 설정 지원  
- 성능 최적화 상담