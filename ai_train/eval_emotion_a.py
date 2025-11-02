#!/usr/bin/env python3
"""
VGGish A/V 모델 평가 스크립트
- 검증 데이터셋(Test Set)으로 최종 성능 평가
- Classification Report (Acc, Precision, Recall, F1) 출력
- Confusion Matrix (혼동 행렬) 시각화 및 이미지 저장
"""

import torch
import torch.nn as nn
from torch.utils.data import DataLoader
import numpy as np
import os
import sys
from pathlib import Path
import json
import random
import pandas as pd
import math
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import matplotlib.pyplot as plt
import seaborn as sns


from train_emotion_a import (
            DogVGGishTrainer, DogAudioDataset, load_data_from_csv_and_dir,
            AROUSAL_MAP, VALENCE_MAP, AROUSAL_NAMES, VALENCE_NAMES,
            NUM_AROUSAL_CLASSES, NUM_VALENCE_CLASSES,
            SILENCE_AROUSAL_LABEL, SILENCE_VALENCE_LABEL
        )
print("Imported from 'train_emotion_a.py'")

def evaluate_model(config):
    """모델 평가 및 시각화 수행"""
    print("="*50); print("오디오 모델 평가 시작"); print("="*50)

    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    print(f"Using device: {device}")

    # --- 1. 검증(Test) 데이터 로드 ---
    # (훈련 스크립트의 main 함수와 동일한 로직)
    print("\n[1/4] 검증 데이터 로드 중...")
    real_val_files, real_val_labels_A, real_val_labels_V = [], [], []
    for csv_path, audio_dir in zip(config['VAL_CSV_PATHS'], config['VAL_AUDIO_DIRS']):
        files, labels_a, labels_v = load_data_from_csv_and_dir(csv_path, audio_dir)
        real_val_files.extend(files)
        real_val_labels_A.extend(labels_a)
        real_val_labels_V.extend(labels_v)

    if not real_val_files:
        print("❌ 오류: 평가할 검증 데이터가 없습니다. 경로와 CSV 파일을 확인하세요.")
        return

    # --- 가상 침묵 데이터 추가 (훈련 시와 동일하게) ---
    if config['NUM_SILENT_VAL'] > 0:
        print(f"\n--- 가상 침묵 데이터 {config['NUM_SILENT_VAL']}개 추가 ---")
        silent_val_paths = ["SILENT"] * config['NUM_SILENT_VAL']
        silent_val_labels_A = [SILENCE_AROUSAL_LABEL] * config['NUM_SILENT_VAL']
        silent_val_labels_V = [SILENCE_VALENCE_LABEL] * config['NUM_SILENT_VAL']
        
        val_files = real_val_files + silent_val_paths
        val_labels_A = real_val_labels_A + silent_val_labels_A
        val_labels_V = real_val_labels_V + silent_val_labels_V
    else:
        print("\n--- 가상 침묵 데이터 추가 안 함 ---")
        val_files, val_labels_A, val_labels_V = real_val_files, real_val_labels_A, real_val_labels_V

    print(f"📊 총 검증 데이터: {len(val_files)}개 (실제 {len(real_val_files)}, 침묵 {config['NUM_SILENT_VAL']})")

    # --- 2. 데이터셋 및 로더 생성 ---
    print("\n[2/4] DataLoader 생성 중...")
    # [중요] train=False로 설정하여 평가 모드(평균 집계) 사용
    val_dataset = DogAudioDataset(list(val_files), list(val_labels_A), list(val_labels_V), train=False)
    val_loader = DataLoader(val_dataset, batch_size=config['BATCH_SIZE'], shuffle=False, num_workers=config['NUM_WORKERS'])
    
    # --- 3. 모델 로드 ---
    print("\n[3/4] 모델 로드 중...")
    try:
        trainer = DogVGGishTrainer(
            num_arousal_classes=NUM_AROUSAL_CLASSES, 
            num_valence_classes=NUM_VALENCE_CLASSES,
            device=device
        )
        trainer.load_model(config['BEST_MODEL_PATH'])
        print(f"✅ 모델 로드 성공: {config['BEST_MODEL_PATH']}")
    except FileNotFoundError:
        print(f"❌ 오류: 모델 파일을 찾을 수 없습니다: {config['BEST_MODEL_PATH']}")
        print("   > [TODO] 스크립트 상단의 BEST_MODEL_PATH 변수에 훈련된 모델의 정확한 파일명을 입력하세요.")
        return
    except Exception as e:
        print(f"❌ 오류: 모델 로드 실패: {e}")
        return

    # --- 4. 평가 및 시각화 ---
    print("\n[4/4] 평가 실행 및 리포트 생성 중...")
    
    # [수정] trainer.validate()를 직접 사용하여 결과 집계
    avg_loss, (labels_A, preds_A), (labels_V, preds_V) = trainer.validate(val_loader)
    
    print("\n" + "="*70)
    print("                 최종 평가 결과 (검증 데이터셋)")
    print("="*70)
    print(f"평균 검증 Loss: {avg_loss:.4f}")

    # Arousal 리포트
    print("\n--- Arousal 최종 성능 리포트 ---")
    acc_A = accuracy_score(labels_A, preds_A) * 100
    report_A = classification_report(labels_A, preds_A,
                                     target_names=AROUSAL_NAMES,
                                     labels=np.arange(NUM_AROUSAL_CLASSES),
                                     digits=4, zero_division=0)
    print(f"Arousal Accuracy: {acc_A:.2f}%")
    print(report_A)

    # Valence 리포트
    print("\n--- Valence 최종 성능 리포트 ---")
    acc_V = accuracy_score(labels_V, preds_V) * 100
    report_V = classification_report(labels_V, preds_V,
                                     target_names=VALENCE_NAMES,
                                     labels=np.arange(NUM_VALENCE_CLASSES),
                                     digits=4, zero_division=0)
    print(f"Valence Accuracy: {acc_V:.2f}%")
    print(report_V)
    print("-" * 70)

    # 혼동 행렬 시각화
    try:
        # Arousal 혼동 행렬
        cm_A = confusion_matrix(labels_A, preds_A, labels=np.arange(NUM_AROUSAL_CLASSES))
        plt.figure(figsize=(8, 6))
        sns.heatmap(cm_A, annot=True, fmt='d', cmap='Blues',
                    xticklabels=AROUSAL_NAMES, yticklabels=AROUSAL_NAMES, annot_kws={"size": 12})
        plt.xlabel('Predicted Label', fontsize=12)
        plt.ylabel('True Label', fontsize=12)
        plt.title('Audio Model - Arousal Confusion Matrix', fontsize=14)
        plt.tight_layout()
        cm_filename_A = "confusion_matrix_audio_arousal.png"
        plt.savefig(cm_filename_A)
        print(f"Arousal 혼동 행렬 이미지 저장 완료: {cm_filename_A}")
        plt.close()

        # Valence 혼동 행렬
        cm_V = confusion_matrix(labels_V, preds_V, labels=np.arange(NUM_VALENCE_CLASSES))
        plt.figure(figsize=(8, 6))
        sns.heatmap(cm_V, annot=True, fmt='d', cmap='Blues',
                    xticklabels=VALENCE_NAMES, yticklabels=VALENCE_NAMES, annot_kws={"size": 12})
        plt.xlabel('Predicted Label', fontsize=12)
        plt.ylabel('True Label', fontsize=12)
        plt.title('Audio Model - Valence Confusion Matrix', fontsize=14)
        plt.tight_layout()
        cm_filename_V = "confusion_matrix_audio_valence.png"
        plt.savefig(cm_filename_V)
        print(f"Valence 혼동 행렬 이미지 저장 완료: {cm_filename_V}")
        plt.close()

    except Exception as e:
        print(f"오류: 혼동 행렬 생성 실패 - {e}")
        print("팁: matplotlib, seaborn 설치 확인 및 한글 폰트 설정 확인")
        
    print("="*70); print("평가 완료"); print("="*70)

