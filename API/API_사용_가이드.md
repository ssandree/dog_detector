# 🐕 강아지 AI 분석 API 사용 가이드

## 📋 목차
1. [API 서버 실행 방법](#1-api-서버-실행-방법)
2. [API 엔드포인트](#2-api-엔드포인트)
3. [프론트엔드 연동 가이드](#3-프론트엔드-연동-가이드)
4. [백엔드 개발자용 가이드](#4-백엔드-개발자용-가이드)
5. [응답 형식](#5-응답-형식)

---

## 1. API 서버 실행 방법

### 🚀 **방법 1: 자동 실행 (권장)**
```bash
cd API
python start_ai_server.py
```

### 🚀 **방법 2: 직접 실행**
```bash
cd API
python api_server.py
```

### ✅ **실행 확인**
- 서버 주소: `http://localhost:8000`
- API 문서: `http://localhost:8000/docs` (자동 생성된 Swagger UI)
- 상태 확인: `http://localhost:8000/api/status`

---

## 2. API 엔드포인트

### 📹 **1) 실시간 강아지 탐지** (다중 카메라 지원)
**엔드포인트**: `POST /api/detect-realtime`

**용도**: 프론트엔드에서 실시간 웹캠 프레임을 전송하여 강아지 탐지 (여러 카메라 동시 지원)

**요청**:
```bash
curl -X POST "http://localhost:8000/api/detect-realtime" \
  -F "file=@frame.jpg" \
  -F "camera_id=camera_1"
```

**응답**:
```json
{
  "camera_id": "camera_1",
  "should_start_recording": true,
  "confidence": 0.95
}
```

**필드 설명**:
- `camera_id`: 카메라 식별 번호 (입력값 그대로 반환)
- `should_start_recording`: 녹화 시작 신호 (true/false)
- `confidence`: 탐지 신뢰도 (0.0 ~ 1.0)

---

### 🎬 **2) MP4 영상 분석 (URL 방식)** - 클라우드 연동
**엔드포인트**: `POST /api/analyze-video-url`

**용도**: 클라우드(AWS S3, Google Cloud 등)에 저장된 영상 URL로 분석

**요청**:
```bash
curl -X POST "http://localhost:8000/api/analyze-video-url" \
  -F "video_url=https://your-cloud-storage.com/dog_video.mp4"
```

**응답**:
```json
{
  "emotion": "편안/안정",
  "patella_status": "정상"
}
```

**필드 설명**:
- `emotion`: 감정 판단 결과 (`"편안/안정"`, `"불안/슬픔"`, `"공포"`, `"공격성"`)
- `patella_status`: 슬개골 탈구 여부 (`"정상"`, `"이상"`)

---

### 📁 **3) MP4 파일 업로드 분석**
**엔드포인트**: `POST /api/analyze-video-file`

**용도**: 프론트엔드에서 직접 파일 업로드

**요청**:
```bash
curl -X POST "http://localhost:8000/api/analyze-video-file" \
  -F "file=@my_dog_video.mp4"
```

**응답**:
```json
{
  "emotion": "불안/슬픔",
  "patella_status": "이상"
}
```

**필드 설명**:
- `emotion`: 감정 판단 결과 (`"편안/안정"`, `"불안/슬픔"`, `"공포"`, `"공격성"`)
- `patella_status`: 슬개골 탈구 여부 (`"정상"`, `"이상"`)

---

## 3. 프론트엔드 연동 가이드

### 🌐 **React/Vue/Angular 예제**

#### **1) 실시간 웹캠 탐지 (다중 카메라)**
```javascript
// 웹캠에서 프레임 캡처 후 전송
async function detectDogRealtime(imageBlob, cameraId) {
  const formData = new FormData();
  formData.append('file', imageBlob);
  formData.append('camera_id', cameraId);  // 카메라 번호 추가

  const response = await fetch('http://localhost:8000/api/detect-realtime', {
    method: 'POST',
    body: formData
  });

  const result = await response.json();
  
  if (result.should_start_recording) {
    console.log(`🐕 카메라 ${result.camera_id}에서 강아지 감지! 신뢰도: ${result.confidence}`);
    startRecording(result.camera_id);
  }
}

// 사용 예시: 여러 카메라 동시 모니터링
detectDogRealtime(imageBlob1, 'camera_1');
detectDogRealtime(imageBlob2, 'camera_2');
detectDogRealtime(imageBlob3, 'camera_3');
```

#### **2) MP4 파일 업로드 및 분석**
```javascript
async function analyzeVideo(file) {
  const formData = new FormData();
  formData.append('file', file);

  const response = await fetch('http://localhost:8000/api/analyze-video-file', {
    method: 'POST',
    body: formData
  });

  const result = await response.json();
  
  console.log('감정:', result.emotion);           // "편안/안정", "불안/슬픔", "공포", "공격성"
  console.log('슬개골:', result.patella_status);  // "정상", "이상"
}
```

#### **3) 클라우드 URL 분석**
```javascript
async function analyzeFromCloud(videoUrl) {
  const formData = new FormData();
  formData.append('video_url', videoUrl);

  const response = await fetch('http://localhost:8000/api/analyze-video-url', {
    method: 'POST',
    body: formData
  });

  const result = await response.json();
  return result;
}
```

---

## 4. 백엔드 개발자용 가이드

### 🔧 **Python FastAPI 클라이언트 예제**

```python
import requests

# 1. 파일 업로드 분석
def analyze_video_file(file_path):
    url = "http://localhost:8000/api/analyze-video-file"
    
    with open(file_path, 'rb') as f:
        files = {'file': f}
        
        response = requests.post(url, files=files)
        return response.json()

# 2. 클라우드 URL 분석
def analyze_video_url(video_url):
    url = "http://localhost:8000/api/analyze-video-url"
    
    data = {'video_url': video_url}
    
    response = requests.post(url, data=data)
    return response.json()

# 사용 예시
result = analyze_video_file("./dog_video.mp4")
print(f"감정: {result['emotion']}")
print(f"슬개골: {result['patella_status']}")
```

---

## 5. 응답 형식

### ✅ **성공 응답**

#### **실시간 탐지 응답**
```json
{
  "camera_id": "camera_1",
  "should_start_recording": true,
  "confidence": 0.95
}
```

**필드 설명**:
- `camera_id`: 카메라 식별 번호 (어느 카메라에서 탐지되었는지 구분)
- `should_start_recording`: 녹화 시작 신호 (true/false) - 신뢰도 0.7 이상일 때 true
- `confidence`: 강아지 탐지 신뢰도 (0.0 ~ 1.0)

#### **영상 분석 결과**
```json
{
  "emotion": "편안/안정",
  "patella_status": "정상"
}
```

**필드 설명**:
- `emotion`: 감정 판단 결과
  - **가능한 값**: `"편안/안정"`, `"불안/슬픔"`, `"공포"`, `"공격성"`
- `patella_status`: 슬개골 탈구 여부
  - **가능한 값**: `"정상"`, `"이상"`

---

### ❌ **에러 응답**

```json
{
  "detail": "MP4 다운로드 실패: Connection timeout"
}
```

**HTTP 상태 코드**:
- `400`: 잘못된 요청 (파일 형식 오류, URL 오류 등)
- `404`: 리소스 없음
- `500`: 서버 내부 오류

---

## 6. 프론트엔드/백엔드에게 제공할 파일

### 📦 **프론트엔드 개발자에게 전달**
1. ✅ **이 문서 (API_사용_가이드.md)**
2. ✅ **API 서버 주소**: `http://localhost:8000` (배포 시 실제 도메인으로 변경)
3. ✅ **Swagger API 문서**: `http://localhost:8000/docs`
4. ✅ **테스트용 영상 파일** (샘플 데이터)

### 📦 **백엔드 개발자에게 전달**
1. ✅ **전체 프로젝트 폴더** (`Capstone Design/`)
2. ✅ **requirements.txt** (패키지 의존성)
3. ✅ **API 서버 코드**:
   - `API/api_server.py`
   - `API/ai_service.py`
   - `ai_core_module.py`
4. ✅ **모델 가중치 파일**:
   - `ai_train/best_dog_emotion_model_f1.pth`
   - `dog_pattela_model/patella_model.pt`
   - `ai_train/dog_pose_stats.pt`
   - `dog_pattela_model/patella_stats_seg60.pt`
5. ✅ **포즈 탐지 모델**:
   - `DogPose_Official/yolo11n_dog24_v242/weights/best.pt`

---

## 7. 설치 및 환경 설정

### 📦 **필수 패키지 설치**
```bash
pip install -r requirements.txt
```

### 🔑 **주요 패키지**
- `fastapi` - API 서버 프레임워크
- `uvicorn` - ASGI 서버
- `torch` - 딥러닝 프레임워크
- `ultralytics` - YOLO 포즈 탐지
- `opencv-python` - 영상 처리
- `pandas`, `numpy`, `scipy` - 데이터 처리

---

## 8. 테스트 방법

### 🧪 **Swagger UI로 테스트**
1. 브라우저에서 `http://localhost:8000/docs` 접속
2. 원하는 API 엔드포인트 선택
3. "Try it out" 버튼 클릭
4. 파일 또는 URL 입력 후 "Execute" 실행
5. 응답 확인

### 🧪 **cURL로 테스트**
```bash
# 실시간 탐지 테스트 (카메라 1)
curl -X POST "http://localhost:8000/api/detect-realtime" \
  -F "file=@test_frame.jpg" \
  -F "camera_id=camera_1"

# 실시간 탐지 테스트 (카메라 2)
curl -X POST "http://localhost:8000/api/detect-realtime" \
  -F "file=@test_frame.jpg" \
  -F "camera_id=camera_2"

# 파일 업로드 테스트
curl -X POST "http://localhost:8000/api/analyze-video-file" \
  -F "file=@test_video.mp4"
```

---

## 9. 배포 시 주의사항

### 🚀 **프로덕션 환경**
1. **CORS 설정 변경**:
   ```python
   # api_server.py
   app.add_middleware(
       CORSMiddleware,
       allow_origins=["https://your-frontend-domain.com"],  # 실제 도메인으로 변경
       allow_credentials=True,
       allow_methods=["*"],
       allow_headers=["*"],
   )
   ```

2. **서버 실행** (프로덕션):
   ```bash
   uvicorn api_server:app --host 0.0.0.0 --port 8000 --workers 4
   ```

3. **GPU 사용** (추론 속도 향상):
   - CUDA 설치 확인
   - PyTorch GPU 버전 설치

---

## 10. 문제 해결 (Troubleshooting)

### ❓ **자주 발생하는 문제**

**Q1: "모델 파일이 없습니다" 오류**
```
⚠️ 포즈 모델 파일 없음: ai_train/best_dog_emotion_model_f1.pth
```
**해결**: 모델 가중치 파일을 올바른 위치에 배치했는지 확인

**Q2: "CUDA out of memory" 오류**
**해결**: 배치 크기 줄이기 또는 CPU 모드로 전환

**Q3: "ffmpeg 오류"**
**해결**: ffmpeg 설치 (`pip install ffmpeg-python`)

---

## 📞 지원

문제 발생 시:
1. API 문서 확인: `http://localhost:8000/docs`
2. 로그 확인: 터미널에 출력되는 에러 메시지
3. 이슈 리포팅: GitHub Issues

---

**🎉 모든 준비가 완료되었습니다! API를 사용해보세요!**
