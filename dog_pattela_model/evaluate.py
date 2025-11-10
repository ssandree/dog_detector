#!/usr/bin/env python3
"""
슬개골 탈구 ST-GCN 모델 평가 스크립트
- 저장된 .pt (체크포인트) 파일을 로드하여 Validation Set 성능을 평가
- 비디오 단위 Soft Voting 적용
- 2클래스 (정상/이상) 분류기 기준
"""

import os
import sys
import json
import torch
import torch.nn as nn
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
import argparse
from typing import List, Dict
from collections import defaultdict
import torch.nn.functional as F
import math 
from importlib import import_module 
import random 

# --- (1) train.py와 동일한 설정 ---

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
    # (평가 시에는 통계 계산 함수 필요 없음)
    if __name__ == "__main__":
        print("✅ data_preprocess_patella.py 모듈 로드 성공")
except ImportError as e:
    if __name__ == "__main__":
        print(f"❌ 데이터 전처리 모듈 로드 실패: {e}")
    DogPoseDataset = None

# 모델 import
from patella_model import PatellaSTGCN 

# _collect_data 함수 (train.py와 동일)
def _collect_data(json_dir, min_frames=60): 
    json_files = list(Path(json_dir).glob("*.json"))
    json_paths = []
    labels = []
    filtered_count = 0
    print(f"JSON 파일 {len(json_files)}개 발견, 필터링 중... (min_frames={min_frames})")
    for json_file in tqdm(json_files, desc=f"데이터 수집 ({Path(json_dir).name})"):
        try:
            filename = json_file.stem
            label = filename.split('_')[0]
            with open(json_file, 'r', encoding='utf-8') as f: data = json.load(f)
            dog_id = list(data.keys())[0]
            frame_count = len(data[dog_id])
            if frame_count >= min_frames:
                json_paths.append(str(json_file))
                labels.append(label)
            else:
                filtered_count += 1
        except Exception as e:
            filtered_count += 1
    print(f"📊 수집 완료 ({Path(json_dir).name}):")
    print(f"  사용된 파일 (고품질): {len(json_paths)}개")
    print(f"  필터링된 파일 (짧은 영상): {filtered_count}개")
    return json_paths, labels

# PatellaDatasetWrapper (train.py와 동일)
class PatellaDatasetWrapper(Dataset):
    """
    2클래스 분류 (정상/이상) Wrapper
    """
    def __init__(self, json_paths: List[str], labels: List[str], seg_len=60, stats_path=None, train=False): # train=False 고정
        self.seg_len = seg_len
        self.stats_path = stats_path
        self.train = train
        self.json_paths = json_paths
        self.raw_labels = labels 

        if len(self.json_paths) == 0:
            raise ValueError(f"❌ Wrapper에 유효한 데이터가 전달되지 않았습니다. (0개)")
        
        binary_labels = []
        for label in self.raw_labels:
            if label == '정상':
                binary_labels.append('정상')
            else:
                binary_labels.append('이상')
        
        self.label_encoder = LabelEncoder()
        all_possible_labels = ['정상', '이상']
        self.label_encoder.fit(all_possible_labels)
        encoded_array = self.label_encoder.transform(binary_labels)
        
        self.encoded_labels: List[int] = np.array(encoded_array).tolist()
        self.num_classes = len(self.label_encoder.classes_) # 2
        
        if DogPoseDataset is None:
            raise ImportError("DogPoseDataset을 import할 수 없습니다.")
        
        self.dataset = DogPoseDataset(
            json_paths=self.json_paths,
            labels=self.encoded_labels,
            seg_len=self.seg_len,
            stats_path=self.stats_path,
            train=self.train # False
        )
        
        print(f"📊 Patella 데이터셋 정보 ({'Train' if train else 'Val'}):")
        print(f"  원본 비디오 수 (재분배됨): {len(self.json_paths)}개")
        print(f"  총 샘플(윈도우) 수: {len(self.dataset)}개")
        print(f"  클래스: {list(self.label_encoder.classes_)}")
        
        if len(self.encoded_labels) > 0:
            class_counts = np.bincount(np.array(self.encoded_labels), minlength=self.num_classes)
            print(f"  [비디오 기준] 클래스 분포:")
            for i, count in enumerate(class_counts):
                if i < len(self.label_encoder.classes_):
                    print(f"    {self.label_encoder.classes_[i]}: {count}개")
        
        print(f"  seg_len (시퀀스 길이): {self.seg_len}프레임")
        if self.stats_path:
            print(f"  통계 파일: {self.stats_path}")
    
    def __len__(self):
        return len(self.dataset)
    
    def __getitem__(self, idx):
        return self.dataset[idx]

