#!/usr/bin/env python3
"""
AI 코어 모듈: 강아지 탐지, 관절 추출, 멀티모달 분석 등 AI 핵심 기능
"""
import cv2
import numpy as np
import json
from pathlib import Path
from datetime import datetime
from typing import Dict
from ultralytics import YOLO
import torch
import torch.nn as nn
import random
import torch.nn.functional as F

# ------------------------------------------------------------------
### >>> TODO: 사용자 구현 필요 <<< ###
# 사용자가 훈련시킨 실제 모델들의 아키텍처(클래스 정의)를 여기에 붙여넣거나 import 하세요.
# ------------------------------------------------------------------
class VideoEmotionModel(nn.Module):
    """관절 데이터(ST-GCN 등)로 감정을 예측하는 모델 클래스 (예시)"""
    def __init__(self): super().__init__(); self.fc = nn.Linear(128, 6)
    def forward(self, x): return self.fc(torch.randn(x.shape[0], 128))

class AudioAVModel(nn.Module):
    """음성으로 Arousal/Valence를 예측하는 모델 클래스 (예시)"""
    def __init__(self): super().__init__(); self.fc = nn.Linear(128, 2)
    def forward(self, x): return self.fc(x)

class PatellaAnalysisModel(nn.Module):
    """관절 데이터로 슬개골 위험도를 예측하는 모델 클래스 (예시)"""
    def __init__(self): super().__init__(); self.fc = nn.Linear(128, 3)
    def forward(self, x): return self.fc(torch.randn(x.shape[0], 128))
# ------------------------------------------------------------------

class DogDetectionCore:
    """YOLO 모델을 사용하여 강아지 객체 및 관절을 탐지하는 클래스"""
    def __init__(self, model_path: str = "DogPose_Official/yolo11n_dog24_v242/weights/best.pt"):
        self.model = YOLO(model_path)
        #20개만 사용해야될 듯 4개가 계속 이상한 곳에 잡힘 
        self.keypoint_mapping = {0: "left_f_wrist", 1: "left_f_ankle", 2: "left_f_shoulder",
3: "left_b_wrist", 4: "left_b_ankle", 5: "left_b_shoulder", 6: "right_f_wrist",
7: "right_f_ankle", 8: "right_f_shoulder", 9: "right_b_wrist", 10: "right_b_ankle",
11: "right_b_shoulder", 12: "tail_start", 13: "tail_end", 14: "left_mid_ear",
15: "right_mid_ear", 16: "nose", 17: "mouth", 18: "left_edge_ear", 19: "right_edge_ear"}

    def detect_dog_in_frame(self, frame: np.ndarray) -> Dict:
        results = self.model(frame, conf=0.5, verbose=False)
        detection_result = {'detected': False, 'confidence': 0.0, 'bbox': None, 'keypoints': self._get_empty_keypoints()}
        if results and results[0].boxes:
            box = results[0].boxes[0]
            detection_result['detected'] = True
            detection_result['confidence'] = float(box.conf[0])
            detection_result['bbox'] = box.xyxy[0].cpu().numpy().tolist()
            if results[0].keypoints and results[0].keypoints.data.shape[1] > 0:
                keypoints_data = results[0].keypoints.data[0].cpu().numpy()
                detection_result['keypoints'] = self._process_keypoints(keypoints_data)
        return detection_result

    def _get_empty_keypoints(self) -> Dict:
        return {name: {'x': 0.0, 'y': 0.0, 'confidence': 0.0} for name in self.keypoint_mapping.values()}

    def _process_keypoints(self, keypoints: np.ndarray, conf_threshold: float = 0.3) -> Dict:
        full_keypoints = {}
        for i, name in self.keypoint_mapping.items():
            if i < len(keypoints):
                x, y, conf = keypoints[i]
                if conf > conf_threshold and x > 0 and y > 0:
                    full_keypoints[name] = {'x': float(x), 'y': float(y), 'confidence': float(conf)}
                else:
                    full_keypoints[name] = {'x': 0.0, 'y': 0.0, 'confidence': 0.0}
            else:
                full_keypoints[name] = {'x': 0.0, 'y': 0.0, 'confidence': 0.0}
        return full_keypoints

