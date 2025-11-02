#!/usr/bin/env python3
"""
VGGish 파인튜닝 스크립트
(수정) Arousal (3-Class) / Valence (3-Class) 멀티태스크 분류
(수정) 명시적 침묵 데이터 추가
(수정) 실제 CSV 및 폴더 경로에서 데이터 로드
(수정) LFS 포인터 파일 오류 방어 및 짧은 오디오 루프 패딩 적용
"""

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
import numpy as np
import os
from pathlib import Path
from torchvggish import vggish, vggish_input
import pickle
from typing import List, Tuple, Dict, Optional
import itertools
import random
import pandas as pd
import soundfile as sf # [추가] 오디오 직접 로딩/패딩 위해
import math # [추가] 패딩 계산 위해
from sklearn.metrics import classification_report, accuracy_score, f1_score

# --- 전역 라벨 매핑 정의 ---
AROUSAL_MAP = {'Low': 0, 'Medium': 1, 'High': 2}
VALENCE_MAP = {'Negative': 0, 'Neutral': 1, 'Positive': 2}
AROUSAL_NAMES = list(AROUSAL_MAP.keys())
VALENCE_NAMES = list(VALENCE_MAP.keys())
NUM_AROUSAL_CLASSES = 3
NUM_VALENCE_CLASSES = 3
# 침묵 라벨 정의 (Medium=1, Neutral=1)
SILENCE_AROUSAL_LABEL = AROUSAL_MAP['Medium']
SILENCE_VALENCE_LABEL = VALENCE_MAP['Neutral']
# VGGish 상수
VGGISH_SAMPLE_RATE = 16000
VGGISH_SEGMENT_LENGTH_SAMPLES = int(VGGISH_SAMPLE_RATE * 0.96) # 15360


