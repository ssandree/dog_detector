#!/usr/bin/env python3
"""
🎯 AI 시스템 동작 경로 상세 매핑
각 기능별 파일과 함수 실행 순서 가이드
"""

print("=" * 80)
print("🔍 AI 시스템 동작 경로 상세 분석")
print("=" * 80)

# 첨부된 다이어그램의 각 구성요소별 매핑
architecture_mapping = {
    "1. Flutter (프론트)": {
        "구현 상태": "🔄 프론트팀 담당",
        "파일/기능": "-",
        "상세 동작": "사용자 UI, 웹캠 제어, AWS 업로드"
    },
    
    "2. AI API (사진전송)": {
        "구현 상태": "✅ 완료",
        "파일/기능": "api_server.py",
        "상세 동작": """
📍 파일: api_server.py
📍 엔드포인트: @app.post("/api/detect-realtime")
📍 함수: async def detect_dog_realtime(file: UploadFile)

🔄 실행 과정:
1. 프론트에서 이미지 업로드 → file: UploadFile
2. image_bytes = await file.read() → 이미지를 bytes로 변환
3. ai_service.detect_dog_realtime(image_bytes) 호출
4. 응답: {"should_start_recording": True/False}

💡 수정 위치: 녹화 신호 임계값 변경
   line 67: detection_result["should_record"] 
   → detection_result['detected'] and detection_result['confidence'] > 0.7
   여기서 0.7을 조정하면 민감도 변경 가능
        """
    },
    
    "3. AI (객체탐지)": {
        "구현 상태": "✅ 완료", 
        "파일/기능": "ai_service.py + YOLO11 모델",
        "상세 동작": """
📍 파일: ai_service.py
📍 함수: async def detect_dog_realtime(self, frame_data: bytes)

🔄 실행 과정:
1. bytes → OpenCV 이미지 변환
   nparr = np.frombuffer(frame_data, np.uint8)
   frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

2. AI 코어 모듈 호출
   detection_result = self.detector.detect_dog_in_frame(frame)
   
3. 실제 YOLO 추론
   📍 파일: ai_core_module.py  
   📍 클래스: DogDetectionCore
   📍 함수: detect_dog_in_frame(self, frame)
   📍 모델: DogPose_Official/yolo11n_dog24/weights/best.pt

💡 수정 위치: 
   - 모델 경로: ai_service.py line 29
   - 신뢰도 임계값: ai_core_module.py에서 YOLO 결과 필터링
        """
    },
    
    "4. 녹화여부": {
        "구현 상태": "✅ 완료",
        "파일/기능": "should_start_recording 신호",
        "상세 동작": """
📍 파일: ai_service.py
📍 라인: 58-62

🔄 신호 생성 로직:
return {
    "detected": detection_result['detected'],
    "confidence": detection_result['confidence'], 
    "should_record": detection_result['detected'] and detection_result['confidence'] > 0.7,
    "timestamp": detection_result['timestamp']
}

💡 수정 위치: should_record 조건
   - 현재: confidence > 0.7 (70% 이상)
   - 더 민감하게: > 0.5 (50% 이상)  
   - 더 엄격하게: > 0.8 (80% 이상)
        """
    },
    
    "5. AWS (클라우드 저장)": {
        "구현 상태": "🔄 백엔드팀 담당",
        "파일/기능": "-",
        "상세 동작": "프론트에서 녹화된 영상을 AWS S3에 업로드"
    },
    
    "6. AI (영상 분석)": {
        "구현 상태": "✅ 완료",
        "파일/기능": "관절추출 + 감정/슬개골 분석",
        "상세 동작": """
📍 파일: api_server.py
📍 엔드포인트: @app.post("/api/analyze-video-url") 
📍 함수: async def analyze_video_from_url(video_url, dog_id)

🔄 실행 과정:
1. 클라우드에서 영상 다운로드
   response = requests.get(video_url, stream=True)
   
2. 임시 파일로 저장
   tempfile.NamedTemporaryFile(suffix='.mp4')
   
3. AI 분석 실행  
   ai_service.process_recorded_video(temp_path, dog_id)
   
   📍 세부 분석: ai_service.py → process_recorded_video()
   
   a) 영상 → 키포인트 추출
      self.video_processor.process_video_to_json(video_path)
      📍 파일: ai_core_module.py
      📍 클래스: VideoProcessor  
      📍 함수: process_video_to_json()
      
   b) 키포인트 → AI 분석
      self.ai_models.analyze_json_data(json_path)
      📍 파일: ai_core_module.py
      📍 클래스: AIModelInterface
      📍 함수: analyze_json_data()

💡 수정 위치:
   - 키포인트 개수: ai_core_module.py VideoProcessor 클래스
   - 감정 분석: dog_emotion_prediction/emotion_model.py
   - 슬개골 분석: dog_patella_idslocation_detection/patella_model.py
        """
    },
    
    "7. MySQL (DB 저장)": {
        "구현 상태": "🔄 백엔드팀 담당", 
        "파일/기능": "JSON 결과만 제공",
        "상세 동작": """
📍 현재 상태: ai_results/ 폴더에 JSON 파일로만 저장
📍 파일: ai_service.py line 88-92

analysis_filename = f"{result['dog_id']}_analysis.json"
analysis_path = self.results_dir / analysis_filename
with open(analysis_path, 'w', encoding='utf-8') as f:
    json.dump(analysis_result, f, indent=2, ensure_ascii=False)

💡 DB 연동 추가 시 수정 위치:
   - ai_service.py에 save_to_database() 함수 추가
   - process_recorded_video() 함수에서 DB 저장 호출
        """
    }
}