# --- 메인 실행 블록 ---
if __name__ == '__main__':
    # --- [TODO] 사용자 설정 ---
    # 훈련 시 사용했던 경로 및 설정
    BASE_PATH = r"C:\Users\User\Desktop\Sejong\Under_Graduate\3_2\Capstone Design\EmotionalCanines"
    
    # [!] 훈련 로그에서 가장 F1 점수가 높았던 (또는 Loss가 낮았던) 파일의
    # [!] 정확한 이름을 여기에 붙여넣으세요.
    BEST_MODEL_PATH = "audio_emotion_model.pt" # 예: 훈련 로그의 '최고 F1 (Macro Avg) 갱신!' 메시지 참고
    
    # 훈련 시와 동일한 설정값
    NUM_SILENT_VAL = 0 # 훈련 시 사용한 값 (최근 로그 기준 0)
    BATCH_SIZE = 128    # 훈련 시 BATCH_SIZE (메모리 부족 시 줄여도 됨)
    NUM_WORKERS = 0    # 훈련 시 NUM_WORKERS (0 권장)
    # --------------------------

    # 자동 경로 설정
    config = {
        'VAL_CSV_PATHS': [
            os.path.join(BASE_PATH, "husky_test_labels.csv"),
            os.path.join(BASE_PATH, "shiba_test_labels.csv")
        ],
        'VAL_AUDIO_DIRS': [
            os.path.join(BASE_PATH, "husky", "test"),
            os.path.join(BASE_PATH, "shiba", "test")
        ],
        'NUM_SILENT_VAL': NUM_SILENT_VAL,
        'BEST_MODEL_PATH': BEST_MODEL_PATH,
        'BATCH_SIZE': BATCH_SIZE,
        'NUM_WORKERS': NUM_WORKERS
    }
    
    evaluate_model(config)