class DogAudioDataset(Dataset):
    """
    강아지 오디오 데이터셋 (Arousal/Valence 멀티태스크 분류용)
    [수정] 'SILENT' 경로 처리 기능 추가
    [수정] 짧은 오디오 파일 루프 패딩
    [수정] LFS 포인터 파일(soundfile 오류) 방어
    [수정] 세그먼트 0개 파일 경고(print) 제거
    """
    
    def __init__(self, audio_files: List[str], arousal_labels: List[int], valence_labels: List[int], train: bool = True):
        self.audio_files = audio_files
        self.train = train
        self.arousal_labels_tensor = torch.LongTensor(arousal_labels)
        self.valence_labels_tensor = torch.LongTensor(valence_labels)
        
        self.silence_label_arousal = SILENCE_AROUSAL_LABEL
        self.silence_label_valence = SILENCE_VALENCE_LABEL
        
    def __len__(self):
        return len(self.audio_files)
    
    def _pad_loop_waveform(self, waveform, target_samples):
        """[추가] 1D 오디오 파형을 루프 패딩하는 함수"""
        num_samples = waveform.shape[0]
        if num_samples == 0:
            return np.zeros(target_samples, dtype=np.float32)
        
        num_repeats = math.ceil(target_samples / num_samples)
        looped_data = np.tile(waveform, num_repeats)
        return looped_data[:target_samples]
    # ▼▼▼▼▼ [추가] SpecAugment 함수 ▼▼▼▼▼
    def _augment(self, spectrogram_tensor):
        """
        간단한 SpecAugment (Frequency & Time Masking) 적용
        입력: (1, 96, 64) 텐서
        """
        # 1. Frequency Masking
        freq_mask_param = 27 # VGGish 멜 밴드 수 96의 약 1/3.5
        f = random.randint(0, freq_mask_param)
        f0 = random.randint(0, 96 - f)
        spectrogram_tensor[:, f0:f0+f, :] = 0

        # 2. Time Masking
        time_mask_param = 20 # VGGish 시간 스텝 64의 약 1/3
        t = random.randint(0, time_mask_param)
        t0 = random.randint(0, 64 - t)
        spectrogram_tensor[:, :, t0:t0+t] = 0

        return spectrogram_tensor
    # ▲▲▲▲▲ [추가] SpecAugment 함수 끝 ▲▲▲▲▲

    def __getitem__(self, idx):
        audio_path = self.audio_files[idx]
        label_arousal = self.arousal_labels_tensor[idx]
        label_valence = self.valence_labels_tensor[idx]

        # --- 'SILENT' 경로 처리 ---
        if audio_path == "SILENT":
            silent_audio = torch.zeros(1, 96, 64) # 3D 텐서 반환
            return silent_audio, torch.tensor(self.silence_label_arousal), torch.tensor(self.silence_label_valence)
        
        # (실제 오디오 파일 로드 및 처리)
        try:
            # ▼▼▼▼▼ [핵심 수정] soundfile로 직접 로드 및 패딩 ▼▼▼▼▼
            try:
                wav_data, sr = sf.read(audio_path, dtype='int16')
                if sr != VGGISH_SAMPLE_RATE:
                    raise ValueError(f"지원하지 않는 샘플링 레이트: {sr}Hz (16000Hz 필요)")
                
                if wav_data.ndim > 1: # 스테레오 -> 모노
                    wav_data = wav_data.mean(axis=1).astype(np.int16)

            except Exception as e:
                # soundfile이 실패하면 (LFS 포인터, 손상된 파일 등)
                # LFS 포인터 파일(텍스트)은 여기서 'sf.read' 오류를 발생시킴
                raise ValueError(f"soundfile.read 실패 (LFS 포인터 또는 손상된 파일 의심): {e}")
            
            samples = wav_data / 32768.0 # float32로 변환
            
            # [수정] 길이가 0.96초 (15360 샘플) 미만이면 *먼저* 패딩
            if len(samples) < VGGISH_SEGMENT_LENGTH_SAMPLES:
                samples = self._pad_loop_waveform(samples, VGGISH_SEGMENT_LENGTH_SAMPLES)
            
            # 패딩된/원본 파형 -> VGGish 입력 텐서로 변환
            audio_input_np = vggish_input.waveform_to_examples(samples, VGGISH_SAMPLE_RATE)
            # torch.Tensor 반환 시 np.ndarray로 변환
            if isinstance(audio_input_np, torch.Tensor):
                if audio_input_np.requires_grad:
                    audio_input_np = audio_input_np.detach().cpu().numpy()
                else:
                    audio_input_np = audio_input_np.cpu().numpy()
            
            if audio_input_np.ndim == 4 and audio_input_np.shape[1] == 1:
                audio_input_np = np.squeeze(audio_input_np, axis=1)  # (N, 96, 64)
            
            # ▼▼▼▼▼ [핵심 수정] ▼▼▼▼▼
            # 세그먼트가 0개이거나 shape가 (N, 96, 64)가 아닌 경우,
            # 예외(raise) 대신 '조용히' 더미 데이터를 반환합니다.
            if audio_input_np.ndim != 3 or audio_input_np.shape[0] == 0 or audio_input_np.shape[1:] != (96, 64):
                dummy_audio = torch.zeros(1, 96, 64) # 3D 텐서 반환
                dummy_label = 0
                return dummy_audio, torch.tensor(dummy_label), torch.tensor(dummy_label)
            # ▲▲▲▲▲ [핵심 수정] ▲▲▲▲▲

            # 4. 세그먼트 선택 (훈련/검증)

            if self.train:
                frame_idx = np.random.randint(0, len(audio_input_np)) if len(audio_input_np) > 1 else 0
                audio_tensor = torch.from_numpy(audio_input_np[frame_idx]).float() # (96, 64)
            else:
                mean_frame = np.asarray(audio_input_np).mean(axis=0).astype(np.float32)
                audio_tensor = torch.from_numpy(mean_frame) # (96, 64)

            audio_tensor = audio_tensor.unsqueeze(0) # (1, 96, 64)
            
            '''
            if self.train:
                # Arousal 또는 Valence 둘 중 하나라도 소수 클래스(0번 아님)이면
                is_minority_A = (label_arousal != 0) # Low(0)가 아닌 Medium(1) or High(2)
                is_minority_V = (label_valence != 0) # Negative(0)가 아닌 Neutral(1) or Positive(2)
                
                if is_minority_A or is_minority_V:
                    # 소수 클래스는 3번 증강 (다양성 확보)
                    for _ in range(3):
                        audio_tensor = self._augment(audio_tensor)
                # else: 다수 클래스(Low, Negative)는 증강 적용 안 함
            # ▲▲▲▲▲ [핵심 수정] ▲▲▲▲▲
            '''
            return audio_tensor, label_arousal, label_valence
            
        except Exception as e:
            # [수정]
            # 이제 여기서는 'soundfile.read' 실패 (LFS 포인터 등)와 같이
            # 세그먼트 생성 *이전*의 심각한 오류만 잡힙니다.
            print(f"⚠️ 오디오 로딩 실패 {audio_path}: {type(e).__name__} - {e}")
            dummy_audio = torch.zeros(1, 96, 64) # 3D 텐서 반환
            dummy_label = 0
            return dummy_audio, torch.tensor(dummy_label), torch.tensor(dummy_label)

