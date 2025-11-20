#!/usr/bin/env python3
"""
AI 서비스 모듈 - FastAPI 백엔드 연동용
수정: ai_core_module.py의 새로운 MP4 처리 기능 적용
"""
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, Optional
import json
import asyncio
import numpy as np
import cv2

# 상위 디렉토리의 ai_core_module import
sys.path.append(str(Path(__file__).parent.parent))
from ai_core_module import DogDetectionCore, VideoProcessor, AIModelInterface

class AIService:
    """AI 서비스 클래스 - 백엔드용 (MP4 완전 처리 지원)"""
    def __init__(self, model_path: str = "../DogPose_Official/yolo11n_dog24_v242/weights/best.pt"):
        # 상대 경로 수정
        base_dir = Path(__file__).parent.parent
        full_model_path = base_dir / model_path.lstrip("../")
        
        self.detector = DogDetectionCore(str(full_model_path))
        self.video_processor = VideoProcessor(self.detector)
        self.analyzer = AIModelInterface()  # 모든 분석 모델을 포함
        
        self.results_dir = Path("ai_results")
        self.results_dir.mkdir(exist_ok=True)
        print("✅ AI 서비스 초기화 완료")
    
    async def detect_dog_realtime(self, image_bytes: bytes) -> Dict:
        """실시간 강아지 탐지 (단일 이미지)"""
        try:
            # bytes -> OpenCV 이미지로 변환
            nparr = np.frombuffer(image_bytes, np.uint8)
            frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if frame is None:
                return {"error": "이미지 디코딩 실패"}
            
            # 강아지 탐지 실행
            detection = self.detector.detect_dog_in_frame(frame)
            
            # 녹화 시작 조건 (신뢰도 0.7 이상)
            should_record = detection['detected'] and detection['confidence'] > 0.7
            
            return {
                "detected": detection['detected'],
                "confidence": detection['confidence'],
                "bbox": detection['bbox'],
                "keypoints": detection['keypoints'],
                "should_record": should_record,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            return {"error": f"탐지 실패: {str(e)}"}

    async def process_mp4_complete(self, mp4_path: str) -> Dict:
        """MP4 파일 완전 처리 (음성 분리 + 포즈 분석 + 감정 분석)"""
        try:
            dog_id = f"dog_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

            # ai_core_module의 새로운 완전 분석 기능 사용
            print(f"🎬 MP4 완전 분석 시작: {mp4_path}")
            analysis_result = self.analyzer.analyze_mp4_complete(mp4_path, dog_id)
            
            if not analysis_result["success"]:
                return {
                    "error": "MP4 분석 실패",
                    "details": analysis_result.get("error", "알 수 없는 오류")
                }
            
            # 기존 API 형식에 맞게 결과 재구성
            emotion_analysis = analysis_result["emotion_analysis"]
            
            # 슬개골 분석 (ai_core_module에서 이미 수행됨)
            patella_result = analysis_result.get("patella_analysis", {
                "status": "unknown",
                "confidence": 0.0,
                "probabilities": {},
                "details": "슬개골 분석 결과 없음"
            })
            
            # API 응답 형식으로 재구성
            final_analysis = {
                "emotion_analysis": {
                    "primary_emotion": emotion_analysis["primary_emotion"],
                    "confidence": emotion_analysis["confidence"],
                    "analysis_mode": emotion_analysis["analysis_mode"],
                    "emotion_probabilities": emotion_analysis["details"],
                    "audio_available": emotion_analysis["audio_arousal_valence"].get("audio_available", False),
                    "audio_info": emotion_analysis["audio_arousal_valence"],
                    "arousal": emotion_analysis.get("arousal"),
                    "valence": emotion_analysis.get("valence"),
                    "arousal_distribution": emotion_analysis.get("arousal_distribution", {}),
                    "valence_distribution": emotion_analysis.get("valence_distribution", {})
                },
                "patella_analysis": patella_result,
                "processing_info": analysis_result["processing"],
                "files_generated": analysis_result["files_generated"],
                "processed_at": datetime.now().isoformat()
            }
            
            # 결과 저장
            analysis_path = self.results_dir / f"{dog_id}_analysis.json"
            with open(analysis_path, 'w', encoding='utf-8') as f:
                json.dump(final_analysis, f, indent=2, ensure_ascii=False, default=str)
            
            return {
                "success": True, 
                "analysis": final_analysis,
                "message": f"MP4 분석 완료 ({emotion_analysis['analysis_mode']} 모드)"
            }

        except Exception as e:
            return {"error": f"MP4 처리 중 오류: {str(e)}"}

    async def process_recorded_video(self, video_path: str) -> Dict:
        """기존 API 호환성을 위한 래퍼 함수"""
        return await self.process_mp4_complete(video_path)

    async def get_analysis_result(self, dog_id: str) -> Dict:
        """분석 결과 조회"""
        try:
            analysis_path = self.results_dir / f"{dog_id}_analysis.json"
            
            if not analysis_path.exists():
                return {"error": f"분석 결과를 찾을 수 없습니다: {dog_id}"}
            
            with open(analysis_path, 'r', encoding='utf-8') as f:
                result = json.load(f)
            
            return {"success": True, "analysis": result}
            
        except Exception as e:
            return {"error": f"결과 조회 실패: {str(e)}"}

    def get_health_summary(self, dog_id: str) -> Dict:
        """건강 상태 요약"""
        try:
            analysis_path = self.results_dir / f"{dog_id}_analysis.json"
            
            if not analysis_path.exists():
                return {"error": f"분석 결과를 찾을 수 없습니다: {dog_id}"}
            
            with open(analysis_path, 'r', encoding='utf-8') as f:
                analysis = json.load(f)
            
            emotion = analysis["emotion_analysis"]
            patella = analysis["patella_analysis"]
            
            # 건강 요약 생성
            summary = {
                "dog_id": dog_id,
                "overall_status": "양호",  # 기본값
                "emotion_status": {
                    "current_emotion": emotion["primary_emotion"],
                    "confidence": emotion["confidence"],
                    "analysis_method": emotion["analysis_mode"]
                },
                "physical_status": {
                    "patella_risk": patella.get("risk_level", "low"),
                    "confidence": patella.get("confidence", 0.9)
                },
                "recommendations": [],
                "last_updated": analysis["processed_at"]
            }
            
            # 감정 기반 권장사항
            if emotion["primary_emotion"] in ["불안/슬픔", "공포"]:
                summary["recommendations"].append("스트레스 관리가 필요할 수 있습니다")
                summary["overall_status"] = "관찰 필요"
            elif emotion["primary_emotion"] == "공격성":
                summary["recommendations"].append("행동 교정 훈련을 고려해보세요")
                summary["overall_status"] = "주의 필요"
            else:
                summary["recommendations"].append("현재 안정적인 상태입니다")
            
            return {"success": True, "summary": summary}
            
        except Exception as e:
            return {"error": f"요약 생성 실패: {str(e)}"}


# --- 싱글톤 인스턴스 관리 ---
_ai_service_instance = None

def get_ai_service() -> AIService:
    global _ai_service_instance
    if _ai_service_instance is None:
        # 모델 경로 수정 (상대 경로)
        model_path = "../DogPose_Official/yolo11n_dog24_v242/weights/best.pt"
        _ai_service_instance = AIService(model_path)
    return _ai_service_instance