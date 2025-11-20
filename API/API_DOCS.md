# 🐕 강아지 AI 분석 API 명세서

## 📡 서버 정보
- **Base URL**: `http://localhost:8000` (개발 환경)
- **Production URL**: `http://0.0.0.0:8000` (배포 시)
- **API 문서**: `http://localhost:8000/docs` (Swagger UI)

## 🚀 API 엔드포인트

### 1. 서버 상태 확인
```http
GET /
```

**응답 예시:**
```json
{
  "message": "강아지 AI 분석 서버가 정상 동작 중입니다",
  "timestamp": "2024-11-12T10:30:00",
  "version": "1.0.0"
}
```

---

### 2. 실시간 강아지 탐지 (녹화 트리거용)
```http
POST /api/detect-realtime
Content-Type: multipart/form-data
``` 

**요청:**
- `image`: 이미지 파일 (jpg, png)

**응답:**
```json
{
  "detected": true,
  "confidence": 0.85,
  "timestamp": "2024-11-12T10:30:00.123Z"
}
```

---

### 3. 🎯 **메인 API: 비디오 URL 분석**
```http
POST /api/analyze-video-url
Content-Type: application/json
```

**요청:**
```json
{
  "url": "https://example.com/dog-video.mp4"
}
```

**응답 (백엔드가 받을 결과):**
```json
{
  "emotion": "편안/안정",
  "patella_status": "정상"
}
```

---

### 4. 🎯 **메인 API: 비디오 파일 업로드 분석**
```http
POST /api/analyze-video-file
Content-Type: multipart/form-data
```

**요청:**
- `file`: MP4/MOV/AVI 비디오 파일

**응답 (백엔드가 받을 결과):**
```json
{
  "emotion": "불안/슬픔",
  "patella_status": "이상"
}
```

---

## 📊 응답 데이터 형식

### 감정 분석 결과 (`emotion`)
- `"편안/안정"`: 강아지가 안정되고 편안한 상태
- `"불안/슬픔"`: 스트레스나 불안감을 보이는 상태  
- `"공포"`: 두려움이나 극도의 스트레스 상태
- `"공격성"`: 공격적이거나 경계하는 상태

### 슬개골 탈구 분석 결과 (`patella_status`)
- `"정상"`: 슬개골 탈구 위험이 낮음
- `"이상"`: 슬개골 탈구 위험이 있어 주의 필요

---

## 🔧 백엔드 연동 가이드

### 1. **Python 요청 예시**
```python
import requests

# 비디오 URL 분석
response = requests.post(
    "http://localhost:8000/api/analyze-video-url",
    json={"url": "https://example.com/dog.mp4"},
    timeout=60
)
result = response.json()
emotion = result["emotion"]
patella = result["patella_status"]
```

### 2. **JavaScript (Node.js) 예시**
```javascript
const axios = require('axios');

const analyzeVideo = async (videoUrl) => {
  try {
    const response = await axios.post('http://localhost:8000/api/analyze-video-url', {
      url: videoUrl
    }, {
      timeout: 60000
    });
    
    return {
      emotion: response.data.emotion,
      patella_status: response.data.patella_status
    };
  } catch (error) {
    console.error('분석 실패:', error);
  }
};
```

### 3. **cURL 예시**
```bash
# 비디오 URL 분석
curl -X POST "http://localhost:8000/api/analyze-video-url" \
     -H "Content-Type: application/json" \
     -d '{"url": "https://example.com/dog.mp4"}'

# 파일 업로드 분석  
curl -X POST "http://localhost:8000/api/analyze-video-file" \
     -F "file=@/path/to/dog_video.mp4"
```

---

## ⚠️ 주의사항

1. **타임아웃 설정**: 비디오 분석은 30-60초 소요될 수 있음
2. **파일 크기**: MP4 파일은 100MB 이하 권장
3. **동시 요청**: 현재 순차 처리 (동시 분석 불가)
4. **에러 처리**: HTTP 400/500 에러 시 적절한 처리 필요

---

## 🐛 에러 응답

```json
{
  "detail": "MP4 분석 실패: 강아지를 찾을 수 없습니다"
}
```

**일반적인 에러 코드:**
- `400`: 잘못된 요청 (파일 형식 오류, URL 오류)
- `500`: 서버 내부 오류 (모델 로딩 실패, 분석 실패)