# --- (DogVGGishTrainer 클래스는 이전과 동일) ---
class DogVGGishTrainer:
    def __init__(self, num_arousal_classes: int = 3, 
                 num_valence_classes: int = 3, 
                 arousal_weights: Optional[torch.Tensor] = None, 
                 valence_weights: Optional[torch.Tensor] = None, 
                 device: str = 'auto'):
        self.device = device if device != 'auto' else ('cuda' if torch.cuda.is_available() else 'cpu')
        self.vggish = vggish(postprocess=False)
        self.shared_mlp = nn.Sequential(
            nn.Linear(128, 256), nn.ELU(), nn.Dropout(0.5),
            nn.Linear(256, 256), nn.ELU(), nn.Dropout(0.5),
            nn.Linear(256, 256), nn.ELU(), nn.Dropout(0.5),
            nn.Linear(256, 256), nn.ELU(), nn.Dropout(0.5)
        )
        self.arousal_head = nn.Linear(256, num_arousal_classes)
        self.valence_head = nn.Linear(256, num_valence_classes)
        self.vggish.to(self.device); self.shared_mlp.to(self.device)
        self.arousal_head.to(self.device); self.valence_head.to(self.device)
        self.criterion_arousal = nn.CrossEntropyLoss(weight=arousal_weights)
        self.criterion_valence = nn.CrossEntropyLoss(weight=valence_weights)
        # [추가] 가중치 적용 여부 출력
        if arousal_weights is not None:
             print(f"  > Arousal 가중치 적용: {arousal_weights.cpu().numpy()}")
        else:
             print("  > Arousal 가중치 미적용.")
        if valence_weights is not None:
             print(f"  > Valence 가중치 적용: {valence_weights.cpu().numpy()}")
        else:
             print("  > Valence 가중치 미적용.")
        print(f"🎮 디바이스: {self.device}")
        print(f"🎵 VGGish A/V Multi-Task Classification 파인튜닝 준비 완료")
        print(f"📊 Arousal: {num_arousal_classes} 클래스, Valence: {num_valence_classes} 클래스")
        print(f"🎮 디바이스: {self.device}")
    
    def setup_optimizer(self, lr_vggish: float = 1e-5, lr_classifier: float = 1e-3):
        classifier_params = itertools.chain(self.shared_mlp.parameters(), 
                                            self.arousal_head.parameters(), 
                                            self.valence_head.parameters())
        self.optimizer = optim.AdamW([
            {'params': self.vggish.parameters(), 'lr': lr_vggish},
            {'params': classifier_params, 'lr': lr_classifier}
        ])
        self.scheduler = optim.lr_scheduler.ReduceLROnPlateau(
            self.optimizer, mode='min', factor=0.5, patience=5
        ) # verbose=True 제거
        print(f"⚙️ 옵티마이저 설정: VGGish lr={lr_vggish}, Classifier Heads lr={lr_classifier}")
    
    def forward(self, x):
        vggish_features = self.vggish(x)
        shared_features = self.shared_mlp(vggish_features)
        output_arousal = self.arousal_head(shared_features)
        output_valence = self.valence_head(shared_features)
        return output_arousal, output_valence
    
    def train_epoch(self, dataloader: DataLoader):
        self.vggish.train(); self.shared_mlp.train()
        self.arousal_head.train(); self.valence_head.train()
        total_loss, correct_arousal, correct_valence, total = 0.0, 0, 0, 0
        
        for batch_idx, (audio, labels_arousal, labels_valence) in enumerate(dataloader):
            audio, labels_arousal, labels_valence = audio.to(self.device), labels_arousal.to(self.device), labels_valence.to(self.device)
            outputs_arousal, outputs_valence = self.forward(audio)
            loss_arousal = self.criterion_arousal(outputs_arousal, labels_arousal)
            loss_valence = self.criterion_valence(outputs_valence, labels_valence)
            loss = loss_arousal + loss_valence
            self.optimizer.zero_grad(); loss.backward(); self.optimizer.step()
            total_loss += loss.item(); total += labels_arousal.size(0)
            _, predicted_arousal = outputs_arousal.max(1); correct_arousal += predicted_arousal.eq(labels_arousal).sum().item()
            _, predicted_valence = outputs_valence.max(1); correct_valence += predicted_valence.eq(labels_valence).sum().item()
            if batch_idx % 20 == 0: print(f"  배치 {batch_idx}/{len(dataloader)}: Total Loss={loss.item():.4f}")
        
        avg_loss = total_loss / (len(dataloader) + 1e-6)
        acc_arousal = 100.0 * correct_arousal / (total + 1e-6)
        acc_valence = 100.0 * correct_valence / (total + 1e-6)
        return avg_loss, acc_arousal, acc_valence
    
    # ▼▼▼▼▼ [수정] validate 함수: 예측/정답 리스트 반환 ▼▼▼▼▼
    def validate(self, dataloader: DataLoader):
        self.vggish.eval(); self.shared_mlp.eval()
        self.arousal_head.eval(); self.valence_head.eval()
        
        total_loss = 0.0
        all_labels_A, all_labels_V = [], []
        all_preds_A, all_preds_V = [], []
        
        dataset_size = len(dataloader.dataset)
        
        with torch.no_grad():
            for audio, labels_arousal, labels_valence in dataloader:
                audio, labels_arousal, labels_valence = audio.to(self.device), labels_arousal.to(self.device), labels_valence.to(self.device)
                
                outputs_arousal, outputs_valence = self.forward(audio)
                
                loss_arousal = self.criterion_arousal(outputs_arousal, labels_arousal)
                loss_valence = self.criterion_valence(outputs_valence, labels_valence)
                loss = loss_arousal + loss_valence
                
                total_loss += loss.item() * audio.size(0) # [수정] 배치 크기 곱하기
                
                _, predicted_arousal = outputs_arousal.max(1)
                _, predicted_valence = outputs_valence.max(1)
                
                # 리스트에 추가
                all_labels_A.extend(labels_arousal.cpu().numpy())
                all_labels_V.extend(labels_valence.cpu().numpy())
                all_preds_A.extend(predicted_arousal.cpu().numpy())
                all_preds_V.extend(predicted_valence.cpu().numpy())
        
        avg_loss = total_loss / (dataset_size + 1e-6) # [수정] 전체 샘플 수로 나누기
        
        return avg_loss, (all_labels_A, all_preds_A), (all_labels_V, all_preds_V)
    # ▲▲▲▲▲ [수정] validate 함수 끝 ▲▲▲▲▲
    
    # ▼▼▼▼▼ [수정] train 함수: F1 기준으로 저장 ▼▼▼▼▼
    def train(self, train_loader: DataLoader, val_loader: DataLoader, epochs: int = 50):
        print(f"🏋️ VGGish A/V Multi-Task Classification 훈련 시작: {epochs} 에포크"); print("="*60)
        
        # best_val_loss = float('inf') # Loss 기준 대신
        best_val_f1_avg = 0.0 # F1 Macro 평균 기준으로 변경
        
        for epoch in range(epochs):
            print(f"\n📅 에포크 {epoch+1}/{epochs}"); print("-" * 40)
            
            train_loss, train_acc_A, train_acc_V = self.train_epoch(train_loader)
            val_loss, (labels_A, preds_A), (labels_V, preds_V) = self.validate(val_loader)
            
            val_acc_A = accuracy_score(labels_A, preds_A) * 100
            val_acc_V = accuracy_score(labels_V, preds_V) * 100
            
            # [추가] F1 Macro 점수 계산
            f1_A_macro = f1_score(labels_A, preds_A, average='macro', zero_division=0)
            f1_V_macro = f1_score(labels_V, preds_V, average='macro', zero_division=0)
            # [추가] 두 Macro F1의 평균
            current_f1_avg = (f1_A_macro + f1_V_macro) / 2
            
            last_lr = self.optimizer.param_groups[0]['lr']
            self.scheduler.step(val_loss)
            
            print(f"훈련 - Loss: {train_loss:.4f}, Arousal Acc: {train_acc_A:.2f}%, Valence Acc: {train_acc_V:.2f}%")
            # [수정] F1 평균 점수 출력
            print(f"검증 - Loss: {val_loss:.4f}, Arousal Acc: {val_acc_A:.2f}%, Valence Acc: {val_acc_V:.2f}%, F1-Avg: {current_f1_avg:.4f}")
            if last_lr != self.optimizer.param_groups[0]['lr']:
                print(f"   (Learning rate reduced to {self.optimizer.param_groups[0]['lr']:.1e})")

            # 상세 리포트 생성 및 출력 (이전과 동일)
            print("\n--- 검증: Arousal Report ---")
            report_A = classification_report(labels_A, preds_A, target_names=AROUSAL_NAMES, labels=np.arange(NUM_AROUSAL_CLASSES), digits=4, zero_division=0)
            print(report_A)
            print("\n--- 검증: Valence Report ---")
            report_V = classification_report(labels_V, preds_V, target_names=VALENCE_NAMES, labels=np.arange(NUM_VALENCE_CLASSES), digits=4, zero_division=0)
            print(report_V)
            print("-" * 40)

            # [수정] F1 평균 점수를 기준으로 모델 저장
            if current_f1_avg > best_val_f1_avg:
                best_val_f1_avg = current_f1_avg
                # [수정] 파일 이름에 F1 점수 반영
                self.save_model(f"best_dog_vggish_av_f1_{current_f1_avg:.4f}.pt")
                print(f"✅ 최고 F1 (Macro Avg) 갱신! 모델 저장됨! (F1: {current_f1_avg:.4f})")
                
        print(f"\n🎉 훈련 완료! 최고 검증 F1 (Macro Avg): {best_val_f1_avg:.4f}")
    # ▲▲▲▲▲ [수정] train 함수 끝 ▲▲▲▲▲
    
    def save_model(self, filename: str):
        save_dict = {
            'vggish_state_dict': self.vggish.state_dict(),
            'shared_mlp_state_dict': self.shared_mlp.state_dict(),
            'arousal_head_state_dict': self.arousal_head.state_dict(),
            'valence_head_state_dict': self.valence_head.state_dict(),
        }
        torch.save(save_dict, filename); print(f"💾 모델 저장: {filename}")
    
    def load_model(self, filename: str):
        checkpoint = torch.load(filename, map_location=self.device)
        self.vggish.load_state_dict(checkpoint['vggish_state_dict'])
        self.shared_mlp.load_state_dict(checkpoint['shared_mlp_state_dict'])
        self.arousal_head.load_state_dict(checkpoint['arousal_head_state_dict'])
        self.valence_head.load_state_dict(checkpoint['valence_head_state_dict'])
        print(f"📂 모델 로드: {filename}")

