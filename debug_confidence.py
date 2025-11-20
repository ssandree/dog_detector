#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
from pathlib import Path
import tempfile
import shutil

# API 서비스 모듈 import
sys.path.append(str(Path(__file__).parent / "API"))
from API.ai_service import get_ai_service

def debug_confidence_zero():
    """신뢰도 0 문제 디버깅"""
    print("🔍 신뢰도 0 문제 디버깅 시작...")
    
    # 환경 설정
    os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"
    os.environ["PYTHONIOENCODING"] = "utf-8"
    
    # AI 서비스 초기화
    print("🔧 AI 서비스 초기화 중...")
    ai_service = get_ai_service()
    
    # 문제가 있는 비디오 선택 (신뢰도 0인 비디오들)
    problem_videos = [
        "test_data/편안_안정/video_04.mp4",  # 신뢰도 0.00
        "test_data/편안_안정/video_06.mp4",  # 신뢰도 0.00 
        "test_data/편안_안정/video_01.mp4"   # 신뢰도 1.00 (정상 비교용)
    ]
    
    for video_path in problem_videos:
        if not os.path.exists(video_path):
            print(f"❌ 파일 없음: {video_path}")
            continue
            
        print(f"\n{'='*60}")
        print(f"🎬 분석 대상: {Path(video_path).name}")
        print(f"{'='*60}")
        
        # 임시 파일 복사 (한글 경로 문제 해결)
        with tempfile.NamedTemporaryFile(delete=False, suffix='.mp4') as temp_file:
            temp_path = temp_file.name
            shutil.copy2(video_path, temp_path)
            print(f"📁 임시 파일: {temp_path}")
        
        try:
            # AI 코어 모듈에 직접 접근하여 디버깅
            ai_core = ai_service.analyzer
            
            # VideoProcessor로 포즈 분석만 먼저 수행  
            from ai_core_module import DogDetectionCore, VideoProcessor
            
            detector = DogDetectionCore()
            processor = VideoProcessor(detector)
            
            # 포즈 데이터 추출 (비디오별 고유 ID 사용)
            video_name = Path(video_path).stem
            unique_dog_id = f"debug_{video_name}"
            print(f"🎯 포즈 분석 수행 중... (ID: {unique_dog_id})")
            process_result = processor.process_mp4_complete(temp_path, unique_dog_id)
            
            if not process_result["success"]:
                print(f"❌ 포즈 분석 실패: {process_result}")
                continue
                
            keypoint_json_path = process_result["pose_analysis"].get("json_path")
            print(f"✅ 키포인트 JSON: {keypoint_json_path}")
            
            if not keypoint_json_path:
                print("❌ 키포인트 JSON 생성 실패")
                continue
            
            # 디버깅 모드로 감정 예측 실행
            print("\n🔍 감정 예측 디버깅 시작...")
            debug_result = ai_core._predict_emotion_from_video(
                keypoint_json_path, 
                use_video_level_avg=True, 
                debug=True
            )
            
            print(f"\n📊 최종 결과:")
            print(f"   감정 확률: {debug_result}")
            max_emotion = max(debug_result.keys(), key=lambda x: debug_result[x])
            print(f"   최고 확률 감정: {max_emotion} ({debug_result[max_emotion]:.3f})")
            
        except Exception as e:
            print(f"💥 디버깅 중 오류: {e}")
            import traceback
            traceback.print_exc()
        
        finally:
            # 임시 파일 삭제
            try:
                os.unlink(temp_path)
            except:
                pass
    
    print(f"\n🏁 디버깅 완료!")

if __name__ == "__main__":
    debug_confidence_zero()