# plot_confusion_matrix 함수 (train.py와 동일)
def plot_confusion_matrix(true_labels, pred_labels, label_encoder, save_name="evaluation_confusion_matrix.png"):
    class_names = list(label_encoder.classes_)
    class_indices = list(range(len(class_names)))
    
    cm = confusion_matrix(true_labels, pred_labels, labels=class_indices)
    
    plt.figure(figsize=(8, 6))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
               xticklabels=class_names, yticklabels=class_names)
    plt.title('슬개골 탈구 분류 혼동 행렬 (비디오 단위)')
    plt.xlabel('예측 라벨')
    plt.ylabel('실제 라벨')
    plt.tight_layout()
    plt.savefig(save_name)
    print(f"✅ 혼동 행렬 저장 완료: {save_name}")
    plt.close()

# --- (2) 평가(Evaluate) 함수 (train.py의 validate 함수 수정) ---

def evaluate_model(model, val_loader, label_encoder, device):
    """
    모델을 평가하고, Soft Voting을 적용하여 최종 리포트와 행렬을 반환합니다.
    """
    model.eval()
    video_outputs = defaultdict(list)
    video_true_labels = {}
    
    with torch.no_grad():
        for sequences, labels, video_indices in tqdm(val_loader, desc="Evaluating"):
            sequences = sequences.to(device)
            labels = labels.to(device)
            
            outputs = model(sequences)
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
        print("❌ 경고: 검증 데이터에서 유효한 비디오 라벨을 찾을 수 없습니다.")
        return

    for vid_idx, probs_list in video_outputs.items():
        mean_prob = torch.mean(torch.stack(probs_list), dim=0)
        final_pred = torch.argmax(mean_prob).item()
        true_label = video_true_labels[vid_idx]
        
        all_preds.append(final_pred)
        all_labels.append(true_label)
        
    # 최종 F1 Score 및 리포트 생성
    class_names = list(label_encoder.classes_)
    class_indices = list(range(len(class_names)))

    f1_macro = f1_score(all_labels, all_preds, average='macro', zero_division=0)
    
    report_str = classification_report(
        all_labels, all_preds, 
        target_names=class_names,
        labels=class_indices,
        digits=4,
        zero_division=0
    )
    
    print("\n" + "="*50)
    print("📊 최종 평가 리포트 (비디오 단위)")
    print("="*50)
    print(report_str)
    print("="*50)
    print(f"🎯 최종 Macro F1-score: {f1_macro:.4f}")
    
    # 혼동 행렬 플롯
    plot_confusion_matrix(all_labels, all_preds, label_encoder)


# --- (3) 메인(main) 함수 ---

