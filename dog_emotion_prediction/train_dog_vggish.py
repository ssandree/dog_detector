#!/usr/bin/env python3
"""
VGGish 파인튜닝 스크립트
사전학습된 VGGish를 강아지 오디오 데이터로 파인튜닝
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

class DogAudioDataset(Dataset):
    """
    강아지 오디오 데이터셋
    """
    
    def __init__(self, audio_files: List[str], labels: List[int], transform=None):
        """
        Args:
            audio_files: 오디오 파일 경로 리스트
            labels: 각 오디오에 대응하는 라벨 (감정 클래스)
            transform: 오디오 변환 함수
        """
        self.audio_files = audio_files
        self.labels = labels
        self.transform = transform
        
        # 라벨을 텐서로 변환
        self.labels_tensor = torch.LongTensor(labels)
        
    def __len__(self):
        return len(self.audio_files)
    
    def __getitem__(self, idx):
        """
        데이터셋에서 하나의 샘플 반환
        """
        audio_path = self.audio_files[idx]
        label = self.labels_tensor[idx]
        
        try:
            # VGGish 입력 형태로 오디오 변환
            audio_input = vggish_input.wavfile_to_examples(audio_path)
            
            # 여러 프레임이 있을 경우 평균 또는 첫 번째 프레임 사용
            if len(audio_input) > 1:
                # 랜덤하게 하나 선택 (데이터 증강 효과)
                frame_idx = np.random.randint(0, len(audio_input))
                audio_tensor = torch.from_numpy(audio_input[frame_idx]).float()
            else:
                audio_tensor = torch.from_numpy(audio_input[0]).float()
            
            # (96, 64) -> (1, 96, 64) 채널 차원 추가
            audio_tensor = audio_tensor.unsqueeze(0)
            
            return audio_tensor, label
            
        except Exception as e:
            print(f"⚠️ 오디오 로딩 실패 {audio_path}: {e}")
            # 에러 시 더미 데이터 반환
            dummy_audio = torch.zeros(1, 96, 64)
            return dummy_audio, label

class DogVGGishTrainer:
    """
    VGGish 파인튜닝 트레이너
    """
    
    def __init__(self, num_classes: int = 8, device: str = 'auto'):
        """
        Args:
            num_classes: 감정 클래스 개수 (기쁨, 흥분, 차분, 불안, 공격적, 두려움, 장난기, 피곤)
            device: 사용할 디바이스
        """
        self.num_classes = num_classes
        self.device = device if device != 'auto' else ('cuda' if torch.cuda.is_available() else 'cpu')
        
        # VGGish 모델 로드 (postprocess=False로 훈련 가능하게)
        self.vggish = vggish(postprocess=False)
        
        # 분류기 레이어 교체 (128 -> num_classes)
        self.classifier = nn.Sequential(
            nn.Linear(128, 256),
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(256, num_classes)
        )
        
        # GPU로 이동
        self.vggish = self.vggish.to(self.device)
        self.classifier = self.classifier.to(self.device)
        
        # 손실 함수
        self.criterion = nn.CrossEntropyLoss()
        
        print(f"🎵 VGGish 파인튜닝 준비 완료")
        print(f"📊 클래스 수: {num_classes}")
        print(f"🎮 디바이스: {self.device}")
    
    def setup_optimizer(self, lr_vggish: float = 1e-5, lr_classifier: float = 1e-3):
        """
        옵티마이저 설정
        Args:
            lr_vggish: VGGish 백본의 학습률 (낮게)
            lr_classifier: 분류기의 학습률 (높게)
        """
        # 다른 학습률로 파라미터 그룹 분리
        self.optimizer = optim.Adam([
            {'params': self.vggish.parameters(), 'lr': lr_vggish},
            {'params': self.classifier.parameters(), 'lr': lr_classifier}
        ])
        
        # 학습률 스케줄러
        self.scheduler = optim.lr_scheduler.ReduceLROnPlateau(
            self.optimizer, mode='min', factor=0.5, patience=5, verbose=True
        )
        
        print(f"⚙️ 옵티마이저 설정: VGGish lr={lr_vggish}, Classifier lr={lr_classifier}")
    
    def forward(self, x):
        """순전파"""
        # VGGish 특성 추출
        vggish_features = self.vggish(x)
        
        # 분류기 통과
        output = self.classifier(vggish_features)
        
        return output, vggish_features
    
    def train_epoch(self, dataloader: DataLoader):
        """한 에포크 훈련"""
        self.vggish.train()
        self.classifier.train()
        
        total_loss = 0.0
        correct = 0
        total = 0
        
        for batch_idx, (audio, labels) in enumerate(dataloader):
            audio = audio.to(self.device)
            labels = labels.to(self.device)
            
            # 순전파
            outputs, features = self.forward(audio)
            loss = self.criterion(outputs, labels)
            
            # 역전파
            self.optimizer.zero_grad()
            loss.backward()
            self.optimizer.step()
            
            # 통계
            total_loss += loss.item()
            _, predicted = outputs.max(1)
            total += labels.size(0)
            correct += predicted.eq(labels).sum().item()
            
            if batch_idx % 10 == 0:
                print(f"  배치 {batch_idx}/{len(dataloader)}: Loss={loss.item():.4f}")
        
        avg_loss = total_loss / len(dataloader)
        accuracy = 100.0 * correct / total
        
        return avg_loss, accuracy
    
    def validate(self, dataloader: DataLoader):
        """검증"""
        self.vggish.eval()
        self.classifier.eval()
        
        total_loss = 0.0
        correct = 0
        total = 0
        
        with torch.no_grad():
            for audio, labels in dataloader:
                audio = audio.to(self.device)
                labels = labels.to(self.device)
                
                outputs, _ = self.forward(audio)
                loss = self.criterion(outputs, labels)
                
                total_loss += loss.item()
                _, predicted = outputs.max(1)
                total += labels.size(0)
                correct += predicted.eq(labels).sum().item()
        
        avg_loss = total_loss / len(dataloader)
        accuracy = 100.0 * correct / total
        
        return avg_loss, accuracy
    
    def train(self, train_loader: DataLoader, val_loader: DataLoader, epochs: int = 50):
        """
        전체 훈련 루프
        """
        print(f"🏋️ VGGish 파인튜닝 시작: {epochs} 에포크")
        print("="*60)
        
        best_val_acc = 0.0
        
        for epoch in range(epochs):
            print(f"\n📅 에포크 {epoch+1}/{epochs}")
            print("-" * 40)
            
            # 훈련
            train_loss, train_acc = self.train_epoch(train_loader)
            
            # 검증
            val_loss, val_acc = self.validate(val_loader)
            
            # 학습률 조정
            self.scheduler.step(val_loss)
            
            print(f"훈련 - Loss: {train_loss:.4f}, Acc: {train_acc:.2f}%")
            print(f"검증 - Loss: {val_loss:.4f}, Acc: {val_acc:.2f}%")
            
            # 최고 모델 저장
            if val_acc > best_val_acc:
                best_val_acc = val_acc
                self.save_model(f"best_dog_vggish_epoch{epoch+1}_acc{val_acc:.1f}.pt")
                print(f"✅ 최고 성능 모델 저장! (검증 정확도: {val_acc:.2f}%)")
        
        print(f"\n🎉 훈련 완료! 최고 검증 정확도: {best_val_acc:.2f}%")
    
    def save_model(self, filename: str):
        """모델 저장"""
        save_dict = {
            'vggish_state_dict': self.vggish.state_dict(),
            'classifier_state_dict': self.classifier.state_dict(),
            'num_classes': self.num_classes,
        }
        torch.save(save_dict, filename)
        print(f"💾 모델 저장: {filename}")
    
    def load_model(self, filename: str):
        """모델 로드"""
        checkpoint = torch.load(filename, map_location=self.device)
        
        self.vggish.load_state_dict(checkpoint['vggish_state_dict'])
        self.classifier.load_state_dict(checkpoint['classifier_state_dict'])
        
        print(f"📂 모델 로드: {filename}")

def create_sample_dataset(data_dir: str = "sample_dog_audio"):
    """
    샘플 데이터셋 생성 예제
    실제 사용시에는 여러분의 강아지 오디오 데이터 경로로 수정하세요
    """
    print("📁 샘플 데이터셋 생성 (실제 데이터로 교체하세요)")
    
    # 감정 라벨 매핑
    emotion_labels = {
        '기쁨': 0, '흥분': 1, '차분': 2, '불안': 3,
        '공격적': 4, '두려움': 5, '장난기': 6, '피곤': 7
    }
    
    audio_files = []
    labels = []
    
    # 실제 데이터 경로 예시
    # for emotion, label_id in emotion_labels.items():
    #     emotion_dir = Path(data_dir) / emotion
    #     if emotion_dir.exists():
    #         for audio_file in emotion_dir.glob("*.wav"):
    #             audio_files.append(str(audio_file))
    #             labels.append(label_id)
    
    # 더미 데이터 (실제로는 위의 주석 코드 사용)
    for i in range(100):
        audio_files.append(f"dummy_audio_{i}.wav")
        labels.append(i % 8)  # 8개 감정 클래스
    
    return audio_files, labels, emotion_labels

def main():
    """메인 함수"""
    print("🎵 VGGish 강아지 감정 분류 훈련")
    print("="*50)
    
    # 1. 데이터셋 준비
    audio_files, labels, emotion_labels = create_sample_dataset()
    print(f"📊 데이터 개수: {len(audio_files)}")
    print(f"🏷️ 감정 라벨: {list(emotion_labels.keys())}")
    
    # 2. 데이터셋 분할 (80% 훈련, 20% 검증)
    split_idx = int(0.8 * len(audio_files))
    
    train_files = audio_files[:split_idx]
    train_labels = labels[:split_idx]
    val_files = audio_files[split_idx:]
    val_labels = labels[split_idx:]
    
    print(f"🏋️ 훈련 데이터: {len(train_files)}")
    print(f"📊 검증 데이터: {len(val_files)}")
    
    # 3. 데이터셋 및 데이터로더 생성
    train_dataset = DogAudioDataset(train_files, train_labels)
    val_dataset = DogAudioDataset(val_files, val_labels)
    
    train_loader = DataLoader(train_dataset, batch_size=16, shuffle=True, num_workers=2)
    val_loader = DataLoader(val_dataset, batch_size=16, shuffle=False, num_workers=2)
    
    # 4. 트레이너 생성 및 훈련
    trainer = DogVGGishTrainer(num_classes=8)
    trainer.setup_optimizer(lr_vggish=1e-5, lr_classifier=1e-3)
    
    # 5. 훈련 실행
    trainer.train(train_loader, val_loader, epochs=20)
    
    print("\n💡 실제 사용시 주의사항:")
    print("1. create_sample_dataset() 함수를 수정하여 실제 오디오 파일 경로 설정")
    print("2. 오디오 파일은 .wav 형식이어야 함")
    print("3. 각 감정별로 폴더를 나누어 정리하면 편함")
    print("4. 충분한 데이터가 있어야 좋은 성능을 얻을 수 있음")

if __name__ == "__main__":
    main()