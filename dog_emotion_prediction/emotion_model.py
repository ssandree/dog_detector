#!/usr/bin/env python3
"""
강아지 감정 예측 모델
- VGGish를 활용한 오디오 특성 추출
- STGCN을 활용한 동작 패턴 분석
- 멀티모달 감정 분류
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.transforms as transforms
import numpy as np
import cv2
from typing import Dict, List, Tuple, Optional
import os
from pathlib import Path

# VGGish 모듈 import (사전학습 모델 사용)
VGGISH_AVAILABLE = False
try:
    from torchvggish import vggish, vggish_input
    VGGISH_AVAILABLE = True
    print("✅ torchvggish 사용 (사전학습된 VGGish)")
except ImportError:
    print("⚠️ torchvggish 미설치: 더미 모델 사용")
    print("💡 사전학습된 VGGish 사용을 위해 'pip install torchvggish' 실행")

try:
    import librosa
    LIBROSA_AVAILABLE = True
except ImportError:
    LIBROSA_AVAILABLE = False
    print("⚠️ librosa 미설치: pip install librosa로 설치하세요.")

# VGGish는 별도 모듈에서 import

class AudioFeatureExtractor:
    """
    오디오 특성 추출기
    VGGish 모델을 사용하여 오디오에서 특성 추출
    """
    
    def __init__(self, model_path: Optional[str] = None):
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        
        try:
            # vggish_loader에서 모델 로드
            from .vggish_loader import get_vggish_instance
            self.vggish, self.use_pretrained, self.preprocess_func = get_vggish_instance()
            
            if torch.cuda.is_available() and self.device != 'cpu':
                self.vggish = self.vggish.to(self.device)
                
            print(f"✅ VGGish 모델 로드 완료 (사전학습: {'Yes' if self.use_pretrained else 'No'})")
        except ImportError:
            # 폴백: 더미 모델
            print("⚠️ VGGish 로더 없음: 더미 모델 사용")
            self.vggish = None
            self.use_pretrained = False
            self.preprocess_func = None
    
    def extract_features(self, audio_path: str) -> np.ndarray:
        """
        오디오 특성 추출
        Args:
            audio_path: 오디오 파일 경로
        Returns:
            features: 추출된 오디오 특성 벡터
        """
        try:
            from .vggish_loader import extract_audio_features
            device_str = str(self.device)
            return extract_audio_features(audio_path, self.vggish, self.preprocess_func, device_str)
        except ImportError:
            print("❌ VGGish 로더 import 실패: 0 벡터 반환")
            return np.zeros(128)
        except Exception as e:
            print(f"❌ 오디오 특성 추출 오류: {e}")
            return np.zeros(128)

class DogEmotionPredictor:
    """
    강아지 감정 예측기
    VGGish (오디오) + 키포인트 (비전) 멀티모달 분석
    """
    
    def __init__(self, vggish_model_path: Optional[str] = None):
        print("🐕 강아지 감정 예측기 초기화")
        
        # 감정 클래스 정의
        self.emotion_classes = {
            0: "happy",      # 기쁨
            1: "excited",    # 흥분
            2: "calm",       # 차분
            3: "anxious",    # 불안
            4: "aggressive", # 공격적
            5: "fearful",    # 두려움
            6: "playful",    # 장난기
            7: "tired"       # 피곤
        }
        
        # 감정 클래스 (한국어)
        self.emotion_classes_kr = {
            0: "기쁨",
            1: "흥분",
            2: "차분함",
            3: "불안함", 
            4: "공격적",
            5: "두려움",
            6: "장난기",
            7: "피곤함"
        }
        
        # 오디오 특성 추출기
        self.audio_extractor = AudioFeatureExtractor(vggish_model_path)
        
        # 감정 분류 모델 (간단한 MLP)
        self.emotion_classifier = self._build_emotion_classifier()
        
        print(f"✅ 감정 클래스: {len(self.emotion_classes)}개")
        print(f"🎵 VGGish 오디오 분석 준비 완료")
    
    def _build_emotion_classifier(self) -> nn.Module:
        """감정 분류 모델 구축"""
        model = nn.Sequential(
            # 오디오 특성 (128) + 키포인트 특성 (24*2=48) = 176
            nn.Linear(176, 256),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(256, 128),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(128, 64),
            nn.ReLU(),
            nn.Linear(64, len(self.emotion_classes))
        )
        
        device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        model.to(device)
        
        return model
    
    def extract_keypoint_features(self, keypoints: Dict) -> np.ndarray:
        """
        키포인트에서 감정 관련 특성 추출
        Args:
            keypoints: 강아지 키포인트 딕셔너리
        Returns:
            features: 키포인트 기반 특성 벡터
        """
        features = []
        
        # 24개 키포인트의 x, y 좌표
        for i in range(24):
            kpt_name = f"kpt_{i}"  # 키포인트 이름은 실제 구조에 맞게 수정
            
            if kpt_name in keypoints and keypoints[kpt_name]['confidence'] > 0.3:
                features.extend([
                    keypoints[kpt_name]['x'],
                    keypoints[kpt_name]['y']
                ])
            else:
                features.extend([0.0, 0.0])  # 감지되지 않은 경우 0으로 채움
        
        return np.array(features, dtype=np.float32)
    
    def predict_emotion(self, 
                       audio_path: Optional[str] = None, 
                       keypoints: Optional[Dict] = None) -> Dict:
        """
        멀티모달 감정 예측
        Args:
            audio_path: 오디오 파일 경로
            keypoints: 강아지 키포인트 데이터
        Returns:
            prediction: 감정 예측 결과
        """
        features = []
        
        # 1. 오디오 특성 추출
        if audio_path and os.path.exists(audio_path):
            audio_features = self.audio_extractor.extract_features(audio_path)
            features.append(audio_features.flatten())
            print(f"🎵 오디오 특성 추출 완료: {audio_features.shape}")
        else:
            # 오디오 없는 경우 0으로 채움
            features.append(np.zeros(128))
            print("🔇 오디오 없음: 기본값 사용")
        
        # 2. 키포인트 특성 추출  
        if keypoints:
            keypoint_features = self.extract_keypoint_features(keypoints)
            features.append(keypoint_features)
            print(f"🎯 키포인트 특성 추출 완료: {keypoint_features.shape}")
        else:
            # 키포인트 없는 경우 0으로 채움
            features.append(np.zeros(48))
            print("❌ 키포인트 없음: 기본값 사용")
        
        # 3. 특성 결합
        combined_features = np.concatenate(features)
        features_tensor = torch.FloatTensor(combined_features).unsqueeze(0)
        
        device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        features_tensor = features_tensor.to(device)
        
        # 4. 감정 예측
        self.emotion_classifier.eval()
        with torch.no_grad():
            outputs = self.emotion_classifier(features_tensor)
            probabilities = F.softmax(outputs, dim=1)
            predicted_class = int(torch.argmax(probabilities, dim=1).item())
        
        # 5. 결과 정리
        emotion_scores = {}
        for i, prob in enumerate(probabilities[0]):
            emotion_scores[self.emotion_classes[i]] = float(prob)
        
        result = {
            "predicted_emotion": self.emotion_classes[predicted_class],
            "predicted_emotion_kr": self.emotion_classes_kr[predicted_class],
            "confidence": float(probabilities[0][predicted_class]),
            "emotion_scores": emotion_scores,
            "features_used": {
                "audio": audio_path is not None,
                "keypoints": keypoints is not None
            }
        }
        
        return result
    
    def analyze_emotion_from_video(self, video_path: str, 
                                 keypoints_data: Optional[Dict] = None) -> List[Dict]:
        """
        비디오에서 시간별 감정 분석
        Args:
            video_path: 비디오 파일 경로
            keypoints_data: 프레임별 키포인트 데이터
        Returns:
            emotion_timeline: 시간별 감정 분석 결과
        """
        results = []
        
        # 비디오에서 오디오 추출 (임시 파일)
        import tempfile
        temp_audio = tempfile.mktemp(suffix='.wav')
        
        try:
            # FFmpeg로 오디오 추출 (실제 구현에서는 subprocess 사용)
            print(f"🎬 비디오 분석 시작: {video_path}")
            
            # 프레임별 분석 (예시)
            for frame_idx in range(0, 100, 10):  # 10프레임마다
                frame_keypoints = None
                if keypoints_data and f"frame_{frame_idx}" in keypoints_data:
                    frame_keypoints = keypoints_data[f"frame_{frame_idx}"]
                
                # 해당 구간의 오디오 감정 분석
                emotion_result = self.predict_emotion(
                    audio_path=temp_audio if os.path.exists(temp_audio) else None,
                    keypoints=frame_keypoints
                )
                
                emotion_result["timestamp"] = frame_idx / 30.0  # 30fps 가정
                emotion_result["frame"] = frame_idx
                
                results.append(emotion_result)
        
        finally:
            # 임시 파일 정리
            if os.path.exists(temp_audio):
                os.remove(temp_audio)
        
        return results

def main():
    """메인 실행 예제"""
    print("🐕 강아지 감정 예측 모델 테스트")
    print("="*60)
    
    # 감정 예측기 초기화
    predictor = DogEmotionPredictor()
    
    # 테스트용 키포인트 데이터
    test_keypoints = {
        "nose": {"x": 100, "y": 200, "confidence": 0.9},
        "left_ear": {"x": 80, "y": 150, "confidence": 0.8},
        "right_ear": {"x": 120, "y": 150, "confidence": 0.8},
        # ... 다른 키포인트들
    }
    
    # 감정 예측 테스트
    result = predictor.predict_emotion(
        audio_path=None,  # 오디오 파일 경로
        keypoints=test_keypoints
    )
    
    print(f"\n🎯 감정 예측 결과:")
    print(f"예측 감정: {result['predicted_emotion_kr']} ({result['predicted_emotion']})")
    print(f"신뢰도: {result['confidence']:.3f}")
    
    print(f"\n📊 감정별 점수:")
    for emotion, score in result['emotion_scores'].items():
        print(f"  {emotion}: {score:.3f}")

if __name__ == "__main__":
    main()