def main():
    parser = argparse.ArgumentParser(description='슬개골 탈구 ST-GCN 평가')
    
    # --- 필수 인자 ---
    parser.add_argument('--checkpoint_path', type=str, required=True,
                       help='평가할 .pt (체크포인트) 파일 경로')
    
    # --- 훈련 시 사용했던 설정 (모델/데이터 로드에 필요) ---
    parser.add_argument('--seg_len', type=int, default=60,
                       help='훈련 시 사용했던 시퀀스 길이 (seg_len)')
    parser.add_argument('--stats_path', type=str, default=None,
                       help='훈련 시 사용했던 통계 파일 경로 (e.g., patella_stats_seg60.pt)')
    parser.add_argument('--val_data_dir', type=str, default='../patella_data/Validation/Json',
                       help='(옵션) 평가에 사용할 검증 데이터 폴더')
    parser.add_argument('--train_data_dir', type=str, default='../patella_data/Training/Json',
                       help='(옵션) 훈련 폴더 (Val 셋 재분배에 필요)')
    parser.add_argument('--val_split', type=float, default=0.2,
                       help='훈련 시 사용했던 검증용 분리 비율 (val_split)')
    
    # --- 실행 옵션 ---
    parser.add_argument('--batch_size', type=int, default=64,
                       help='평가 시 사용할 배치 크기')
    parser.add_argument('--num_workers', type=int, default=0, 
                       help='데이터로더 워커 수 (Windows에서는 0 권장)') 
    
    args = parser.parse_args()
    
    # --- 1. 통계 파일 경로 자동 설정 (train.py와 동일) ---
    if args.stats_path is None:
        args.stats_path = f"patella_stats_seg{args.seg_len}.pt"
        print(f"기본 통계 파일 경로 설정: {args.stats_path}")
        
    if not os.path.exists(args.stats_path):
        print(f"❌ 오류: 통계 파일({args.stats_path})을 찾을 수 없습니다.")
        print(f"`--calculate_stats` 옵션으로 train.py를 먼저 실행하여 통계 파일을 생성해야 합니다.")
        return

    # --- 2. 훈련/검증 데이터 재분배 (train.py와 동일) ---
    print("=" * 60)
    print(f"🚀 고품질(seg_len={args.seg_len}) 검증 데이터 로드 중...")
    print("=" * 60)
    if DogPoseDataset is None:
         raise ImportError("DogPoseDataset이 import되지 않았습니다.")
            
    train_paths, train_labels = _collect_data(args.train_data_dir, args.seg_len)
    val_paths, val_labels = _collect_data(args.val_data_dir, args.seg_len)
    
    all_paths = train_paths + val_paths
    all_labels = train_labels + val_labels
    
    if len(all_paths) < 1:
        print(f"❌ 고품질 데이터( {args.seg_len}프레임 이상)가 없습니다.")
        return
        
    print(f"\n✅ 총 {len(all_paths)}개의 고품질 비디오 확보.")
    
    # 계층적 셔플 (train.py와 동일한 random_state=42 사용)
    train_paths_new, val_paths_new, train_labels_new, val_labels_new = train_test_split(
        all_paths,
        all_labels,
        test_size=args.val_split, 
        random_state=42,
        stratify=all_labels
    )
    
    if not val_paths_new:
        print("❌ 경고: 검증 데이터가 0개입니다. (val_split이 너무 낮거나 데이터 부족)")
        return
        
    print(f"  -> 총 {len(val_paths_new)}개의 검증 비디오로 평가를 시작합니다.")
    print("=" * 60)

    # --- 3. 데이터셋 및 로더 준비 ---
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"사용 디바이스: {device}")
    
    # [핵심] train=False로 설정하여 증강(Augmentation) 없이 평가
    val_dataset = PatellaDatasetWrapper(
        json_paths=list(val_paths_new), 
        labels=list(val_labels_new),   
        seg_len=args.seg_len,
        stats_path=args.stats_path,
        train=False 
    )
    
    val_loader = DataLoader(
        val_dataset,
        batch_size=args.batch_size,
        shuffle=False,
        num_workers=args.num_workers
    )
    
    # --- 4. 모델 생성 및 가중치 로드 ---
    print(f"\n모델 생성 중... (Classes: {val_dataset.num_classes})")
    
    # [핵심] 모델 구조는 훈련 시 사용한 '경량화 버전'이어야 함
    model = PatellaSTGCN(
        in_channels=3,
        num_classes=val_dataset.num_classes, # 2
        dropout=0.0 # 평가 시에는 Dropout 비활성화
    ).to(device)
    
    print(f"모델 파라미터 수: {sum(p.numel() for p in model.parameters()):,}")

    try:
        print(f"가중치 로드 중: {args.checkpoint_path}")
        # [핵심] weights_only=False로 LabelEncoder까지 로드 (train.py와 동일)
        checkpoint = torch.load(args.checkpoint_path, weights_only=False)
        
        # (선택) 체크포인트의 LabelEncoder와 현재 LabelEncoder 비교
        try:
            saved_encoder = checkpoint['label_encoder']
            if list(saved_encoder.classes_) != list(val_dataset.label_encoder.classes_):
                print("⚠️ 경고: 저장된 모델의 라벨과 현재 데이터의 라벨이 다릅니다!")
                print(f"  모델 라벨: {list(saved_encoder.classes_)}")
                print(f"  데이터 라벨: {list(val_dataset.label_encoder.classes_)}")
        except KeyError:
            print("경고: 체크포인트에 'label_encoder' 정보가 없습니다.")

        model.load_state_dict(checkpoint['model_state_dict'])
        print("✅ 가중치 로드 성공.")
        
    except Exception as e:
        print(f"❌ 오류: 가중치 파일 로드 실패. {e}")
        print("    (1) --seg_len이 훈련 시와 동일한지 확인하세요.")
        print("    (2) 5클래스 모델 가중치에 2클래스 모델을 로드하려는지 확인하세요.")
        return

    # --- 5. 평가 실행 ---
    evaluate_model(model, val_loader, val_dataset.label_encoder, device)

if __name__ == "__main__":
    main()