# --- (load_data_from_csv_and_dir 함수는 이전과 동일) ---
def load_data_from_csv_and_dir(csv_path: str, audio_dir: str):
    print(f"📁 데이터 로드 중: {csv_path}")
    try: df = pd.read_csv(csv_path)
    except FileNotFoundError: print(f"❌ 오류: CSV 파일({csv_path}) 없음."); return [], [], []
    except Exception as e: print(f"❌ 오류: CSV 읽기 실패: {e}"); return [], [], []
    audio_files, arousal_labels, valence_labels = [], [], []
    missing_files = 0
    for _, row in df.iterrows():
        try:
            audio_id = row['audio_id']
            if not str(audio_id).endswith('.wav'): audio_id = str(audio_id) + '.wav'
            audio_path = os.path.join(audio_dir, audio_id)
            if os.path.exists(audio_path):
                audio_files.append(audio_path)
                arousal_labels.append(AROUSAL_MAP[row['arousal']])
                valence_labels.append(VALENCE_MAP[row['valence']])
            else: missing_files += 1
        except KeyError as e: print(f"⚠️ 경고: CSV에 {e} 열이 없거나 라벨 맵에 없는 값: {row}")
        except Exception as e: print(f"⚠️ 경고: 데이터 처리 중 오류 (행: {row}): {e}")
    print(f"📊 총 {len(df)} 행 중 {len(audio_files)} 개의 오디오 파일 로드 완료.")
    if missing_files > 0: print(f"❌ 누락된 파일 수: {missing_files} 개 (경로: {audio_dir})")
    return audio_files, arousal_labels, valence_labels

