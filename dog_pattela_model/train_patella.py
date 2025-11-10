#!/usr/bin/env python3
"""
슬개골 탈구 ST-GCN 모델 학습 스크립트
- F1-score 최고값으로 모델 저장 (비디오 단위 평가)
- [수정] WeightedRandomSampler 사용
- [수정] seg_len 미만 짧은 비디오 필터링
- [수정] Train/Val 폴더를 합쳐서 8:2로 (계층적) 재분배
- [수정] torch.load 오류 수정, weight_decay 증가
"""

import os
import sys
import json
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
import numpy as np
from sklearn.metrics import f1_score, classification_report, confusion_matrix
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split 
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
from tqdm import tqdm
import time
from datetime import datetime
import argparse
from typing import List, Tuple, Any, Dict
from collections import defaultdict
import torch.nn.functional as F
import math 
from importlib import import_module 
import random 

# 한글 폰트 설정
plt.rcParams['font.family'] = 'Malgun Gothic'
plt.rcParams['axes.unicode_minus'] = False

# 동적 임포트 블록
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
common_path = os.path.join(project_root, 'common')
sys.path.insert(0, common_path)

try:
    data_preprocess = import_module('data_preprocess_patella') 
    DogPoseDataset = data_preprocess.DogPoseDataset
    calculate_and_save_stats = data_preprocess.calculate_and_save_stats
    if __name__ == "__main__":
        print("✅ data_preprocess_patella.py 모듈 로드 성공")
except ImportError as e:
    if __name__ == "__main__":
        print(f"❌ 데이터 전처리 모듈 로드 실패: {e}")
        print(" common/data_preprocess_patella.py 파일이 있는지 확인하세요.")
    DogPoseDataset = None
    calculate_and_save_stats = None

# 모델 import
from patella_model import PatellaSTGCN # (수정된 모델 임포트)

# _collect_data 함수 (이전과 동일)
def _collect_data(json_dir, min_frames=60): 
    json_files = list(Path(json_dir).glob("*.json"))
    json_paths = []
    labels = []
    filtered_count = 0
    print(f"JSON 파일 {len(json_files)}개 발견, 필터링 중... (min_frames={min_frames})")
    label_examples = {}
    for json_file in tqdm(json_files, desc=f"데이터 수집 ({Path(json_dir).name})"):
        try:
            filename = json_file.stem
            parts = filename.split('_')
            label = parts[0]
            with open(json_file, 'r', encoding='utf-8') as f: data = json.load(f)
            dog_id = list(data.keys())[0]
            frames_data = data[dog_id]
            frame_count = len(frames_data)
            if frame_count >= min_frames:
                json_paths.append(str(json_file))
                labels.append(label)
                if label not in label_examples: label_examples[label] = []
                if len(label_examples[label]) < 3: label_examples[label].append(filename)
            else:
                filtered_count += 1
        except Exception as e:
            filtered_count += 1
    print(f"📊 수집 완료 ({Path(json_dir).name}):")
    print(f"  사용된 파일 (고품질): {len(json_paths)}개")
    print(f"  필터링된 파일 (짧은 영상): {filtered_count}개")
    if label_examples:
        print(f"\n🏷️ 발견된 라벨별 파일명 예시 ({Path(json_dir).name}):")
        for label, examples in label_examples.items():
            print(f"  '{label}': {examples}")
    return json_paths, labels

