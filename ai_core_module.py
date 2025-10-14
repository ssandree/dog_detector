#!/usr/bin/env python3
"""
AI 코어 모듈: 강아지 탐지 및 관절 추출
프론트, 백엔드와 연동하여 실시간 강아지 탐지 및 영상 처리
"""

import cv2
import numpy as np
import json
import os
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Tuple
from ultralytics import YOLO
import threading
import time

class DogDetectionCore:
    """강아지 탐지 코어 모듈"""
    
    def __init__(self, model_path: str):
        """초기화"""
        self.model = YOLO(model_path)
        self.is_recording = False
        self.detection_threshold = 0.5
        
        # 키포인트 매핑 - Dog-Pose 공식 데이터셋 (완전한 24개 키포인트)
        self.keypoint_mapping = {
            # 머리 부분 (0-4)
            0: "nose",              # 코
            1: "left_eye",          # 왼쪽 눈
            2: "right_eye",         # 오른쪽 눈
            3: "left_ear",          # 왼쪽 귀
            4: "right_ear",         # 오른쪽 귀
            
            # 앞다리 (5-10)
            5: "left_shoulder",     # 왼쪽 어깨
            6: "right_shoulder",    # 오른쪽 어깨
            7: "left_elbow",        # 왼쪽 팔꿈치
            8: "right_elbow",       # 오른쪽 팔꿈치
            9: "left_front_paw",    # 왼쪽 앞발
            10: "right_front_paw",  # 오른쪽 앞발
            
            # 뒷다리 (11-16)
            11: "left_hip",         # 왼쪽 엉덩이
            12: "right_hip",        # 오른쪽 엉덩이
            13: "left_knee",        # 왼쪽 무릎
            14: "right_knee",       # 오른쪽 무릎
            15: "left_back_paw",    # 왼쪽 뒷발
            16: "right_back_paw",   # 오른쪽 뒷발
            
            # 꼬리 (17-19)
            17: "tail_base",        # 꼬리 시작
            18: "tail_mid",         # 꼬리 중간
            19: "tail_end",         # 꼬리 끝
            
            # 몸체 추가 부위 (20-23) - 기존에 누락됨!
            20: "neck",             # 목
            21: "chest",            # 가슴
            22: "withers",          # 어깨 위
            23: "back_center"       # 등 중앙
        }
    
    def detect_dog_in_frame(self, frame: np.ndarray) -> Dict:
        """단일 프레임에서 강아지 탐지"""
        results = self.model(frame, conf=self.detection_threshold, verbose=False)
        
        detection_result = {
            'detected': False,
            'confidence': 0.0,
            'bbox': None,
            'keypoints': None,
            'timestamp': datetime.now().isoformat()
        }
        
        if results and len(results) > 0:
            result = results[0]
            
            # 바운딩 박스 확인
            if result.boxes is not None and len(result.boxes) > 0:
                box = result.boxes[0]
                detection_result['detected'] = True
                detection_result['confidence'] = float(box.conf[0])
                detection_result['bbox'] = box.xyxy[0].cpu().numpy().tolist()
                
                # 키포인트 추출
                if result.keypoints is not None and len(result.keypoints) > 0:
                    keypoints = result.keypoints.data[0].cpu().numpy()
                    detection_result['keypoints'] = self._process_keypoints(keypoints)
        
        return detection_result
    
    def _process_keypoints(self, keypoints: np.ndarray, conf_threshold: float = 0.3) -> Dict:
        """키포인트 처리 및 필터링"""
        processed_keypoints = {}
        
        for i, (x, y, conf) in enumerate(keypoints):
            if conf > conf_threshold and x > 0 and y > 0:
                processed_keypoints[self.keypoint_mapping[i]] = {
                    'x': float(x),
                    'y': float(y),
                    'confidence': float(conf)
                }
        
        return processed_keypoints
    
    def should_start_recording(self, frame: np.ndarray) -> bool:
        """녹화 시작 여부 판단"""
        detection = self.detect_dog_in_frame(frame)
        return detection['detected'] and detection['confidence'] > self.detection_threshold

class VideoProcessor:
    """영상 처리 모듈"""
    
    def __init__(self, model_path: str):
        """초기화"""
        self.detector = DogDetectionCore(model_path)
        self.output_dir = Path("processed_videos")
        self.output_dir.mkdir(exist_ok=True)
    
    def process_video_to_json(self, video_path: str, dog_id: Optional[str] = None) -> Dict:
        """영상을 처리하여 JSON 데이터 생성"""
        if dog_id is None:
            dog_id = f"dog_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        print(f"🎬 영상 처리 시작: {video_path}")
        
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            raise ValueError(f"영상을 열 수 없습니다: {video_path}")
        
        # 영상 정보
        fps = int(cap.get(cv2.CAP_PROP_FPS))
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        duration = total_frames / fps if fps > 0 else 0
        
        print(f"📊 영상 정보: {total_frames}프레임, {fps}FPS, {duration:.1f}초")
        
        # JSON 데이터 구조
        json_data = {
            dog_id: {
                "metadata": {
                    "video_path": video_path,
                    "fps": fps,
                    "total_frames": total_frames,
                    "duration": duration,
                    "processed_at": datetime.now().isoformat()
                },
                "frames": {}
            }
        }
        
        frame_count = 0
        processed_frames = 0
        
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            
            # 프레임별 처리 (예: 매 5프레임마다)
            if frame_count % 5 == 0:
                detection = self.detector.detect_dog_in_frame(frame)
                
                if detection['detected'] and detection['keypoints']:
                    frame_key = f"frame_{frame_count:06d}"
                    json_data[dog_id]["frames"][frame_key] = {
                        "timestamp": frame_count / fps if fps > 0 else 0,
                        "confidence": detection['confidence'],
                        "bbox": detection['bbox'],
                        "keypoints": detection['keypoints']
                    }
                    processed_frames += 1
            
            frame_count += 1
            
            # 진행상황 출력
            if frame_count % 100 == 0:
                progress = (frame_count / total_frames) * 100
                print(f"⏳ 처리 진행률: {progress:.1f}% ({processed_frames}개 프레임 추출)")
        
        cap.release()
        
        print(f"✅ 영상 처리 완료: {processed_frames}개 프레임에서 관절 데이터 추출")
        
        # JSON 파일 저장
        json_filename = f"{dog_id}_keypoints.json"
        json_path = self.output_dir / json_filename
        
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, indent=2, ensure_ascii=False)
        
        print(f"💾 JSON 저장: {json_path}")
        
        return {
            "json_path": str(json_path),
            "dog_id": dog_id,
            "processed_frames": processed_frames,
            "total_frames": total_frames,
            "success": True
        }

