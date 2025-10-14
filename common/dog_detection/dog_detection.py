#!/usr/bin/env python3
"""
강아지 탐지 모델 - YOLO11 기반
"""

import cv2
import numpy as np
from ultralytics import YOLO
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from datetime import datetime

class DogDetector:
    """YOLO11 기반 강아지 탐지 및 키포인트 추출"""
    
    def __init__(self, model_path: str):
        """
        초기화
        
        Args:
            model_path: YOLO11 모델 파일 경로
        """
        if not Path(model_path).exists():
            raise FileNotFoundError(f"모델 파일을 찾을 수 없습니다: {model_path}")
        
        self.model = YOLO(model_path)
        self.detection_threshold = 0.5
        
        # 20개 키포인트 매핑
        self.keypoint_mapping = {
            0: "left_f_wrist", 1: "left_f_ankle", 2: "left_f_shoulder",
            3: "left_b_wrist", 4: "left_b_ankle", 5: "left_b_shoulder", 
            6: "right_f_wrist", 7: "right_f_ankle", 8: "right_f_shoulder",
            9: "right_b_wrist", 10: "right_b_ankle", 11: "right_b_shoulder",
            12: "tail_s", 13: "tail_e", 14: "left_mid_ear", 15: "right_mid_ear",
            16: "nose", 17: "mouth", 18: "left_edge_ear", 19: "right_edge_ear"
        }
    
    def detect(self, image, conf_threshold):
        """
        이미지에서 강아지 탐지 및 키포인트 추출
        
        Args:
            image: 입력 이미지 (OpenCV 형식)
            conf_threshold: 신뢰도 임계값
            
        Returns:
            탐지 결과 딕셔너리
        """
        if conf_threshold is None:
            conf_threshold = self.detection_threshold
        
        # YOLO 추론
        results = self.model(image, conf=conf_threshold, imgsz=640, verbose=False)
        
        detection_result = {
            'detected': False,
            'confidence': 0.0,
            'bbox': None,
            'keypoints': {},
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
                keypoint_name = self.keypoint_mapping.get(i, f'point_{i}')
                processed_keypoints[keypoint_name] = {
                    'x': float(x),
                    'y': float(y),
                    'confidence': float(conf)
                }
        
        return processed_keypoints
    
    def batch_detect(self, images, conf_threshold):
        """여러 이미지 배치 처리"""
        results = []
        for image in images:
            result = self.detect(image, conf_threshold)
            results.append(result)
        return results
    
    def get_keypoint_count(self, detection_result: Dict) -> int:
        """검출된 키포인트 개수 반환"""
        return len(detection_result.get('keypoints', {}))
    
    def is_good_detection(self, detection_result: Dict) -> bool:
        """탐지 품질 판단 (녹화 시작 기준)"""
        return (detection_result['detected'] and 
                detection_result['confidence'] > 0.7 and
                self.get_keypoint_count(detection_result) >= 8)