class PatellaDatasetWrapper(Dataset):
    """
    슬개골 탈구 데이터셋 래퍼 - DogPoseDataset 활용
    [수정] 2클래스 분류: 정상(0) vs 이상(1) - 1기/2기/3기/4기를 모두 '이상'으로 통합
    """
    def __init__(self, json_paths: List[str], labels: List[str], seg_len=60, stats_path=None, train=True): 
        self.seg_len = seg_len
        self.stats_path = stats_path
        self.train = train
        self.json_paths = json_paths
        self.raw_labels = labels 

        if len(self.json_paths) == 0:
            raise ValueError(f"❌ Wrapper에 유효한 데이터가 전달되지 않았습니다. (0개)")
        
        # [수정] 라벨을 2클래스로 변환: 정상=0, 나머지(1기/2기/3기/4기)=1
        binary_labels = []
        for label in self.raw_labels:
            if label == '정상':
                binary_labels.append('정상')
            else:  # 1기, 2기, 3기, 4기
                binary_labels.append('이상')
        
        self.label_encoder = LabelEncoder()
        all_possible_labels = ['정상', '이상']
        self.label_encoder.fit(all_possible_labels)
        encoded_array = self.label_encoder.transform(binary_labels)
        
        self.encoded_labels: List[int] = np.array(encoded_array).tolist()
        self.num_classes = len(self.label_encoder.classes_) # 2
        
        if DogPoseDataset is None:
            raise ImportError("DogPoseDataset을 import할 수 없습니다. data_preprocess_patella.py를 확인하세요.")
        
        self.dataset = DogPoseDataset(
            json_paths=self.json_paths,
            labels=self.encoded_labels,
            seg_len=self.seg_len,
            stats_path=self.stats_path,
            train=self.train
        )
        
        print(f"📊 Patella 데이터셋 정보 ({'Train' if train else 'Val'}):")
        print(f"  원본 비디오 수 (재분배됨): {len(self.json_paths)}개")
        print(f"  총 샘플(윈도우) 수: {len(self.dataset)}개")
        print(f"  클래스: {list(self.label_encoder.classes_)}")
        
        print(f"  라벨 매핑:")
        for i, class_name in enumerate(self.label_encoder.classes_):
            print(f"    {i}: {class_name}")
        
        if len(self.encoded_labels) > 0:
            class_counts = np.bincount(np.array(self.encoded_labels), minlength=self.num_classes)
            print(f"  [비디오 기준] 클래스 분포:")
            for i, count in enumerate(class_counts):
                if i < len(self.label_encoder.classes_):
                    print(f"    {self.label_encoder.classes_[i]}: {count}개")
        
        try:
            sample_labels = [s[2] for s in self.dataset.samples]
            sample_class_counts = np.bincount(np.array(sample_labels), minlength=self.num_classes)
            print(f"  [샘플 기준] 클래스 분포:")
            for i, count in enumerate(sample_class_counts):
                if i < len(self.label_encoder.classes_):
                    print(f"    {self.label_encoder.classes_[i]}: {count}개")
        except Exception as e:
            print(f"샘플 기준 클래스 분포 계산 실패: {e}")
            
        print(f"  seg_len (시퀀스 길이): {self.seg_len}프레임")
        if self.stats_path:
            print(f"  통계 파일: {self.stats_path}")
    
    def __len__(self):
        return len(self.dataset)
    
    def __getitem__(self, idx):
        return self.dataset[idx]