class VideoProcessor:
    """영상 파일을 처리하여 관절 데이터 JSON을 생성하는 클래스"""
    def __init__(self, detector: DogDetectionCore, output_dir: Path = Path("processed_videos")):
        self.detector = detector
        self.output_dir = output_dir
        self.output_dir.mkdir(exist_ok=True)

    def process_video_to_json(self, video_path: str, dog_id: str) -> Dict:
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened(): raise ValueError(f"영상을 열 수 없습니다: {video_path}")
        json_data = {dog_id: {"frames": {}}}
        frame_count = 0
        while True:
            ret, frame = cap.read()
            if not ret: break
            if frame_count % 5 == 0:
                detection = self.detector.detect_dog_in_frame(frame)
                if detection['detected']:
                    frame_key = f"frame_{frame_count}"
                    json_data[dog_id]["frames"][frame_key] = detection['keypoints']
            frame_count += 1
        cap.release()
        json_path = self.output_dir / f"{dog_id}_keypoints.json"
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, indent=2, ensure_ascii=False)
        return {"success": True, "json_path": str(json_path), "dog_id": dog_id}

class AIModelInterface:
    """모든 분석 모델을 총괄하는 인터페이스"""
    def __init__(self):
        print("🤖 AI 인터페이스 초기화 시작...")
        base_dir = Path(__file__).parent.parent
        model_dir = base_dir / "saved_models"
        
        self.video_model = VideoEmotionModel()
        # self.video_model.load_state_dict(torch.load(model_dir / "video_emotion_model.pt"))
        self.video_model.eval()

        self.audio_model = AudioAVModel()
        # self.audio_model.load_state_dict(torch.load(model_dir / "audio_av_model.pt"))
        self.audio_model.eval()

        self.patella_model = PatellaAnalysisModel()
        # self.patella_model.load_state_dict(torch.load(model_dir / "patella_model.pt"))
        self.patella_model.eval()

        stats = torch.load(model_dir / "dog_pose_stats.pt")
        self.mean, self.std = stats['mean'], stats['std']
        
        self.seg_len = 60
        self.emotion_labels = ["happy", "sad", "angry", "anxious", "calm", "excited"]
        self.keypoint_names = list(DogDetectionCore("").keypoint_mapping.values())
        print("✅ AI 인터페이스 초기화 완료")

    def _preprocess_joints(self, json_path: str, seg_len: int) -> torch.Tensor:
        with open(json_path, 'r', encoding='utf-8') as f: data = json.load(f)
        dog_id = list(data.keys())[0]
        frames_dict = data[dog_id].get('frames', {})
        sorted_frames = sorted(frames_dict.items(), key=lambda item: int(item[0].split('_')[1]))
        
        frames_data = []
        for _, keypoints_dict in sorted_frames:
            frame_joints = [list(keypoints_dict.get(name, {'x':0,'y':0,'confidence':0}).values()) for name in self.keypoint_names]
            frames_data.append(frame_joints)
        
        if not frames_data:
            return torch.zeros((1, 3, seg_len, len(self.keypoint_names), 1))

        sample = np.array(frames_data, dtype=np.float32)

        num_frames = sample.shape[0]
        if num_frames > seg_len:
            start_idx = (num_frames - seg_len) // 2
            sample = sample[start_idx : start_idx + seg_len]
        else:
            sample = self._pad(sample, seg_len)
        
        sample = self._normalize(sample)
        tensor = torch.from_numpy(sample).permute(2, 0, 1).float()
        
        permuted_tensor = tensor.permute(1, 2, 0)
        tensor = (permuted_tensor - self.mean) / self.std
        tensor = tensor.permute(2, 0, 1)
        return tensor.unsqueeze(0).unsqueeze(-1)

    def _predict_emotion_from_video(self, keypoint_json_path: str) -> dict:
        input_tensor = self._preprocess_joints(keypoint_json_path, self.seg_len)
        with torch.no_grad(): output = self.video_model(input_tensor)
        probabilities = torch.softmax(output, dim=1)[0]
        return {name: prob.item() for name, prob in zip(self.emotion_labels, probabilities)}

    def _predict_av_from_audio(self, audio_path: str) -> dict:
        # ### >>> TODO: 실제 음성 전처리 및 모델 추론 구현 <<< ###
        return {"arousal": random.uniform(-1, 1), "valence": random.uniform(-1, 1)}

    def analyze_emotion_multimodal(self, keypoint_json_path: str, audio_path: str) -> Dict:
        video_probs = self._predict_emotion_from_video(keypoint_json_path)
        audio_av = self._predict_av_from_audio(audio_path)
        fused_probs = self._fuse_emotion_results(video_probs, audio_av)
        # ▼▼▼▼▼ [해결책] 딕셔너리가 비어 있는지 확인하는 코드 추가 ▼▼▼▼▼
        if not fused_probs: # 딕셔너리가 비어있으면 True
            # 오류를 발생시키는 대신, 기본값 또는 에러 상태를 반환
            return {
                "primary_emotion": "unknown",
                "confidence": 0.0,
                "details": {"error": "Failed to calculate emotion probabilities."}
            }
        # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
        primary_emotion = max(fused_probs.keys(), key=lambda x: fused_probs[x])  # 타입 안전한 방법
        return {"primary_emotion": primary_emotion, "confidence": fused_probs[primary_emotion], "details": fused_probs}

    def analyze_patella(self, keypoint_json_path: str) -> Dict:
        # ### >>> TODO: 실제 슬개골 모델 추론 구현 <<< ###
        return {"risk_level": "low", "confidence": 0.92, "details": "정상"}

    def _fuse_emotion_results(self, video_probs: dict, audio_av: dict, boost_factor: float = 1.5) -> dict:
        EMOTION_AV_MAP = {"happy": ("Positive", "High"), "sad": ("Negative", "Low"), "angry": ("Negative", "High"), "anxious": ("Negative", "High"), "calm": ("Positive", "Low"), "excited": ("Positive", "High")}
        audio_valence_quad = "Positive" if audio_av.get("valence", 0) >= 0 else "Negative"
        audio_arousal_quad = "High" if audio_av.get("arousal", 0) >= 0 else "Low"
        adjusted_scores = {}
        for emotion, prob in video_probs.items():
            expected_valence, expected_arousal = EMOTION_AV_MAP.get(emotion, (None, None))
            if expected_valence == audio_valence_quad and expected_arousal == audio_arousal_quad:
                adjusted_scores[emotion] = prob * boost_factor
            else:
                adjusted_scores[emotion] = prob
        scores = torch.tensor(list(adjusted_scores.values()))
        final_probs = F.softmax(scores, dim=0)
        return {emotion: prob.item() for emotion, prob in zip(adjusted_scores.keys(), final_probs)}

    def _normalize(self, sample):
        left_shoulder_idx, right_shoulder_idx = 5, 6
        for i in range(sample.shape[0]):
            left_shoulder = sample[i, left_shoulder_idx, :2]
            right_shoulder = sample[i, right_shoulder_idx, :2]
            if np.all(left_shoulder != 0) and np.all(right_shoulder != 0):
                center = (left_shoulder + right_shoulder) / 2
                sample[i, :, :2] = sample[i, :, :2] - center
        return sample

    def _pad(self, sample, target_len):
        padded_sample = np.zeros((target_len, sample.shape[1], sample.shape[2]), dtype=np.float32)
        if sample.shape[0] > 0:
            padded_sample[:sample.shape[0], :, :] = sample
        return padded_sample