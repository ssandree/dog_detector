#!/usr/bin/env python3
"""
AI 서비스 모듈 - FastAPI 백엔드 연동용
강아지 탐지, 영상 처리, 감정/슬개골 분석 API
"""

import os
import sys
from pathlib import Path
from typing import Dict, Optional
# AI 코어 모듈 import를 위한 경로 추가
current_dir = Path(__file__).parent
parent_dir = current_dir.parent
sys.path.append(str(parent_dir))

from ai_core_module import DogDetectionCore, VideoProcessor, AIModelInterface
import cv2
import numpy as np
from typing import Dict, Optional
from datetime import datetime
import json
import asyncio

class AIService:
    """AI 서비스 클래스 - 백엔드용"""
    
    def __init__(self):
        """초기화"""
        # 학습된 YOLO11 Dog-Pose 모델 경로 수정
        full_model_path = Path(__file__).parent / "DogPose_Official/yolo11n_dog24/weights/best.pt"
        
        if not full_model_path.exists():
            raise FileNotFoundError(f"AI 모델을 찾을 수 없습니다: {full_model_path}")
        
        self.detector = DogDetectionCore(str(full_model_path))
        self.video_processor = VideoProcessor(str(full_model_path))
        self.ai_models = AIModelInterface()
        
        # 결과 저장 디렉토리
        self.results_dir = Path("ai_results")
        self.results_dir.mkdir(exist_ok=True)
        
        print("✅ AI 서비스 초기화 완료")
    
    async def detect_dog_realtime(self, frame_data: bytes) -> Dict:
        """실시간 강아지 탐지"""
        try:
            # bytes 데이터를 OpenCV 이미지로 변환
            nparr = np.frombuffer(frame_data, np.uint8)
            frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if frame is None:
                return {"error": "이미지 디코딩 실패"}
            
            # 강아지 탐지
            detection_result = self.detector.detect_dog_in_frame(frame)
            
            return {
                "detected": detection_result['detected'],
                "confidence": detection_result['confidence'],
                "should_record": detection_result['detected'] and detection_result['confidence'] > 0.7,
                "timestamp": detection_result['timestamp']
            }
            
        except Exception as e:
            return {"error": f"탐지 실패: {str(e)}"}
    
    async def process_recorded_video(self, video_path: str, dog_id: Optional[str] = None) -> Dict:
        """녹화된 영상 처리"""
        try:
            if not os.path.exists(video_path):
                return {"error": f"영상 파일을 찾을 수 없습니다: {video_path}"}
            
            # 영상 → JSON 변환
            result = self.video_processor.process_video_to_json(video_path, dog_id)
            
            if result['success']:
                # AI 모델 분석
                analysis_result = self.ai_models.analyze_json_data(result['json_path'])
                
                # 결과 저장
                analysis_filename = f"{result['dog_id']}_analysis.json"
                analysis_path = self.results_dir / analysis_filename
                
                with open(analysis_path, 'w', encoding='utf-8') as f:
                    json.dump(analysis_result, f, indent=2, ensure_ascii=False)
                
                return {
                    "success": True,
                    "dog_id": result['dog_id'],
                    "keypoints_json": result['json_path'],
                    "analysis_json": str(analysis_path),
                    "processed_frames": result['processed_frames'],
                    "emotion": analysis_result['emotion_analysis']['primary_emotion'],
                    "emotion_confidence": analysis_result['emotion_analysis']['confidence'],
                    "patella_risk": analysis_result['patella_analysis']['risk_level'],
                    "overall_health": analysis_result['overall_health']['status']
                }
            else:
                return {"error": "영상 처리 실패"}
                
        except Exception as e:
            return {"error": f"영상 처리 중 오류: {str(e)}"}
    
    async def get_analysis_result(self, dog_id: str) -> Dict:
        """분석 결과 조회"""
        try:
            analysis_file = self.results_dir / f"{dog_id}_analysis.json"
            
            if not analysis_file.exists():
                return {"error": f"분석 결과를 찾을 수 없습니다: {dog_id}"}
            
            with open(analysis_file, 'r', encoding='utf-8') as f:
                analysis_data = json.load(f)
            
            return {
                "success": True,
                "dog_id": dog_id,
                "analysis": analysis_data
            }
            
        except Exception as e:
            return {"error": f"결과 조회 실패: {str(e)}"}
    
    def get_health_summary(self, dog_id: str) -> Dict:
        """건강 상태 요약"""
        try:
            analysis_file = self.results_dir / f"{dog_id}_analysis.json"
            
            if not analysis_file.exists():
                return {"error": "분석 데이터 없음"}
            
            with open(analysis_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # 요약 정보 추출
            emotion = data['emotion_analysis']
            patella = data['patella_analysis']
            overall = data['overall_health']
            
            return {
                "dog_id": dog_id,
                "overall_status": overall['status'],
                "overall_score": overall['score'],
                "emotion": {
                    "primary": emotion['primary_emotion'],
                    "confidence": emotion['confidence']
                },
                "patella": {
                    "risk_level": patella['risk_level'],
                    "left_leg_risk": patella['details']['left_leg']['risk'],
                    "right_leg_risk": patella['details']['right_leg']['risk']
                },
                "recommendations": patella['recommendations'],
                "last_updated": data['processed_at']
            }
            
        except Exception as e:
            return {"error": f"요약 생성 실패: {str(e)}"}

# 글로벌 AI 서비스 인스턴스
ai_service = None

def get_ai_service() -> AIService:
    """AI 서비스 싱글톤 인스턴스 반환"""
    global ai_service
    if ai_service is None:
        ai_service = AIService()
    return ai_service

# 테스트 함수
async def test_ai_service():
    """AI 서비스 테스트"""
    print("🧪 AI 서비스 테스트 시작")
    
    try:
        service = get_ai_service()
        print("✅ AI 서비스 로드 성공")
        
        # 테스트 이미지로 탐지 테스트
        test_image_path = r"D:\반려동물 구분을 위한 동물 영상\Training\DOG\raw"
        dataset_path = Path(test_image_path)
        
        if dataset_path.exists():
            image_files = []
            for ext in ['*.jpg', '*.jpeg', '*.png']:
                image_files.extend(list(dataset_path.rglob(ext)))
            
            if image_files:
                # 이미지를 bytes로 변환
                test_image = cv2.imread(str(image_files[0]))
                _, img_encoded = cv2.imencode('.jpg', test_image)
                img_bytes = img_encoded.tobytes()
                
                # 탐지 테스트
                detection_result = await service.detect_dog_realtime(img_bytes)
                print(f"🔍 탐지 테스트: {detection_result}")
        
        print("✅ AI 서비스 테스트 완료")
        
    except Exception as e:
        print(f"❌ AI 서비스 테스트 실패: {e}")

if __name__ == "__main__":
    import asyncio
    asyncio.run(test_ai_service())