class PatellaTrainer:
    """슬개골 탈구 모델 학습기"""
    def __init__(self, args, train_paths, train_labels, val_paths, val_labels):
        self.args = args
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        print(f"사용 디바이스: {self.device}")
        
        self.train_dataset = PatellaDatasetWrapper(
            json_paths=train_paths, 
            labels=train_labels,   
            seg_len=args.seg_len,
            stats_path=args.stats_path,
            train=True
        )
        
        self.val_dataset = PatellaDatasetWrapper(
            json_paths=val_paths, 
            labels=val_labels,   
            seg_len=args.seg_len,
            stats_path=args.stats_path,
            train=False
        )
        

        self.train_loader = DataLoader(
            self.train_dataset, 
            batch_size=args.batch_size,
            shuffle=True,     # <--- Sampler를 안 쓰니 항상 True
            num_workers=args.num_workers,
            sampler=None      # <--- Sampler 제거
        )
        # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
        
        self.val_loader = DataLoader(
            self.val_dataset,
            batch_size=args.batch_size,
            shuffle=False,
            num_workers=args.num_workers
        )
        
        self.model = PatellaSTGCN(
            in_channels=3,
            num_classes=self.train_dataset.num_classes,
            dropout=args.dropout
        ).to(self.device)

        class_weights = self._calculate_class_weights_sqrt()
        self.criterion = nn.CrossEntropyLoss(weight = class_weights)
        #print(f"WeightedCrossEntropyLoss (Log) 사용 (가중치: {class_weights.cpu().numpy() if class_weights is not None else 'None'}).")
        
        self.optimizer = optim.AdamW(
            self.model.parameters(),
            lr=args.learning_rate,
            weight_decay=args.weight_decay # args에서 받음 (5e-4)
        )
        
        self.scheduler = optim.lr_scheduler.ReduceLROnPlateau(
            self.optimizer, mode='max', factor=0.5, patience=10
        )
        
        self.train_losses = []
        self.val_losses = []
        self.val_f1_scores = []
        self.best_f1 = 0.0
        self.best_epoch = 0
    
    # ▼▼▼ [수정] 이 함수를 PatellaTrainer 클래스 안에 새로 추가 (또는 덮어쓰기) ▼▼▼
    def _calculate_class_weights_sqrt(self):
        """샘플 기준 클래스 가중치 계산 (Sqrt 역수)"""
        try:
            sample_labels = [s[2] for s in self.train_dataset.dataset.samples]
            if not sample_labels:
                raise ValueError("샘플 라벨이 없습니다.")

            class_counts = np.bincount(np.array(sample_labels), minlength=self.train_dataset.num_classes)
            class_counts = np.where(class_counts == 0, 1, class_counts) 
            
            # ▼▼▼ [핵심 수정] 1.0 / np.log(c + 1) -> 1.0 / np.sqrt(c) ▼▼▼
            weights = 1.0 / np.sqrt(class_counts) 
            # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
            
            # 가중치 정규화 (합이 1이 되도록)
            weights = weights / np.sum(weights)
            # 클래스 개수 곱하기 (PyTorch 권장 방식)
            weights = weights * self.train_dataset.num_classes 
            
            weights = torch.FloatTensor(weights).to(self.device)
            return weights
            
        except Exception as e:
            print(f"샘플 기준 가중치 계산 실패: {e}. 동일 가중치 사용.")
            return None
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
    
    def train_epoch(self):
        self.model.train()
        total_loss = 0.0
        all_preds = []
        all_labels = []
        pbar = tqdm(self.train_loader, desc="Training")
        for sequences, labels, _ in pbar: 
            sequences = sequences.to(self.device)
            labels = labels.to(self.device)
            self.optimizer.zero_grad()
            outputs = self.model(sequences)
            loss = self.criterion(outputs, labels)
            loss.backward()
            torch.nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
            self.optimizer.step()
            total_loss += loss.item()
            preds = torch.argmax(outputs, dim=1)
            all_preds.extend(preds.cpu().numpy())
            all_labels.extend(labels.cpu().numpy())
            pbar.set_postfix({'loss': loss.item()})
        avg_loss = total_loss / len(self.train_loader) if len(self.train_loader) > 0 else 0
        train_f1 = f1_score(all_labels, all_preds, average='macro', zero_division=0)
        return avg_loss, train_f1
    
    def validate(self):
        self.model.eval()
        total_loss = 0.0
        video_outputs = defaultdict(list)
        video_true_labels = {}
        with torch.no_grad():
            for sequences, labels, video_indices in tqdm(self.val_loader, desc="Validation"):
                sequences = sequences.to(self.device)
                labels = labels.to(self.device)
                outputs = self.model(sequences)
                loss = self.criterion(outputs, labels)
                total_loss += loss.item()
                probabilities = F.softmax(outputs, dim=1)
                for i in range(len(video_indices)):
                    vid_idx = video_indices[i].item()
                    prob = probabilities[i].cpu()
                    label = labels[i].item()
                    video_outputs[vid_idx].append(prob)
                    video_true_labels[vid_idx] = label

        all_preds = []
        all_labels = []
        
        if not video_true_labels:
            print("경고: 검증 데이터에서 유효한 비디오 라벨을 찾을 수 없습니다.")
            return 0, 0, {}, [], []

        for vid_idx, probs_list in video_outputs.items():
            mean_prob = torch.mean(torch.stack(probs_list), dim=0)
            final_pred = torch.argmax(mean_prob).item()
            true_label = video_true_labels[vid_idx]
            
            all_preds.append(final_pred)
            all_labels.append(true_label)
            
        avg_loss = total_loss / len(self.val_loader) if len(self.val_loader) > 0 else 0
        val_f1 = f1_score(all_labels, all_preds, average='macro', zero_division=0)
        
        class_names = list(self.train_dataset.label_encoder.classes_)
        class_indices = list(range(self.train_dataset.num_classes)) 

        report = classification_report(
            all_labels, all_preds, 
            target_names=class_names,
            labels=class_indices,
            output_dict=True,
            zero_division=0
        )
        
        return avg_loss, val_f1, report, all_labels, all_preds
    
    def save_model(self, f1_score, epoch):
        if f1_score > self.best_f1:
            self.best_f1 = f1_score
            self.best_epoch = epoch
            checkpoint = {
                'epoch': epoch,
                'model_state_dict': self.model.state_dict(),
                'optimizer_state_dict': self.optimizer.state_dict(),
                'best_f1': self.best_f1,
                'label_encoder': self.train_dataset.label_encoder,
                'args': self.args
            }
            save_path = f"best_patella_stgcn_f1_{self.best_f1:.4f}.pt"
            torch.save(checkpoint, save_path)
            print(f"🎯 새로운 최고 F1-score: {self.best_f1:.4f} (에포크 {epoch}) - 모델 저장: {save_path}")
            return True
        return False
    
    def plot_training_curves(self):
        plt.figure(figsize=(15, 5))
        plt.subplot(1, 3, 1)
        plt.plot(self.train_losses, label='Train Loss (Sample avg)')
        plt.plot(self.val_losses, label='Val Loss (Sample avg)')
        plt.title('Training and Validation Loss')
        plt.xlabel('Epoch')
        plt.ylabel('Loss')
        plt.legend()
        plt.grid()
        plt.subplot(1, 3, 2)
        plt.plot(self.val_f1_scores, label='Val F1-score (Video avg)', color='green')
        plt.title('Validation F1-score (Video Level)')
        plt.xlabel('Epoch')
        plt.ylabel('F1-score')
        plt.legend()
        plt.grid()
        plt.subplot(1, 3, 3)
        
        # [수정] LR 플로팅
        if self.train_losses: 
            current_lr = self.optimizer.param_groups[0]['lr']
            lrs = [current_lr] * len(self.train_losses)
            plt.plot(lrs, label=f'LR (current={current_lr:.1E})')
        else:
            plt.plot([], label='LR (N/A)') 
        
        plt.title('Learning Rate')
        plt.xlabel('Epoch')
        plt.ylabel('LR')
        plt.legend()
        plt.grid()
        plt.tight_layout()
        plt.savefig('training_curves.png', dpi=300, bbox_inches='tight')
        plt.close()
    
    def train(self):
        print("=" * 60)
        print("🚀 슬개골 탈구 ST-GCN 학습 시작 (비디오 단위 평가)")
        print("=" * 60)
        print(f"모델 파라미터 수 (단순화됨): {sum(p.numel() for p in self.model.parameters()):,}")
        print(f"학습 데이터: {len(self.train_dataset.json_paths)} 비디오 -> {len(self.train_dataset)} 샘플")
        print(f"검증 데이터: {len(self.val_dataset.json_paths)} 비디오 -> {len(self.val_dataset)} 샘플")
        print()
        
        start_time = time.time()
        patience_counter = 0
        
        for epoch in range(self.args.epochs):
            print(f"\n에포크 {epoch+1}/{self.args.epochs}")
            print("-" * 40)
            
            train_loss, train_f1 = self.train_epoch()
            
            if len(self.val_loader) == 0:
                print("경고: 검증 데이터셋이 비어있습니다. 검증을 건너뜁니다.")
                print(f"Train Loss (Sample avg): {train_loss:.4f}, Train F1 (Sample avg): {train_f1:.4f}")
                if self.save_model(train_f1, epoch + 1):
                     patience_counter = 0
                else:
                     patience_counter += 1
                continue 
            
            val_loss, val_f1, report, val_labels, val_preds = self.validate()
            
            self.train_losses.append(train_loss)
            self.val_losses.append(val_loss)
            self.val_f1_scores.append(val_f1)
            
            print(f"Train Loss (Sample avg): {train_loss:.4f}, Train F1 (Sample avg): {train_f1:.4f}")
            print(f"Val Loss (Sample avg): {val_loss:.4f}, Val F1 (Video avg): {val_f1:.4f}")
            
            if epoch < 3 or (epoch + 1) % 5 == 0 or val_f1 > self.best_f1:
                print("\n📊 비디오 단위 클래스별 성능:")
                print("  분류 리포트:")
                print(classification_report(val_labels, val_preds, 
                                          target_names=list(self.train_dataset.label_encoder.classes_),
                                          labels=list(range(self.train_dataset.num_classes)),
                                          zero_division=0))
            
            if self.save_model(val_f1, epoch + 1):
                patience_counter = 0
            else:
                patience_counter += 1
            
            self.scheduler.step(val_f1)
            
            if patience_counter >= self.args.early_stopping:
                print(f"\n⏹️ 조기 종료 (patience: {self.args.early_stopping})")
                break
        
        end_time = time.time()
        duration = end_time - start_time
        
        print(f"\n🎉 학습 완료!")
        print(f"⏱️ 총 소요시간: {duration/3600:.2f}시간")
        print(f"🎯 최고 F1-score (비디오 단위): {self.best_f1:.4f} (에포크 {self.best_epoch})")
        
        if len(self.val_loader) > 0 and self.best_f1 > 0:
            try:
                print("최고 모델 로드하여 최종 혼동 행렬 생성...")
                checkpoint_path = f"best_patella_stgcn_f1_{self.best_f1:.4f}.pt"
                # ▼▼▼ [핵심 수정] torch.load 오류 해결 (weights_only=False) ▼▼▼
                checkpoint = torch.load(checkpoint_path, weights_only=False) 
                # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
                self.model.load_state_dict(checkpoint['model_state_dict'])
                val_loss, val_f1, report, val_labels, val_preds = self.validate()
                print("최종 혼동 행렬용 리포트:")
                print(classification_report(val_labels, val_preds, 
                                              target_names=list(self.train_dataset.label_encoder.classes_),
                                              labels=list(range(self.train_dataset.num_classes)),
                                              zero_division=0))
                self.plot_confusion_matrix(val_labels, val_preds)
            except Exception as e:
                print(f"최고 모델 로드 실패: {e}. 마지막 에포크의 혼동 행렬 사용.")
                if 'val_labels' in locals() and 'val_preds' in locals():
                    self.plot_confusion_matrix(val_labels, val_preds)
                else:
                    print("플롯할 검증 결과가 없습니다.")
            
            self.plot_training_curves()
        
    
    def plot_confusion_matrix(self, true_labels, pred_labels):
        class_names = list(self.train_dataset.label_encoder.classes_)
        cm = confusion_matrix(true_labels, pred_labels, labels=list(range(self.train_dataset.num_classes)))
        
        plt.figure(figsize=(8, 6))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                   xticklabels=class_names, yticklabels=class_names)
        plt.title('슬개골 탈구 분류 혼동 행렬 (비디오 단위)')
        plt.xlabel('예측 라벨')
        plt.ylabel('실제 라벨')
        plt.tight_layout()
        plt.savefig('confusion_matrix.png', dpi=300, bbox_inches='tight')
        plt.close()