def main():
    """메인 함수"""
    print("🎵 VGGish 강아지 A/V 멀티태스크 분류 훈련")
    print("="*50)

    TRAIN_CSV_PATH = "final_audio_train.csv"
    VAL_CSV_PATH = "final_audio_val.csv"
    '''
    # --- 1. [TODO] 사용자 설정: 여기에 실제 경로를 입력하세요 ---
    # ----------------------------------------------------
    
    # (자동 경로 설정)
    TRAIN_CSV_PATHS = [
        os.path.join(BASE_PATH, "husky_train_labels.csv"),
        os.path.join(BASE_PATH, "shiba_train_labels.csv")
    ]
    TRAIN_AUDIO_DIRS = [
        os.path.join(BASE_PATH, "husky", "train"),
        os.path.join(BASE_PATH, "shiba", "train")
    ]
    VAL_CSV_PATHS = [
        os.path.join(BASE_PATH, "husky_test_labels.csv"),
        os.path.join(BASE_PATH, "shiba_test_labels.csv")
    ]
    VAL_AUDIO_DIRS = [
        os.path.join(BASE_PATH, "husky", "test"),
        os.path.join(BASE_PATH, "shiba", "test")
    ]
    '''
    # 가상 침묵 데이터 개수
    NUM_SILENT_TRAIN = 0
    NUM_SILENT_VAL = 0
    
    # 하이퍼파라미터
    BATCH_SIZE = 512
    EPOCHS = 300
    LR_VGGISH = 1e-5
    LR_CLASSIFIER = 1e-3
    NUM_WORKERS = 12 # 윈도우 환경 오류 방지 위해 0으로 설정

    # 1. 데이터셋 준비
    print("--- 훈련 데이터 로드 ---")
    # ▼▼▼▼▼ [수정] `load_data_from_csv` 대신 새 CSV 로드 ▼▼▼▼▼
    try:
        train_df = pd.read_csv(TRAIN_CSV_PATH)
        # 'full_path' 열에서 파일 경로를 바로 읽음
        real_train_files = train_df['full_path'].tolist()
        real_train_labels_A = train_df['arousal'].map(AROUSAL_MAP).tolist()
        real_train_labels_V = train_df['valence'].map(VALENCE_MAP).tolist()
        print(f"📊 총 {len(real_train_files)} 개의 훈련 오디오 파일 로드 완료.")
    except Exception as e:
        print(f"❌ 오류: '{TRAIN_CSV_PATH}' 로드 실패. {e}")
        print("   > `prepare_audio_data.py`를 먼저 실행했는지 확인하세요.")
        return

    print("\n--- 검증 데이터 로드 ---")
    try:
        val_df = pd.read_csv(VAL_CSV_PATH)
        real_val_files = val_df['full_path'].tolist()
        real_val_labels_A = val_df['arousal'].map(AROUSAL_MAP).tolist()
        real_val_labels_V = val_df['valence'].map(VALENCE_MAP).tolist()
        print(f"📊 총 {len(real_val_files)} 개의 검증 오디오 파일 로드 완료.")
    except Exception as e:
        print(f"❌ 오류: '{VAL_CSV_PATH}' 로드 실패. {e}")
        return
    # ▲▲▲▲▲ [수정] 새 CSV 로드 끝 ▲▲▲▲▲

    if not real_train_files: print("❌ 오류: 훈련 데이터 없음."); return
        
    # --- 가상 침묵 데이터 추가 (현재 0개) ---
    if NUM_SILENT_TRAIN > 0 or NUM_SILENT_VAL > 0:
        print(f"\n--- 가상 침묵 데이터 추가 ---")
        silent_train_paths = ["SILENT"] * NUM_SILENT_TRAIN
        silent_train_labels_A = [SILENCE_AROUSAL_LABEL] * NUM_SILENT_TRAIN
        silent_train_labels_V = [SILENCE_VALENCE_LABEL] * NUM_SILENT_TRAIN
        silent_val_paths = ["SILENT"] * NUM_SILENT_VAL
        silent_val_labels_A = [SILENCE_AROUSAL_LABEL] * NUM_SILENT_VAL
        silent_val_labels_V = [SILENCE_VALENCE_LABEL] * NUM_SILENT_VAL
        print(f"  > 가상 침묵 데이터 생성: 훈련 {NUM_SILENT_TRAIN}개, 검증 {NUM_SILENT_VAL}개")
        
        train_files = real_train_files + silent_train_paths
        train_labels_A = real_train_labels_A + silent_train_labels_A
        train_labels_V = real_train_labels_V + silent_train_labels_V
        val_files = real_val_files + silent_val_paths
        val_labels_A = real_val_labels_A + silent_val_labels_A
        val_labels_V = real_val_labels_V + silent_val_labels_V
    else:
        print("\n--- 가상 침묵 데이터 추가 안 함 ---")
        train_files, train_labels_A, train_labels_V = real_train_files, real_train_labels_A, real_train_labels_V
        val_files, val_labels_A, val_labels_V = real_val_files, real_val_labels_A, real_val_labels_V

    # [수정] 섞기 로직을 결합 후로 이동
    combined_train = list(zip(train_files, train_labels_A, train_labels_V)); random.shuffle(combined_train)
    train_files, train_labels_A, train_labels_V = zip(*combined_train)
    combined_val = list(zip(val_files, val_labels_A, val_labels_V)); random.shuffle(combined_val)
    val_files, val_labels_A, val_labels_V = zip(*combined_val)
    
    print(f"🏋️ 총 훈련 데이터: {len(train_files)}개 (실제 {len(real_train_files)}, 침묵 {NUM_SILENT_TRAIN})")
    print(f"📊 총 검증 데이터: {len(val_files)}개 (실제 {len(real_val_files)}, 침묵 {NUM_SILENT_VAL})")
    
    # 2. 데이터셋 및 데이터로더 생성
    train_dataset = DogAudioDataset(list(train_files), list(train_labels_A), list(train_labels_V), train=True)
    val_dataset = DogAudioDataset(list(val_files), list(val_labels_A), list(val_labels_V), train=False)
    
    # ▼▼▼▼▼ [수정] WeightedRandomSampler 대신 일반 Shuffle 사용 ▼▼▼▼▼
    train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True, num_workers=NUM_WORKERS)
    val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE, shuffle=False, num_workers=NUM_WORKERS)
    print("\n일반 Shuffle 사용 (가중 손실 함수 적용됨).")
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

    # 3. 트레이너 생성 및 훈련
    
    # ▼▼▼▼▼ [수정] 가중 손실 함수 계산 (새로운 훈련 데이터 라벨 기준) ▼▼▼▼▼
    print("\n클래스 가중치 계산 중 (새 훈련 데이터 기준)...")
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    
    # Arousal 가중치 (재분배된 훈련 라벨 real_train_labels_A 사용)
    counts_A = np.bincount(real_train_labels_A, minlength=NUM_AROUSAL_CLASSES)
    weights_A = None
    if all(c > 0 for c in counts_A):
        weights_A = torch.tensor([1.0 / math.sqrt(c) for c in counts_A], dtype=torch.float).to(device)
        weights_A = weights_A / weights_A.mean() # 평균 1로 정규화
    else:
        print("  > 경고: Arousal 훈련 데이터에 일부 클래스 부재. 가중치 미적용.")

    # Valence 가중치 (재분배된 훈련 라벨 real_train_labels_V 사용)
    counts_V = np.bincount(real_train_labels_V, minlength=NUM_VALENCE_CLASSES)
    weights_V = None
    if all(c > 0 for c in counts_V):
        weights_V = torch.tensor([1.0 / math.sqrt(c) for c in counts_V], dtype=torch.float).to(device)
        weights_V = weights_V / weights_V.mean() # 평균 1로 정규화
    else:
        print("  > 경고: Valence 훈련 데이터에 일부 클래스 부재. 가중치 미적용.")
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

    trainer = DogVGGishTrainer(
        num_arousal_classes=NUM_AROUSAL_CLASSES, 
        num_valence_classes=NUM_VALENCE_CLASSES,
        arousal_weights=weights_A, # [수정] 가중치 전달
        valence_weights=weights_V, # [수정] 가중치 전달
        device=device
    )
    trainer.setup_optimizer(lr_vggish=LR_VGGISH, lr_classifier=LR_CLASSIFIER)
    trainer.train(train_loader, val_loader, epochs=EPOCHS)
    
if __name__ == "__main__":
    main()