# 상세 출력
for component, details in architecture_mapping.items():
    print(f"\n{component}")
    print("─" * 60)
    print(f"📊 구현 상태: {details['구현 상태']}")
    print(f"📁 파일/기능: {details['파일/기능']}")
    print(f"📋 상세 동작:\n{details['상세 동작']}")
    print()

print("=" * 80)
print("🔧 키포인트 개수 이슈 분석")
print("=" * 80)

keypoint_analysis = """
❓ 문제: 24개 키포인트 설정했는데 20개로 추출된다?

🔍 확인 방법:
1. 실제 학습된 모델 검증
   python -c "from ultralytics import YOLO; model = YOLO('DogPose_Official/yolo11n_dog24/weights/best.pt'); print('키포인트:', model.model.model[-1].kpt_shape)"

2. 실제 추론 결과 확인  
   📍 파일: ai_core_module.py
   📍 함수: VideoProcessor.extract_keypoints_from_frame()
   📍 라인: keypoints = result.keypoints.xy[0] 

💡 수정 위치:
1. ai_core_module.py line 200-220: extract_keypoints_from_frame()
   - 여기서 keypoints.shape 출력해서 실제 개수 확인
   
2. train_official_dog_pose.py: 학습 설정 확인
   - dog-pose.yaml 파일에서 실제 키포인트 수 확인
   
3. 키포인트 매핑 배열 수정
   📍 파일: train_official_dog_pose.py line 150-200
   - keypoint_names 배열을 실제 개수에 맞게 조정

🚨 중요: Dog-Pose 공식 데이터셋이 실제로 20개 키포인트일 수 있음
   - 24개는 일반적인 인간 포즈 추정 기준
   - 강아지 특화 데이터셋은 다를 수 있음
"""

print(keypoint_analysis)

print("=" * 80)
print("🎯 테스트 및 디버깅 가이드")  
print("=" * 80)

debug_guide = """
🧪 각 단계별 테스트 방법:

1️⃣ 실시간 탐지 테스트
   python test_api.py  # API 서버 실행 후
   
2️⃣ 키포인트 개수 확인
   📍 파일: ai_core_module.py
   📍 수정: extract_keypoints_from_frame() 함수에 print 추가
   
   def extract_keypoints_from_frame(self, frame):
       results = self.model(frame)
       for result in results:
           if result.keypoints is not None:
               keypoints = result.keypoints.xy[0]
               print(f"🔍 키포인트 shape: {keypoints.shape}")  # 여기 추가
               
3️⃣ 영상 분석 전체 플로우 테스트
   📍 파일: ai_service.py  
   📍 함수: test_ai_service() 실행

4️⃣ 신뢰도 임계값 조정
   📍 파일: ai_service.py line 60
   confidence > 0.7 → 원하는 값으로 변경

🔧 주요 수정 포인트:
- 키포인트 개수: ai_core_module.py VideoProcessor
- 탐지 민감도: ai_service.py confidence 임계값  
- 모델 경로: ai_service.py line 29
- 분석 결과 형식: ai_core_module.py AIModelInterface
"""

print(debug_guide)

print("✅ 분석 완료!")