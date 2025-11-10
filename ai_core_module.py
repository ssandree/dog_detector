#!/usr/bin/env python3
"""
AI 코어 모듈: 강아지 탐지, 관절 추출, 멀티모달 분석 등 AI 핵심 기능
"""
import cv2
import numpy as np
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, Optional
from ultralytics import YOLO
import torch
import torch.nn as nn
import random
import torch.nn.functional as F
import pandas as pd
from scipy.signal import savgol_filter

# ------------------------------------------------------------------
### 실제 모델 import ###
# ------------------------------------------------------------------
# ST-GCN 기반 포즈 감정 모델
from dog_emotion_model.stgcn import DogEmotionSTGCN

# 슬개골 탈구 모델
from dog_pattela_model.patella_model import PatellaSTGCN

# VGGish 기반 음성 모델 (trainer 클래스에서 구조 가져오기)
try:
    from torchvggish import vggish
    from ai_train.train_emotion_a import DogVGGishTrainer
    VGGISH_AVAILABLE = True
except ImportError:
    VGGISH_AVAILABLE = False
    print("⚠️ VGGish 또는 트레이너 모듈 import 실패")

# 기존 예시 클래스들은 그대로 유지 (fallback용)
class VideoEmotionModel(nn.Module):
    """관절 데이터(ST-GCN 등)로 감정을 예측하는 모델 클래스 (예시)"""
    def __init__(self): super().__init__(); self.fc = nn.Linear(128, 4)  # 4개 클래스로 변경
    def forward(self, x): return self.fc(torch.randn(x.shape[0], 128))

