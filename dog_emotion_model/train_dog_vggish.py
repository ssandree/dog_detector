#!/usr/bin/env python3
"""
VGGish 파인튜닝 스크립트
(수정) 사전학습된 VGGish를 강아지 오디오 데이터로 파인튜닝
(수정) Arousal (3-Class) / Valence (3-Class) 멀티태스크 분류
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
import itertools # (옵티마이저 파라미터 그룹화를 위해 추가)

class DogAudioDataset(Dataset):
    """
    강아지 오디오 데이터셋 (Arousal/Valence 멀티태스크 분류용)
    """
    
    # [수정] 라벨을 2개의 분리된 리스트로 받음 (e.g., [0, 1, 2], [0, 1, 2])
    def __init__(self, audio_files: List[str], arousal_labels: List[int], valence_labels: List[int]):
        """
        Args:
            audio_files: 오디오 파일 경로 리스트
            arousal_labels: Arousal 라벨 (e.g., 0=Low, 1=Medium, 2=High)
            valence_labels: Valence 라벨 (e.g., 0=Negative, 1=Neutral, 2=Positive)
        """
        self.audio_files = audio_files
        
        # [수정] CrossEntropyLoss를 위해 LongTensor로 변환
        self.arousal_labels_tensor = torch.LongTensor(arousal_labels)
        self.valence_labels_tensor = torch.LongTensor(valence_labels)
        
    def __len__(self):
        return len(self.audio_files)
    
    def __getitem__(self, idx):
        """
        [수정] 2개의 라벨을 반환 (audio, label_arousal, label_valence)
        """
        audio_path = self.audio_files[idx]
        label_arousal = self.arousal_labels_tensor[idx]
        label_valence = self.valence_labels_tensor[idx]
        
        try:
            audio_input = vggish_input.wavfile_to_examples(audio_path)
            
            if len(audio_input) > 1:
                frame_idx = np.random.randint(0, len(audio_input))
                audio_tensor = torch.from_numpy(audio_input[frame_idx]).float()
            else:
                audio_tensor = torch.from_numpy(audio_input[0]).float()
            
            audio_tensor = audio_tensor.unsqueeze(0) # (1, 96, 64)
            
            return audio_tensor, label_arousal, label_valence
            
        except Exception as e:
            print(f"⚠️ 오디오 로딩 실패 {audio_path}: {e}")
            dummy_audio = torch.zeros(1, 96, 64)
            dummy_label = 0 # 어차피 0번 라벨로 학습됨
            return dummy_audio, dummy_label, dummy_label

class DogVGGishTrainer:
    """
    VGGish 파인튜닝 트레이너 (A/V 멀티태스크 분류용)
    """
    
    # [수정] 2개의 클래스 수를 인자로 받음
    def __init__(self, num_arousal_classes: int = 3, num_valence_classes: int = 3, device: str = 'auto'):
        self.device = device if device != 'auto' else ('cuda' if torch.cuda.is_available() else 'cpu')
        
        self.vggish = vggish(postprocess=False)
        
        # [수정] Multi-Head Classifier
        # VGGish 출력(128) -> 공통 MLP(256) -> 2개의 분리된 Head
        self.shared_mlp = nn.Sequential(
            nn.Linear(128, 256),
            nn.ReLU(),
            nn.Dropout(0.5)
        )
        self.arousal_head = nn.Linear(256, num_arousal_classes)
        self.valence_head = nn.Linear(256, num_valence_classes)
        
        self.vggish = self.vggish.to(self.device)
        self.shared_mlp = self.shared_mlp.to(self.device)
        self.arousal_head = self.arousal_head.to(self.device)
        self.valence_head = self.valence_head.to(self.device)
        
        # [수정] 2개의 분리된 손실 함수 (분류용)
        self.criterion_arousal = nn.CrossEntropyLoss()
        self.criterion_valence = nn.CrossEntropyLoss()
        
        print(f"🎵 VGGish A/V Multi-Task Classification 파인튜닝 준비 완료")
        print(f"📊 Arousal 클래스 수: {num_arousal_classes}, Valence 클래스 수: {num_valence_classes}")
        print(f"🎮 디바이스: {self.device}")
    
    def setup_optimizer(self, lr_vggish: float = 1e-5, lr_classifier: float = 1e-3):
        # [수정] VGGish / 나머지(MLP+Heads) 파라미터 그룹 분리
        classifier_params = itertools.chain(self.shared_mlp.parameters(), 
                                            self.arousal_head.parameters(), 
                                            self.valence_head.parameters())
        
        self.optimizer = optim.Adam([
            {'params': self.vggish.parameters(), 'lr': lr_vggish},
            {'params': classifier_params, 'lr': lr_classifier}
        ])
        
        self.scheduler = optim.lr_scheduler.ReduceLROnPlateau(
            self.optimizer, mode='min', factor=0.5, patience=5, verbose=True
        )
        print(f"⚙️ 옵티마이저 설정: VGGish lr={lr_vggish}, Classifier Heads lr={lr_classifier}")
    
    def forward(self, x):
        """[수정] 2개의 출력을 반환"""
        vggish_features = self.vggish(x)
        shared_features = self.shared_mlp(vggish_features)
        output_arousal = self.arousal_head(shared_features)
        output_valence = self.valence_head(shared_features)
        return output_arousal, output_valence
    
    def train_epoch(self, dataloader: DataLoader):
        """[수정] 멀티태스크 훈련"""
        self.vggish.train(); self.shared_mlp.train()
        self.arousal_head.train(); self.valence_head.train()
        
        total_loss = 0.0
        correct_arousal, correct_valence, total = 0, 0, 0
        
        for batch_idx, (audio, labels_arousal, labels_valence) in enumerate(dataloader):
            audio = audio.to(self.device)
            labels_arousal = labels_arousal.to(self.device)
            labels_valence = labels_valence.to(self.device)
            
            outputs_arousal, outputs_valence = self.forward(audio)
            
            # [수정] 2개의 손실을 계산하고 더함
            loss_arousal = self.criterion_arousal(outputs_arousal, labels_arousal)
            loss_valence = self.criterion_valence(outputs_valence, labels_valence)
            loss = loss_arousal + loss_valence # 총 손실
            
            self.optimizer.zero_grad()
            loss.backward()
            self.optimizer.step()
            
            total_loss += loss.item()
            total += labels_arousal.size(0)

            # [수정] 2개의 정확도 계산
            _, predicted_arousal = outputs_arousal.max(1)
            correct_arousal += predicted_arousal.eq(labels_arousal).sum().item()
            
            _, predicted_valence = outputs_valence.max(1)
            correct_valence += predicted_valence.eq(labels_valence).sum().item()
            
            if batch_idx % 10 == 0:
                print(f"  배치 {batch_idx}/{len(dataloader)}: Total Loss={loss.item():.4f} (A: {loss_arousal.item():.4f}, V: {loss_valence.item():.4f})")
        
        avg_loss = total_loss / len(dataloader)
        acc_arousal = 100.0 * correct_arousal / total
        acc_valence = 100.0 * correct_valence / total
        
        return avg_loss, acc_arousal, acc_valence # [수정] 3개 값 반환
    
    def validate(self, dataloader: DataLoader):
        """[수정] 멀티태스크 검증"""
        self.vggish.eval(); self.shared_mlp.eval()
        self.arousal_head.eval(); self.valence_head.eval()
        
        total_loss = 0.0
        correct_arousal, correct_valence, total = 0, 0, 0
        
        with torch.no_grad():
            for audio, labels_arousal, labels_valence in dataloader:
                audio = audio.to(self.device)
                labels_arousal = labels_arousal.to(self.device)
                labels_valence = labels_valence.to(self.device)
                
                outputs_arousal, outputs_valence = self.forward(audio)
                
                loss_arousal = self.criterion_arousal(outputs_arousal, labels_arousal)
                loss_valence = self.criterion_valence(outputs_valence, labels_valence)
                loss = loss_arousal + loss_valence
                
                total_loss += loss.item()
                total += labels_arousal.size(0)

                _, predicted_arousal = outputs_arousal.max(1)
                correct_arousal += predicted_arousal.eq(labels_arousal).sum().item()
                
                _, predicted_valence = outputs_valence.max(1)
                correct_valence += predicted_valence.eq(labels_valence).sum().item()
        
        avg_loss = total_loss / len(dataloader)
        acc_arousal = 100.0 * correct_arousal / total
        acc_valence = 100.0 * correct_valence / total
        
        return avg_loss, acc_arousal, acc_valence # [수정] 3개 값 반환
    
    def train(self, train_loader: DataLoader, val_loader: DataLoader, epochs: int = 50):
        print(f"🏋️ VGGish A/V Multi-Task Classification 훈련 시작: {epochs} 에포크")
        print("="*60)
        
        best_val_loss = float('inf') # [수정] Loss 기준으로 저장
        
        for epoch in range(epochs):
            print(f"\n📅 에포크 {epoch+1}/{epochs}")
            print("-" * 40)
            
            # [수정] 3개 값 반환 받음
            train_loss, train_acc_A, train_acc_V = self.train_epoch(train_loader)
            val_loss, val_acc_A, val_acc_V = self.validate(val_loader)
            
            self.scheduler.step(val_loss)
            
            # [수정] 2개 정확도 모두 출력
            print(f"훈련 - Loss: {train_loss:.4f}, Arousal Acc: {train_acc_A:.2f}%, Valence Acc: {train_acc_V:.2f}%")
            print(f"검증 - Loss: {val_loss:.4f}, Arousal Acc: {val_acc_A:.2f}%, Valence Acc: {val_acc_V:.2f}%")
            
            # [수정] Loss가 가장 낮을 때 저장
            if val_loss < best_val_loss:
                best_val_loss = val_loss
                avg_acc = (val_acc_A + val_acc_V) / 2
                self.save_model(f"best_dog_vggish_av_loss{val_loss:.4f}_acc{avg_acc:.1f}.pt")
                print(f"✅ 최고 성능 모델 저장! (검증 Loss: {val_loss:.4f})")
        
        print(f"\n🎉 훈련 완료! 최저 검증 Loss: {best_val_loss:.4f}")
    
    def save_model(self, filename: str):
        """[수정] 4개 state_dict 저장"""
        save_dict = {
            'vggish_state_dict': self.vggish.state_dict(),
            'shared_mlp_state_dict': self.shared_mlp.state_dict(),
            'arousal_head_state_dict': self.arousal_head.state_dict(),
            'valence_head_state_dict': self.valence_head.state_dict(),
            # 'num_classes': self.num_classes, # (삭제)
        }
        torch.save(save_dict, filename)
        print(f"💾 모델 저장: {filename}")
    
    def load_model(self, filename: str):
        """[수정] 4개 state_dict 로드"""
        checkpoint = torch.load(filename, map_location=self.device)
        
        self.vggish.load_state_dict(checkpoint['vggish_state_dict'])
        self.shared_mlp.load_state_dict(checkpoint['shared_mlp_state_dict'])
        self.arousal_head.load_state_dict(checkpoint['arousal_head_state_dict'])
        self.valence_head.load_state_dict(checkpoint['valence_head_state_dict'])
        
        print(f"📂 모델 로드: {filename}")

def create_sample_dataset(data_dir: str = "sample_dog_audio"):
    """
    [수정] Arousal/Valence 라벨을 반환하는 샘플 데이터셋
    """
    print("📁 샘플 A/V 데이터셋 생성 (실제 데이터로 교체하세요)")
    
    # [수정] 라벨 매핑 예시
    # arousal_map = {'Low': 0, 'Medium': 1, 'High': 2}
    # valence_map = {'Negative': 0, 'Neutral': 1, 'Positive': 2}
    
    audio_files = []
    arousal_labels = []
    valence_labels = []
    
    # 더미 데이터 (실제로는 CSV 등에서 로드)
    for i in range(100):
        audio_files.append(f"dummy_audio_{i}.wav")
        arousal_labels.append(i % 3) # (0, 1, 2)
        valence_labels.append(i % 3) # (0, 1, 2)
    
    return audio_files, arousal_labels, valence_labels

def main():
    """메인 함수"""
    print("🎵 VGGish 강아지 A/V 멀티태스크 분류 훈련")
    print("="*50)
    
    # 1. 데이터셋 준비
    # [수정] 2개의 라벨 리스트를 받음
    audio_files, arousal_labels, valence_labels = create_sample_dataset()
    print(f"📊 데이터 개수: {len(audio_files)}")
    
    # 2. 데이터셋 분할
    split_idx = int(0.8 * len(audio_files))
    
    train_files = audio_files[:split_idx]
    train_labels_A = arousal_labels[:split_idx]
    train_labels_V = valence_labels[:split_idx]
    
    val_files = audio_files[split_idx:]
    val_labels_A = arousal_labels[split_idx:]
    val_labels_V = valence_labels[split_idx:]
    
    print(f"🏋️ 훈련 데이터: {len(train_files)}")
    print(f"📊 검증 데이터: {len(val_files)}")
    
    # 3. 데이터셋 및 데이터로더 생성
    # [수정] 2개의 라벨을 Dataset에 전달
    train_dataset = DogAudioDataset(train_files, train_labels_A, train_labels_V)
    val_dataset = DogAudioDataset(val_files, val_labels_A, val_labels_V)
    
    train_loader = DataLoader(train_dataset, batch_size=16, shuffle=True, num_workers=2)
    val_loader = DataLoader(val_dataset, batch_size=16, shuffle=False, num_workers=2)
    
    # 4. 트레이너 생성
    # [수정] 클래스 개수(3, 3) 전달
    trainer = DogVGGishTrainer(num_arousal_classes=3, num_valence_classes=3)
    trainer.setup_optimizer(lr_vggish=1e-5, lr_classifier=1e-3)
    
    # 5. 훈련 실행
    trainer.train(train_loader, val_loader, epochs=20)
    
    print("\n💡 실제 사용시 주의사항:")
    print("1. create_sample_dataset() 함수를 수정하여 실제 오디오 파일 경로와 A/V 라벨 로드")
    print("2. Arousal 라벨(0,1,2)과 Valence 라벨(0,1,2)이 순서대로 매칭되어야 함")

if __name__ == "__main__":
    main()