class AIModelInterface:
    """AI 모델 인터페이스 (감정 + 슬개골)"""
    
    def __init__(self):
        """초기화"""
        self.emotion_model = None  # 감정 모델 (추후 구현)
        self.patella_model = None  # 슬개골 모델 (추후 구현)
    
    def analyze_emotion(self, json_data: Dict) -> Dict:
        """감정 분석"""
        # TODO: 실제 감정 분석 모델 구현
        print("🎭 감정 분석 시작...")
        
        # 임시 분석 결과
        emotion_result = {
            "primary_emotion": "happy",
            "confidence": 0.85,
            "emotions": {
                "happy": 0.85,
                "calm": 0.10,
                "alert": 0.05
            },
            "analysis_timestamp": datetime.now().isoformat()
        }
        
        print(f"😊 감정 분석 결과: {emotion_result['primary_emotion']} ({emotion_result['confidence']:.2f})")
        return emotion_result
    
    def analyze_patella(self, json_data: Dict) -> Dict:
        """슬개골 탈구 분석"""
        # TODO: 실제 슬개골 분석 모델 구현
        print("🦴 슬개골 분석 시작...")
        
        # 임시 분석 결과
        patella_result = {
            "risk_level": "low",
            "confidence": 0.92,
            "details": {
                "left_leg": {"risk": 0.15, "grade": 0},
                "right_leg": {"risk": 0.08, "grade": 0}
            },
            "recommendations": ["정기적인 운동", "체중 관리"],
            "analysis_timestamp": datetime.now().isoformat()
        }
        
        print(f"🏥 슬개골 분석 결과: {patella_result['risk_level']} 위험도")
        return patella_result
    
    def analyze_json_data(self, json_path: str) -> Dict:
        """JSON 데이터 종합 분석"""
        with open(json_path, 'r', encoding='utf-8') as f:
            json_data = json.load(f)
        
        dog_id = list(json_data.keys())[0]
        
        # 감정 및 슬개골 분석
        emotion_result = self.analyze_emotion(json_data)
        patella_result = self.analyze_patella(json_data)
        
        # 종합 결과
        analysis_result = {
            "dog_id": dog_id,
            "emotion_analysis": emotion_result,
            "patella_analysis": patella_result,
            "processed_at": datetime.now().isoformat()
        }
        
        return analysis_result

def main():
    """테스트 실행"""
    print("🤖 AI 코어 모듈 테스트")
    print("=" * 50)
    
    # 모델 로드
    model_path = "DogPose_Official/yolo11n_dog24/weights/best.pt"
    
    if not os.path.exists(model_path):
        print(f"❌ 모델을 찾을 수 없습니다: {model_path}")
        return
    
    # 테스트 시나리오
    print("📋 테스트 시나리오:")
    print("1. 강아지 탐지 테스트")
    print("2. 영상 처리 테스트 (추후)")
    print("3. AI 모델 분석 테스트")
    
    # 1. 강아지 탐지 테스트
    detector = DogDetectionCore(model_path)
    
    # 테스트 이미지로 탐지 테스트
    test_image_path = r"D:\반려동물 구분을 위한 동물 영상\Training\DOG\raw"
    dataset_path = Path(test_image_path)
    
    if dataset_path.exists():
        image_files = []
        for ext in ['*.jpg', '*.jpeg', '*.png']:
            image_files.extend(list(dataset_path.rglob(ext)))
        
        if image_files:
            test_image = cv2.imread(str(image_files[0]))
            detection = detector.detect_dog_in_frame(test_image)
            
            print(f"\n🔍 탐지 결과:")
            print(f"   강아지 탐지: {'✅' if detection['detected'] else '❌'}")
            print(f"   신뢰도: {detection['confidence']:.3f}")
            print(f"   키포인트 수: {len(detection['keypoints']) if detection['keypoints'] else 0}")
    
    # 3. AI 모델 인터페이스 테스트
    ai_interface = AIModelInterface()
    
    # 임시 JSON 데이터 생성
    temp_json = {
        "test_dog": {
            "frames": {
                "frame_000001": {"keypoints": {"nose": {"x": 100, "y": 150, "confidence": 0.9}}}
            }
        }
    }
    
    emotion_result = ai_interface.analyze_emotion(temp_json)
    patella_result = ai_interface.analyze_patella(temp_json)
    
    print(f"\n🎭 감정 분석: {emotion_result['primary_emotion']}")
    print(f"🦴 슬개골 위험도: {patella_result['risk_level']}")
    
    print("\n✅ AI 코어 모듈 테스트 완료!")

if __name__ == "__main__":
    main()