class AudioAVModel(nn.Module):
    """음성으로 Arousal/Valence를 예측하는 모델 클래스 (예시)"""
    def __init__(self): super().__init__(); self.fc = nn.Linear(128, 2)
    def forward(self, x): return self.fc(x)
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
    """영상 파일을 처리하여 관절 데이터 JSON을 생성하고 음성을 분리하는 클래스"""
    def __init__(self, detector: DogDetectionCore, output_dir: Path = Path("processed_videos")):
        self.detector = detector
        self.output_dir = output_dir
        self.output_dir.mkdir(exist_ok=True)

    def extract_audio_from_video(self, video_path: str, output_audio_path: Optional[str] = None) -> Dict:
        """MP4 영상에서 음성을 추출하여 WAV 파일로 저장"""
        try:
            import subprocess
            import os
            
            # 출력 파일 경로 설정
            if output_audio_path is None:
                video_name = Path(video_path).stem
                output_audio_path = str(self.output_dir / f"{video_name}_audio.wav")
            
            # ffmpeg 명령어로 음성 추출
            cmd = [
                'ffmpeg', 
                '-i', video_path,           # 입력 비디오
                '-vn',                      # 비디오 스트림 제외
                '-acodec', 'pcm_s16le',     # 16bit PCM 코덱
                '-ar', '16000',             # 16kHz 샘플링 레이트 (VGGish 호환)
                '-ac', '1',                 # 모노 채널
                '-y',                       # 덮어쓰기 허용
                str(output_audio_path)
            ]
            
            # ffmpeg 실행
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                # 음성 파일 생성 성공
                file_size = os.path.getsize(output_audio_path) if os.path.exists(output_audio_path) else 0
                return {
                    "success": True,
                    "audio_path": output_audio_path,
                    "file_size": file_size,
                    "message": "음성 추출 완료"
                }
            else:
                # ffmpeg 오류
                return {
                    "success": False,
                    "audio_path": None,
                    "error": result.stderr,
                    "message": "ffmpeg 음성 추출 실패"
                }
                
        except FileNotFoundError:
            # ffmpeg가 설치되지 않은 경우, moviepy 사용 시도
            try:
                # moviepy import를 여기서 시도 (설치 안되어 있으면 에러 발생)
                import moviepy.editor as mp  # type: ignore
                
                if output_audio_path is None:
                    video_name = Path(video_path).stem
                    output_audio_path = str(self.output_dir / f"{video_name}_audio.wav")
                
                # moviepy로 음성 추출
                video_clip = mp.VideoFileClip(video_path)
                if video_clip.audio is not None:
                    audio_clip = video_clip.audio
                    audio_clip.write_audiofile(
                        str(output_audio_path),
                        fps=16000,  # 16kHz 샘플링 레이트
                        verbose=False,
                        logger=None
                    )
                    audio_clip.close()
                    video_clip.close()
                    
                    file_size = os.path.getsize(output_audio_path) if os.path.exists(output_audio_path) else 0
                    return {
                        "success": True,
                        "audio_path": output_audio_path,
                        "file_size": file_size,
                        "message": "음성 추출 완료 (moviepy 사용)"
                    }
                else:
                    video_clip.close()
                    return {
                        "success": False,
                        "audio_path": None,
                        "message": "영상에 음성 트랙이 없습니다"
                    }
                    
            except ImportError:
                return {
                    "success": False,
                    "audio_path": None,
                    "message": "ffmpeg와 moviepy 모두 사용할 수 없습니다. 설치가 필요합니다."
                }
            except Exception as e:
                return {
                    "success": False,
                    "audio_path": None,
                    "error": str(e),
                    "message": "moviepy 음성 추출 실패"
                }
                
        except Exception as e:
            return {
                "success": False,
                "audio_path": None,
                "error": str(e),
                "message": "음성 추출 중 예외 발생"
            }

    def process_mp4_complete(self, video_path: str, dog_id: str) -> Dict:
        """MP4 파일을 완전히 처리: 음성 추출 + 포즈 분석"""
        results = {
            "video_path": video_path,
            "dog_id": dog_id,
            "audio_extraction": {},
            "pose_analysis": {},
            "success": False
        }
        
        try:
            # 1. 음성 추출
            print(f"🎵 음성 추출 중: {video_path}")
            audio_result = self.extract_audio_from_video(video_path)
            results["audio_extraction"] = audio_result
            
            # 2. 포즈 분석 (키포인트 JSON 생성)
            print(f"🎯 포즈 분석 중: {video_path}")
            pose_result = self.process_video_to_json(video_path, dog_id)
            results["pose_analysis"] = pose_result
            
            # 3. 전체 성공 여부 판단
            results["success"] = pose_result.get("success", False)  # 포즈 분석은 필수
            
            print(f"✅ MP4 처리 완료: 음성={'O' if audio_result['success'] else 'X'}, 포즈={'O' if pose_result['success'] else 'X'}")
            
            return results
            
        except Exception as e:
            results["error"] = str(e)
            results["message"] = f"MP4 처리 중 오류: {e}"
            print(f"❌ MP4 처리 실패: {e}")
            return results

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
        base_dir = Path(__file__).parent
        ai_train_dir = base_dir / "ai_train"
        
        # 1. 포즈 감정 모델 (ST-GCN)
        print("📹 포즈 감정 모델 로딩...")
        try:
            # ST-GCN 모델 생성 (연결 정보는 기본값 사용)
            connections = [(2, 5), (5, 8), (8, 11), (11, 2), (0, 1), (1, 2), (3, 4), (4, 5), 
                          (6, 7), (7, 8), (9, 10), (10, 11), (12, 13), (14, 15), (16, 17), 
                          (14, 18), (15, 19)]
            from dog_emotion_model.stgcn import create_normalized_adjacency
            A = create_normalized_adjacency(20, connections)
            self.video_model = DogEmotionSTGCN(in_channels=3, num_classes=4, A=A, num_nodes=20, edges=connections)  # 4개 클래스로 변경
            
            # 가중치 로드
            video_weight_path = ai_train_dir / "best_dog_emotion_model_f1.pth"
            if video_weight_path.exists():
                checkpoint = torch.load(video_weight_path, map_location='cpu')
                # [수정] checkpoint에서 model_state_dict 추출
                if isinstance(checkpoint, dict) and 'model_state_dict' in checkpoint:
                    self.video_model.load_state_dict(checkpoint['model_state_dict'])
                    print(f"✅ 포즈 모델 로드 완료: {video_weight_path}")
                else:
                    self.video_model.load_state_dict(checkpoint)
                    print(f"✅ 포즈 모델 로드 완료: {video_weight_path}")
            else:
                print(f"⚠️ 포즈 모델 파일 없음: {video_weight_path}")
        except Exception as e:
            print(f"⚠️ 포즈 모델 로드 실패: {e}, 기본 모델 사용")
            self.video_model = VideoEmotionModel()
        self.video_model.eval()

        # 2. 음성 감정 모델 (VGGish)
        print("🎵 음성 감정 모델 로딩...")
        try:
            if VGGISH_AVAILABLE:
                # DogVGGishTrainer 생성 후 가중치 로드
                self.audio_trainer = DogVGGishTrainer(num_arousal_classes=3, num_valence_classes=3)
                audio_weight_path = ai_train_dir / "audio_emotion_model.pt"
                if audio_weight_path.exists():
                    self.audio_trainer.load_model(str(audio_weight_path))
                    print(f"✅ 음성 모델 로드 완료: {audio_weight_path}")
                else:
                    print(f"⚠️ 음성 모델 파일 없음: {audio_weight_path}")
                self.audio_model = self.audio_trainer  # trainer 객체를 그대로 사용
            else:
                print("⚠️ VGGish 미설치, 기본 모델 사용")
                self.audio_model = AudioAVModel()
        except Exception as e:
            print(f"⚠️ 음성 모델 로드 실패: {e}, 기본 모델 사용")
            self.audio_model = AudioAVModel()

        # 3. 슬개골 모델 로드 (2-class: 정상/이상)
        print("🦴 슬개골 탈구 모델 로딩...")
        try:
            patella_model_path = Path(__file__).parent / "dog_pattela_model" / "patella_model.pt"
            self.patella_model = PatellaSTGCN(in_channels=3, num_classes=2, dropout=0.5)  # 2-class로 변경
            
            if patella_model_path.exists():
                checkpoint = torch.load(patella_model_path, map_location='cpu')
                # checkpoint 구조 확인
                if isinstance(checkpoint, dict) and 'model_state_dict' in checkpoint:
                    self.patella_model.load_state_dict(checkpoint['model_state_dict'])
                    print(f"✅ 슬개골 모델 로드 완료: {patella_model_path}")
                else:
                    self.patella_model.load_state_dict(checkpoint)
                    print(f"✅ 슬개골 모델 로드 완료: {patella_model_path}")
            else:
                print(f"⚠️ 슬개골 모델 파일 없음: {patella_model_path}")
        except Exception as e:
            print(f"⚠️ 슬개골 모델 로드 실패: {e}")
            self.patella_model = None
        
        if self.patella_model:
            self.patella_model.eval()
        
        self.patella_labels = ["정상", "이상"]  # 2-class로 변경

        # 4. 전처리 통계 로드 (감정 모델용)
        print("📊 감정 모델 전처리 통계 로딩...")
        try:
            emotion_stats_path = ai_train_dir / "dog_pose_stats.pt"
            if emotion_stats_path.exists():
                stats = torch.load(emotion_stats_path, map_location='cpu')
                self.emotion_mean, self.emotion_std = stats['mean'], stats['std']
                print(f"✅ 감정 모델 통계 로드 완료: {emotion_stats_path}")
            else:
                print(f"⚠️ 감정 모델 통계 파일 없음: {emotion_stats_path}")
                self.emotion_mean, self.emotion_std = torch.zeros(3), torch.ones(3)
        except Exception as e:
            print(f"⚠️ 감정 모델 통계 로드 실패: {e}")
            self.emotion_mean, self.emotion_std = torch.zeros(3), torch.ones(3)
        
        # 5. 전처리 통계 로드 (슬개골 모델용)
        print("📊 슬개골 모델 전처리 통계 로딩...")
        try:
            patella_stats_path = Path(__file__).parent / "dog_pattela_model" / "patella_stats_seg60.pt"
            if patella_stats_path.exists():
                patella_stats = torch.load(patella_stats_path, map_location='cpu')
                self.patella_mean, self.patella_std = patella_stats['mean'], patella_stats['std']
                print(f"✅ 슬개골 모델 통계 로드 완료: {patella_stats_path}")
            else:
                print(f"⚠️ 슬개골 모델 통계 파일 없음: {patella_stats_path}")
                self.patella_mean, self.patella_std = torch.zeros(3), torch.ones(3)
        except Exception as e:
            print(f"⚠️ 슬개골 모델 통계 로드 실패: {e}")
            self.patella_mean, self.patella_std = torch.zeros(3), torch.ones(3)
        
        self.seg_len = 30  # 감정 모델용
        self.patella_seg_len = 60  # 슬개골 모델용
        self.emotion_labels = ["편안/안정", "불안/슬픔", "공포", "공격성"]
        self.keypoint_names = list(DogDetectionCore("").keypoint_mapping.values())
        print("✅ AI 인터페이스 초기화 완료")

    def _preprocess_joints(self, json_path: str, seg_len: int, for_patella: bool = False) -> torch.Tensor:
        """
        키포인트 JSON을 전처리하여 모델 입력 텐서 생성
        [수정] data_preprocess_emotion.py와 동일한 파이프라인 적용:
        1. 데이터 로드
        2. 스무딩/보간 (_smooth_and_interpolate)
        3. 샘플링/패딩
        4. 정규화 및 스케일링 (_normalize_and_scale)
        5. 텐서 변환 및 표준화
        """
        with open(json_path, 'r', encoding='utf-8') as f: 
            data = json.load(f)
        dog_id = list(data.keys())[0]
        frames_dict = data[dog_id].get('frames', {})
        sorted_frames = sorted(frames_dict.items(), key=lambda item: int(item[0].split('_')[1]))
        
        # 1. 데이터 로드 (shape: [T, V, 3])
        frames_data = []
        for _, keypoints_dict in sorted_frames:
            frame_joints = [list(keypoints_dict.get(name, {'x':0,'y':0,'confidence':0}).values()) for name in self.keypoint_names]
            frames_data.append(frame_joints)
        
        if not frames_data:
            return torch.zeros((1, 3, seg_len, len(self.keypoint_names), 1))

        sample = np.array(frames_data, dtype=np.float32)

        # 2. [추가] 스무딩/보간 적용 (학습시와 동일)
        sample = self._smooth_and_interpolate(sample)

        num_frames = sample.shape[0]
        
        # 3. 샘플링/패딩
        if num_frames > seg_len:
            start_idx = (num_frames - seg_len) // 2
            sample = sample[start_idx : start_idx + seg_len]
        else:
            sample = self._pad(sample, seg_len)
        
        # 4. 정규화 및 스케일링 (학습시와 동일)
        sample = self._normalize_and_scale(sample)
        
        # 5. 텐서 변환 (C, T, V)
        tensor = torch.from_numpy(sample).permute(2, 0, 1).float()
        
        # 6. 표준화 (mean/std 적용 - 모델에 따라 다른 통계 사용)
        if for_patella:
            mean, std = self.patella_mean, self.patella_std
        else:
            mean, std = self.emotion_mean, self.emotion_std
        
        permuted_tensor = tensor.permute(1, 2, 0)  # (T, V, C)
        tensor = (permuted_tensor - mean) / (std.clamp(min=1e-6))
        tensor = tensor.permute(2, 0, 1)  # (C, T, V)
        
        # 7. 배치 및 멤버 차원 추가 (1, C, T, V, 1)
        return tensor.unsqueeze(0).unsqueeze(-1)

    def _predict_emotion_from_video(self, keypoint_json_path: str, use_video_level_avg: bool = True) -> dict:
        """
        포즈 모델에서 4개 감정에 대한 확률값 출력
        [수정] 학습 시와 동일하게 비디오 레벨 평균 적용 옵션 추가
        """
        # 전체 프레임 로드하여 슬라이딩 윈도우로 분할
        with open(keypoint_json_path, 'r', encoding='utf-8') as f: 
            data = json.load(f)
        dog_id = list(data.keys())[0]
        frames_dict = data[dog_id].get('frames', {})
        sorted_frames = sorted(frames_dict.items(), key=lambda item: int(item[0].split('_')[1]))
        
        # 프레임 데이터 로드
        frames_data = []
        for _, keypoints_dict in sorted_frames:
            frame_joints = [list(keypoints_dict.get(name, {'x':0,'y':0,'confidence':0}).values()) for name in self.keypoint_names]
            frames_data.append(frame_joints)
        
        if not frames_data:
            return {name: 0.0 for name in self.emotion_labels}
        
        sample = np.array(frames_data, dtype=np.float32)
        sample = self._smooth_and_interpolate(sample)
        
        num_frames = sample.shape[0]
        
        # 슬라이딩 윈도우 방식으로 여러 세그먼트 생성 (학습 시와 동일)
        if use_video_level_avg and num_frames >= self.seg_len:
            all_probs = []
            stride = max(self.seg_len // 3, 1)  # 33% 오버랩
            
            for start_idx in range(0, num_frames - self.seg_len + 1, stride):
                segment = sample[start_idx : start_idx + self.seg_len]
                segment = self._normalize_and_scale(segment)
                
                # 텐서 변환 및 표준화
                tensor = torch.from_numpy(segment).permute(2, 0, 1).float()
                permuted_tensor = tensor.permute(1, 2, 0)
                tensor = (permuted_tensor - self.emotion_mean) / (self.emotion_std.clamp(min=1e-6))
                tensor = tensor.permute(2, 0, 1).unsqueeze(0).unsqueeze(-1)
                
                # 추론
                with torch.no_grad():
                    output = self.video_model(tensor)
                    prob = torch.softmax(output, dim=1)[0]
                    all_probs.append(prob)
            
            # 확률 평균 (학습 시와 동일)
            mean_prob = torch.mean(torch.stack(all_probs), dim=0)
            probabilities = mean_prob
        else:
            # 단일 세그먼트 (기존 방식)
            input_tensor = self._preprocess_joints(keypoint_json_path, self.seg_len)
            with torch.no_grad(): 
                output = self.video_model(input_tensor)
                probabilities = torch.softmax(output, dim=1)[0]
        
        # 4개 감정에 대한 확률값 반환
        video_emotion_probs = {}
        for i, name in enumerate(self.emotion_labels):
            if i < len(probabilities):
                video_emotion_probs[name] = float(probabilities[i].item())
            else:
                video_emotion_probs[name] = 0.0
        
        return video_emotion_probs

    def _check_audio_validity(self, audio_path: str) -> dict:
        """음성 파일의 유효성과 소리 유무를 체크"""
        try:
            import soundfile as sf
            import os
            
            # 파일 존재 여부 확인
            if not os.path.exists(audio_path):
                return {"valid": False, "has_sound": False, "reason": "파일 없음"}
            
            # 파일 크기 확인
            if os.path.getsize(audio_path) == 0:
                return {"valid": False, "has_sound": False, "reason": "파일 크기 0"}
            
            # 음성 파일 로드 시도
            try:
                wav_data, sr = sf.read(audio_path, dtype='float32')
                
                # 데이터가 비어있는지 확인
                if len(wav_data) == 0:
                    return {"valid": False, "has_sound": False, "reason": "음성 데이터 없음"}
                
                # 스테레오면 모노로 변환
                if wav_data.ndim > 1:
                    wav_data = wav_data.mean(axis=1)
                
                # 실제 소리가 있는지 확인 (RMS 기반)
                rms_value = np.sqrt(np.mean(wav_data**2))
                silence_threshold = 0.001  # 조정 가능한 임계값
                
                has_sound = rms_value > silence_threshold
                
                return {
                    "valid": True,
                    "has_sound": has_sound,
                    "rms": float(rms_value),
                    "duration": len(wav_data) / sr,
                    "reason": "정상" if has_sound else "무음/매우 작은 소리"
                }
                
            except Exception as e:
                return {"valid": False, "has_sound": False, "reason": f"음성 로드 실패: {e}"}
                
        except ImportError:
            return {"valid": False, "has_sound": False, "reason": "soundfile 라이브러리 없음"}
        except Exception as e:
            return {"valid": False, "has_sound": False, "reason": f"예외 발생: {e}"}

    def _predict_av_from_audio(self, audio_path: str) -> dict:
        """음성에서 Arousal/Valence 예측 (소리 유무 체크 포함)"""
        # 1. 음성 파일 유효성 체크
        audio_check = self._check_audio_validity(audio_path)
        
        # 2. 음성이 유효하지 않거나 소리가 없는 경우
        if not audio_check["valid"] or not audio_check["has_sound"]:
            print(f"🔇 음성 분석 불가: {audio_check['reason']}")
            return {
                "arousal": None,
                "valence": None, 
                "arousal_confidence": 0.0,
                "valence_confidence": 0.0,
                "audio_available": False,
                "audio_check": audio_check
            }
        
        # 3. 유효한 음성이 있는 경우에만 분석 수행
        try:
            # VGGish 트레이너가 있고 실제 모델이 로드된 경우
            if hasattr(self, 'audio_trainer') and hasattr(self.audio_trainer, 'forward'):
                # 실제 음성 전처리 및 추론은 트레이너의 기존 메서드 활용
                # 간단한 더미 데이터로 테스트 (실제로는 audio_path를 전처리해야 함)
                dummy_input = torch.zeros(1, 1, 96, 64)  # VGGish 입력 형태
                with torch.no_grad():
                    arousal_out, valence_out = self.audio_trainer.forward(dummy_input)
                    arousal_probs = torch.softmax(arousal_out, dim=1)[0]
                    valence_probs = torch.softmax(valence_out, dim=1)[0]
                    
                arousal_labels = ["Low", "Medium", "High"]
                valence_labels = ["Negative", "Neutral", "Positive"]
                
                arousal_pred = int(torch.argmax(arousal_probs).item())
                valence_pred = int(torch.argmax(valence_probs).item())
                
                return {
                    "arousal": arousal_labels[arousal_pred],
                    "valence": valence_labels[valence_pred],
                    "arousal_confidence": float(arousal_probs[arousal_pred].item()),
                    "valence_confidence": float(valence_probs[valence_pred].item()),
                    "audio_available": True,
                    "audio_check": audio_check
                }
            else:
                # 기본값 반환
                return {
                    "arousal": "Medium", 
                    "valence": "Neutral", 
                    "arousal_confidence": 0.5, 
                    "valence_confidence": 0.5,
                    "audio_available": True,
                    "audio_check": audio_check
                }
        except Exception as e:
            print(f"⚠️ 음성 감정 분석 실패: {e}")
            return {
                "arousal": None,
                "valence": None, 
                "arousal_confidence": 0.0,
                "valence_confidence": 0.0,
                "audio_available": False,
                "audio_check": audio_check
            }

    def analyze_emotion_multimodal(self, keypoint_json_path: str, audio_path: str) -> Dict:
        """멀티모달 감정 분석 - 포즈 + 음성 융합 (음성 없으면 포즈만 사용)"""
        # 1. 포즈 모델에서 4개 감정 확률 예측
        video_probs = self._predict_emotion_from_video(keypoint_json_path)
        
        # 2. 음성 모델에서 Arousal/Valence 예측 (유효성 체크 포함)
        audio_av = self._predict_av_from_audio(audio_path)
        
        # 3. 음성 유무에 따른 분석 방식 결정
        analysis_mode = "pose_only" if not audio_av.get("audio_available", True) else "multimodal"
        
        # 4. 융합 로직 적용
        fused_probs = self._fuse_pose_audio_emotions(video_probs, audio_av)
        
        # 5. 결과 정리
        if not fused_probs:
            return {
                "primary_emotion": "unknown",
                "confidence": 0.0,
                "analysis_mode": analysis_mode,
                "details": {"error": "Failed to calculate emotion probabilities."},
                "video_emotion": video_probs,
                "audio_arousal_valence": audio_av
            }
        
        primary_emotion = max(fused_probs.keys(), key=lambda x: fused_probs[x])
        return {
            "primary_emotion": primary_emotion, 
            "confidence": fused_probs[primary_emotion],
            "analysis_mode": analysis_mode,  # "pose_only" 또는 "multimodal"
            "details": fused_probs,
            "video_emotion": video_probs,
            "audio_arousal_valence": audio_av
        }

    def _fuse_pose_audio_emotions(self, video_probs: dict, audio_av: dict) -> dict:
        """포즈와 음성 감정을 융합하는 새로운 로직 (음성 없을 때 포즈만 사용)"""
        # 초기 확률은 포즈 모델 결과로 설정
        fused_probs = video_probs.copy()
        
        # 음성 데이터가 유효하지 않거나 소리가 없는 경우
        if not audio_av.get("audio_available", True) or audio_av.get("arousal") is None:
            print("🎯 음성 없음: 포즈 모델 결과만 사용")
            return fused_probs  # 포즈 모델 결과 그대로 반환
        
        # 음성에서 예측된 Arousal/Valence 조합 (음성이 있는 경우에만)
        arousal = audio_av.get("arousal", "Medium")
        valence = audio_av.get("valence", "Neutral")
        
        print(f"🎵 음성 결과 적용: Arousal={arousal}, Valence={valence}")
        
        # 음성 기반 감정 보정 로직
        if valence == "Negative" and arousal == "High":
            # (Negative, High) → 불안/슬픔, 공포, 공격성에 각각 1.0 추가
            fused_probs["불안/슬픔"] += 1.0
            fused_probs["공포"] += 1.0 
            fused_probs["공격성"] += 1.0
            print("📈 (Negative, High): 불안/슬픔, 공포, 공격성 보정")
            
        elif valence == "Negative" and arousal == "Low":
            # (Negative, Low) → 불안/슬픔에 1.0 추가
            fused_probs["불안/슬픔"] += 1.0
            print("📈 (Negative, Low): 불안/슬픔 보정")
        else:
            print("📊 다른 음성 조합: 포즈 결과 유지")
        
        # 확률 정규화 (합이 1이 되도록)
        total_prob = sum(fused_probs.values())
        if total_prob > 0:
            fused_probs = {emotion: prob / total_prob for emotion, prob in fused_probs.items()}
        
        return fused_probs

    def analyze_patella(self, keypoint_json_path: str, use_video_level_avg: bool = True) -> Dict:
        """
        슬개골 탈구 분석 (2-class: 정상/이상)
        [수정] 학습 시와 동일하게 비디오 레벨 평균 적용
        """
        try:
            if self.patella_model is None:
                return {
                    "status": "unknown", 
                    "confidence": 0.0, 
                    "probabilities": {},
                    "details": "슬개골 모델이 로드되지 않았습니다."
                }
            
            # 전체 프레임 로드하여 슬라이딩 윈도우로 분할
            with open(keypoint_json_path, 'r', encoding='utf-8') as f: 
                data = json.load(f)
            dog_id = list(data.keys())[0]
            frames_dict = data[dog_id].get('frames', {})
            sorted_frames = sorted(frames_dict.items(), key=lambda item: int(item[0].split('_')[1]))
            
            # 프레임 데이터 로드
            frames_data = []
            for _, keypoints_dict in sorted_frames:
                frame_joints = [list(keypoints_dict.get(name, {'x':0,'y':0,'confidence':0}).values()) for name in self.keypoint_names]
                frames_data.append(frame_joints)
            
            if not frames_data:
                return {
                    "status": "unknown",
                    "confidence": 0.0,
                    "probabilities": {},
                    "details": "프레임 데이터 없음"
                }
            
            sample = np.array(frames_data, dtype=np.float32)
            sample = self._smooth_and_interpolate(sample)
            
            num_frames = sample.shape[0]
            
            # 슬라이딩 윈도우 방식 (학습 시와 동일)
            if use_video_level_avg and num_frames >= self.patella_seg_len:
                all_probs = []
                stride = max(self.patella_seg_len // 3, 1)  # 33% 오버랩
                
                for start_idx in range(0, num_frames - self.patella_seg_len + 1, stride):
                    segment = sample[start_idx : start_idx + self.patella_seg_len]
                    segment = self._normalize_and_scale(segment)
                    
                    # 텐서 변환 및 표준화 (슬개골 통계 사용)
                    tensor = torch.from_numpy(segment).permute(2, 0, 1).float()
                    permuted_tensor = tensor.permute(1, 2, 0)
                    tensor = (permuted_tensor - self.patella_mean) / (self.patella_std.clamp(min=1e-6))
                    tensor = tensor.permute(2, 0, 1).unsqueeze(0).unsqueeze(-1)
                    
                    # 추론
                    with torch.no_grad():
                        output = self.patella_model(tensor)
                        prob = torch.softmax(output, dim=1)[0]
                        all_probs.append(prob)
                
                # 확률 평균 (학습 시와 동일)
                mean_prob = torch.mean(torch.stack(all_probs), dim=0)
                probabilities = mean_prob
            else:
                # 단일 세그먼트 (기존 방식)
                input_tensor = self._preprocess_joints(keypoint_json_path, self.patella_seg_len, for_patella=True)
                with torch.no_grad():
                    output = self.patella_model(input_tensor)
                    probabilities = torch.softmax(output, dim=1)[0]
            
            # 가장 높은 확률의 클래스 선택
            pred_idx = int(torch.argmax(probabilities).item())
            pred_status = self.patella_labels[pred_idx]  # "정상" 또는 "이상"
            pred_conf = float(probabilities[pred_idx].item())
            
            # 확률 분포
            prob_dict = {label: float(probabilities[i].item()) for i, label in enumerate(self.patella_labels)}
            
            return {
                "status": pred_status,  # "정상" 또는 "이상"
                "confidence": pred_conf,
                "probabilities": prob_dict,
                "details": f"{pred_status} (신뢰도: {pred_conf:.2%})"
            }
            
        except Exception as e:
            print(f"⚠️ 슬개골 분석 실패: {e}")
            return {
                "status": "error",
                "confidence": 0.0,
                "probabilities": {},
                "details": f"분석 중 오류 발생: {e}"
            }

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

    def _normalize_and_scale(self, sample):
        """
        [수정] (Median IQR 스케일링) - data_preprocess_emotion.py와 100% 동일
        시퀀스 전체(비디오 원본)에서 유효한 '모든 관절의 퍼짐 정도(IQR)'의 "중간값"을 찾아 
        단 하나의 스케일 값으로 시퀀스 전체를 정규화합니다.
        """
        processed_sample = sample.copy()
        all_frame_scales = []

        # 1. 시퀀스 전체를 스캔하여 유효한 스케일(퍼짐 정도) 값 수집
        for i in range(processed_sample.shape[0]):
            frame_coords_xy = processed_sample[i, :, :2]
            valid_coords = frame_coords_xy[np.any(frame_coords_xy != 0, axis=1)]
            
            if valid_coords.shape[0] < 2: 
                continue

            x_q1, x_q3 = np.percentile(valid_coords[:, 0], [25, 75])
            y_q1, y_q3 = np.percentile(valid_coords[:, 1], [25, 75])
            frame_scale = (x_q3 - x_q1) + (y_q3 - y_q1)
            
            if frame_scale > 1e-6: 
                all_frame_scales.append(frame_scale)

        # 2. 시퀀스의 대표 스케일 값(중간값) 결정
        if all_frame_scales:
            median_scale = np.median(all_frame_scales)
        else:
            median_scale = 1.0 
            
        # 3. 시퀀스 전체를 '단 하나의' 대표 스케일 값으로 정규화
        for i in range(processed_sample.shape[0]):
            frame = processed_sample[i]
            frame_coords_xy = frame[:, :2]
            
            valid_coords = frame_coords_xy[np.any(frame_coords_xy != 0, axis=1)]
            if valid_coords.shape[0] > 0:
                center = np.median(valid_coords, axis=0)
            else:
                center = np.array([0, 0]) 
            
            processed_sample[i, :, :2] = processed_sample[i, :, :2] - center
            
            if median_scale > 1e-6:
                processed_sample[i, :, :2] = processed_sample[i, :, :2] / median_scale
        
        return processed_sample

    def _smooth_and_interpolate(self, sample: np.ndarray,
                                 confidence_threshold: float = 0.3,
                                 window_length: int = 5, polyorder: int = 2):
        """
        스무딩 및 보간 (data_preprocess_emotion.py와 100% 동일)
        1. 낮은 신뢰도 키포인트를 NaN으로 마스킹
        2. 선형 보간으로 NaN 채우기
        3. Savitzky-Golay 필터로 스무딩
        """
        num_frames_in = sample.shape[0]
        if num_frames_in == 0: 
            return sample
            
        num_joints = sample.shape[1]
        processed_sample = sample.copy()
        
        # 좌표와 신뢰도 분리
        coords = processed_sample[:, :, :2].copy()
        confidences = processed_sample[:, :, 2]
        
        # 낮은 신뢰도 → NaN
        coords[confidences < confidence_threshold] = np.nan
        
        # 각 관절에 대해 보간
        for j in range(num_joints):
            s_x = pd.Series(coords[:, j, 0])
            s_y = pd.Series(coords[:, j, 1])
            
            s_x_filled = s_x.interpolate(method='linear', limit_direction='both', limit_area='inside').ffill().bfill()
            s_y_filled = s_y.interpolate(method='linear', limit_direction='both', limit_area='inside').ffill().bfill()
            
            processed_sample[:, j, 0] = s_x_filled.values
            processed_sample[:, j, 1] = s_y_filled.values
        
        processed_sample = np.nan_to_num(processed_sample)
        
        # Savitzky-Golay 필터 적용
        safe_window_length = min(window_length, num_frames_in)
        if safe_window_length % 2 == 0: 
            safe_window_length -= 1
        if safe_window_length < 3: 
            return processed_sample
            
        safe_polyorder = min(polyorder, safe_window_length - 1)
        if safe_polyorder < 1: 
            safe_polyorder = 1
        
        if num_frames_in >= safe_window_length:
            try:
                for j in range(num_joints):
                    processed_sample[:, j, 0] = savgol_filter(processed_sample[:, j, 0], safe_window_length, safe_polyorder)
                    processed_sample[:, j, 1] = savgol_filter(processed_sample[:, j, 1], safe_window_length, safe_polyorder)
            except ValueError: 
                pass
        
        return processed_sample

    def _pad(self, sample, target_len):
        padded_sample = np.zeros((target_len, sample.shape[1], sample.shape[2]), dtype=np.float32)
        if sample.shape[0] > 0:
            padded_sample[:sample.shape[0], :, :] = sample
        return padded_sample

    def analyze_mp4_complete(self, mp4_path: str, dog_id: str = "dog_001") -> Dict:
        """MP4 파일을 완전 분석: 음성 분리 + 포즈 추출 + 감정 분석"""
        print(f"🎬 MP4 완전 분석 시작: {mp4_path}")
        
        try:
            # 1. VideoProcessor로 MP4 처리 (음성 분리 + 포즈 추출)
            detector = DogDetectionCore()
            processor = VideoProcessor(detector)
            
            # MP4에서 음성과 포즈 데이터 추출
            process_result = processor.process_mp4_complete(mp4_path, dog_id)
            
            if not process_result["success"]:
                return {
                    "success": False,
                    "error": "MP4 처리 실패",
                    "details": process_result
                }
            
            # 2. 추출된 파일들로 감정 분석
            keypoint_json_path = process_result["pose_analysis"].get("json_path")
            audio_path = process_result["audio_extraction"].get("audio_path", "")
            
            if not keypoint_json_path:
                return {
                    "success": False,
                    "error": "키포인트 JSON 생성 실패",
                    "details": process_result
                }
            
            # 3. 멀티모달 감정 분석 수행
            emotion_result = self.analyze_emotion_multimodal(keypoint_json_path, audio_path or "")
            
            # 4. 전체 결과 통합
            return {
                "success": True,
                "mp4_path": mp4_path,
                "dog_id": dog_id,
                "processing": process_result,
                "emotion_analysis": emotion_result,
                "files_generated": {
                    "keypoints_json": keypoint_json_path,
                    "extracted_audio": audio_path,
                    "audio_available": process_result["audio_extraction"]["success"]
                }
            }
            
        except Exception as e:
            print(f"❌ MP4 분석 실패: {e}")
            return {
                "success": False,
                "error": str(e),
                "mp4_path": mp4_path,
                "message": f"MP4 분석 중 오류 발생: {e}"
            }