def main():
    parser = argparse.ArgumentParser(description='슬개골 탈구 ST-GCN 학습')
    
    parser.add_argument('--train_data_dir', type=str, default='../patella_data/Training/Json')
    # ▼▼▼ [수정] 오타 수정 (addd_argument -> add_argument) ▼▼▼
    parser.add_argument('--val_data_dir', type=str, default='../patella_data/Validation/Json')
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
    parser.add_argument('--stats_path', type=str, default=None,
                       help='통계 파일 경로 (지정하지 않으면 seg_len 기반 자동 경로 사용)')
    parser.add_argument('--calculate_stats', action='store_true', default=False,
                       help='학습 전 통계 파일 강제 생성 여부')
    
    parser.add_argument('--seg_len', type=int, default=60,
                       help='시퀀스 길이 (프레임 수)')
    
    parser.add_argument('--dropout', type=float, default=0.5)
    
    parser.add_argument('--batch_size', type=int, default=64)
    
    parser.add_argument('--learning_rate', type=float, default=2e-4,
                       help='학습률')
    
    # ▼▼▼ [수정] weight_decay 증가 (Regularization 강화) ▼▼▼
    parser.add_argument('--weight_decay', type=float, default=5e-4, # 1e-4 -> 5e-4
                       help='가중치 감쇠 (L2 정규화)')
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
    
    parser.add_argument('--epochs', type=int, default=1000)
    parser.add_argument('--early_stopping', type=int, default=30)
    
    # ▼▼▼ [수정] num_workers=0으로 변경 (I/O 병목 방지) ▼▼▼
    parser.add_argument('--num_workers', type=int, default=0, 
                       help='데이터로더 워커 수 (Windows에서는 0 권장)') 
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
    
    parser.add_argument('--val_split', type=float, default=0.2,
                       help='전체 고품질 데이터에서 검증용으로 분리할 비율 (예: 0.2)')
    
    args = parser.parse_args()
    
    # --- 1. 모든 고품질 데이터 수집 (Train/Val 폴더 모두) ---
    print("=" * 60)
    print("🚀 모든 고품질 데이터 수집 및 재분배 시작...")
    print("=" * 60)
    if DogPoseDataset is None or calculate_and_save_stats is None:
         raise ImportError("DogPoseDataset 또는 calculate_and_save_stats가 import되지 않았습니다.")
            
    train_paths, train_labels = _collect_data(args.train_data_dir, args.seg_len)
    val_paths, val_labels = _collect_data(args.val_data_dir, args.seg_len)
    
    all_paths = train_paths + val_paths
    all_labels = train_labels + val_labels
    
    if len(all_paths) < 10: 
        print(f"❌ 고품질 데이터( {args.seg_len}프레임 이상)가 {len(all_paths)}개밖에 없어 학습을 중단합니다.")
        return
        
    print(f"\n✅ 총 {len(all_paths)}개의 고품질 비디오 확보.")
    
    # --- 2. 데이터 셔플 및 8:2 분배 (계층적 셔플) ---
    print(f"\n✅ 계층적 분배 (stratify) 8:2 (val_split={args.val_split}) 시작...")
    
    train_paths_new, val_paths_new, train_labels_new, val_labels_new = train_test_split(
        all_paths,
        all_labels,
        test_size=args.val_split, 
        random_state=42,
        stratify=all_labels  # [핵심] 'all_labels'의 비율을 유지하며 셔플
    )

    if not train_paths_new:
        print("❌ 훈련 데이터가 없습니다. (분배 실패)")
        return
    if not val_paths_new:
        print("⚠️ 경고: 검증 데이터가 없습니다. (데이터가 너무 적어 분배 실패) Train 셋으로만 진행합니다.")
        val_paths_new, val_labels_new = [], [] # 빈 리스트로 설정
        
    print(f"  -> 새로운 훈련 셋: {len(train_paths_new)}개 비디오")
    print(f"  -> 새로운 검증 셋: {len(val_paths_new)}개 비디오")
    print("=" * 60)

    # --- 3. 통계 파일 경로 결정 및 생성 (새로운 훈련 셋 기준) ---
    if args.stats_path is None:
        args.stats_path = f"patella_stats_seg{args.seg_len}.pt"
        print(f"기본 통계 파일 경로 설정: {args.stats_path}")
    
    if args.calculate_stats or not os.path.exists(args.stats_path):
        if args.calculate_stats:
            print(f"📊 통계 파일 강제 생성 중... ({args.stats_path})")
        else:
            print(f"📊 통계 파일이 없어 새로 생성 중... ({args.stats_path})")
        
        temp_dataset = PatellaDatasetWrapper(
            json_paths=list(train_paths_new),
            labels=list(train_labels_new),
            seg_len=args.seg_len, 
            stats_path=None,
            train=False
        )
        
        calculate_and_save_stats(temp_dataset, args.stats_path)
        print(f"✅ 통계 파일 생성 완료: {args.stats_path}")
    else:
        print(f"✅ 기존 통계 파일 로드: {args.stats_path}")
    
    # --- 4. 학습 시작 (재분배된 데이터로) ---
    trainer = PatellaTrainer(
        args, 
        train_paths=list(train_paths_new), 
        train_labels=list(train_labels_new), 
        val_paths=list(val_paths_new), 
        val_labels=list(val_labels_new)
    )
    trainer.train()

if __name__ == "__main__":
    main()