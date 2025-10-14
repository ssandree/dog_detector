#!/usr/bin/env python3
"""
AI 서비스 모듈 - FastAPI 백엔드 연동용
"""
from pathlib import Path
from datetime import datetime
from typing import Dict, Optional
import json
import asyncio

# AI 코어 모듈 import
from ai_core_module import DogDetectionCore, VideoProcessor, AIModelInterface

class AIService:
    """AI 서비스 클래스 - 백엔드용"""
    def __init__(self, model_path: str = "DogPose_Official/yolo11n_dog24_v242/weights/best.pt"):
        self.detector = DogDetectionCore(model_path)
        self.video_processor = VideoProcessor(self.detector)
        self.analyzer = AIModelInterface() # 모든 분석 모델을 포함
        
        self.results_dir = Path("ai_results")
        self.results_dir.mkdir(exist_ok=True)
        print("✅ AI 서비스 초기화 완료")
    
    def _find_corresponding_audio(self, video_path: str) -> str:
        # ------------------------------------------------------------------
        ### >>> TODO: 사용자 구현 필요 <<< ###
        # 실제 영상 파일에 매칭되는 음성 파일을 찾는 규칙을 구현해야 합니다.
        # 예: 'video/dog1.mp4' -> 'audio/dog1.wav'
        # ------------------------------------------------------------------
        audio_path = Path(video_path).with_suffix('.wav')
        if not audio_path.exists():
            # 임시로 빈 음성 파일을 생성하거나 에러 처리
            raise FileNotFoundError(f"음성 파일을 찾을 수 없습니다: {audio_path}")
        return str(audio_path)

    async def process_recorded_video(self, video_path: str, dog_id: Optional[str] = None) -> Dict:
        """녹화된 영상과 음성을 종합적으로 처리하고 분석"""
        try:
            if not dog_id:
                dog_id = f"dog_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

            # 1. 영상에서 관절 데이터 JSON 추출
            keypoints_result = self.video_processor.process_video_to_json(video_path, dog_id)
            if not keypoints_result.get("success"):
                return {"error": "관절 데이터 추출 실패"}
            
            keypoint_json_path = keypoints_result["json_path"]
            
            # 2. 해당하는 음성 파일 찾기
            audio_path = self._find_corresponding_audio(video_path)

            # 3. AI 종합 분석 (감정, 슬개골 등)
            emotion_result = self.analyzer.analyze_emotion_multimodal(keypoint_json_path, audio_path)
            patella_result = self.analyzer.analyze_patella(keypoint_json_path)

            # 4. 최종 결과 취합 및 저장
            final_analysis = {
                "dog_id": dog_id,
                "emotion_analysis": emotion_result,
                "patella_analysis": patella_result,
                "processed_at": datetime.now().isoformat()
            }
            analysis_path = self.results_dir / f"{dog_id}_analysis.json"
            with open(analysis_path, 'w', encoding='utf-8') as f:
                json.dump(final_analysis, f, indent=2, ensure_ascii=False)
            
            return {"success": True, "dog_id": dog_id, "analysis": final_analysis}

        except Exception as e:
            return {"error": f"영상 처리 중 오류: {str(e)}"}
    
    # ... (detect_dog_realtime, get_analysis_result 등 다른 메서드들) ...

# --- 싱글톤 인스턴스 관리 ---
_ai_service_instance = None
def get_ai_service() -> AIService:
    global _ai_service_instance
    if _ai_service_instance is None:
        # ------------------------------------------------------------------
        ### >>> TODO: 사용자 구현 필요 <<< ###
        # YOLO 관절 추출 모델의 최종 경로를 지정해야 합니다.
        # ------------------------------------------------------------------
        model_path = "DogPose_Official/yolo11n_dog24/weights/best.pt"
        _ai_service_instance = AIService(model_path)
    return _ai_service_instance