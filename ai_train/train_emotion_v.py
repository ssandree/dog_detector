import torch
from torch import nn
from torch import optim
from torch.utils.data import DataLoader, WeightedRandomSampler
import numpy as np
import os
import sys
import glob
from pathlib import Path
import json
import random
from sklearn.metrics import f1_score, precision_score, accuracy_score, classification_report, confusion_matrix
import math 
from collections import defaultdict
import torch.nn.functional as F
from importlib import import_module
import time # 조기 종료용
from tqdm import tqdm # [추가] 진행바 표시

# --- 1. 시스템 경로 설정 ---
current_file_path = os.path.abspath(__file__)
ai_train_dir = os.path.dirname(current_file_path)
project_root_dir = os.path.dirname(ai_train_dir)
if project_root_dir not in sys.path:
    sys.path.append(project_root_dir)

# --- 2. 실제 모듈 임포트 ---
from dog_emotion_model.stgcn import DogEmotionSTGCN, create_normalized_adjacency
# [수정] 곽민준님이 주신 'data_preprocess_emotion.py'를 import
try:
    data_preprocess = import_module('common.data_preprocess_emotion')
    DogPoseDataset = data_preprocess.DogPoseDataset
    calculate_and_save_stats = data_preprocess.calculate_and_save_stats

except ImportError as e:
    print(f"❌ 데이터 전처리 모듈 로드 실패: {e}")
    DogPoseDataset = None
    calculate_and_save_stats = None


# --- 3. 실제 데이터 로딩 함수 (간단 버전) ---
def load_data_from_final_folder(pose_data_dir, emotion_label_file):
    """폴더 내 모든 JSON 파일 로드 + 라벨 매칭"""
    emotion_mapping = {"편안/안정": 0, "불안/슬픔": 1, "공포": 2, "공격성": 3}
    
    # 라벨 로드
    with open(emotion_label_file, 'r', encoding='utf-8') as f:
        all_labels = json.load(f)
    
    json_paths, labels = [], []
    
    # 폴더의 모든 JSON 파일 스캔
    for json_file in Path(pose_data_dir).glob('*.json'):
        # 파일명: 20201022_dog-lying-000031.mp4.json
        # stem: 20201022_dog-lying-000031.mp4
        video_name = json_file.stem
        
        # 라벨에서 찾기 (키는 .mp4까지만)
        if video_name in all_labels:
            emotion = all_labels[video_name].get('inspect_emotion', None)
            if emotion in emotion_mapping:
                json_paths.append(str(json_file))
                labels.append(emotion_mapping[emotion])
    
    # 통계
    print(f"\n'{os.path.basename(pose_data_dir)}': {len(json_paths)}개")
    emotion_counts = {name: sum(1 for l in labels if l == idx) 
                     for name, idx in emotion_mapping.items()}
    for name, idx in sorted(emotion_mapping.items(), key=lambda x: x[1]):
        print(f"  - {name} ({idx}): {emotion_counts[name]}개")
    
    return json_paths, labels, emotion_mapping, emotion_counts

def main():
    """메인 실행 함수"""
    # --- 4. 하이퍼파라미터 및 설정 ---
    NUM_NODES = 20
    SEG_LEN = 30      # [수정] 30프레임으로 설정 (1초 정도의 시간 정보, 충분한 시간적 패턴)
    C_IN = 3          
    EPOCHS = 200       
    BATCH_SIZE = 128  # [수정] RTX 5080에 맞게 증가 (128 -> 256)
    LEARNING_RATE = 5e-4  # [수정] 학습률 감소 (안정적 학습)
    WEIGHT_DECAY = 5e-3   # [수정] 정규화 강화
    DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    
    # ▼▼▼ [수정] GPU 사용 시 병렬 데이터 로딩 ▼▼▼
    # NUM_WORKERS=0: 단일 프로세스 (느림)
    # NUM_WORKERS=4~8: 멀티프로세싱으로 데이터 로딩 병렬화 (빠름)
    NUM_WORKERS = 16 if DEVICE.type == 'cuda' else 0
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
    
    # [추가] Mixed Precision 학습 (RTX 5080 최적화)
    USE_AMP = True if DEVICE.type == 'cuda' else False
    
    PATIENCE = 30 # [수정] 조기 종료 Patience 증가

    # 경로 설정
    POSE_DATA_DIR = '../pose_data'
    # [수정] Training_final/Validation_final 전용 라벨 파일 사용
    TRAIN_EMOTION_LABEL_FILE = '../pose_data/training_final_labels.json'
    VAL_EMOTION_LABEL_FILE = '../pose_data/validation_final_labels.json'
    # [수정] Training_final / Validation_final 폴더 사용
    TRAIN_POSE_DIR = '../pose_data/Training_final'
    VAL_POSE_DIR = '../pose_data/Validation_final'
    STATS_PATH = 'dog_pose_stats.pt'
    # [수정] 2개의 모델 저장: Accuracy 최고 / F1-Score 최고
    BEST_MODEL_PATH_ACC = 'best_dog_emotion_model_acc.pth'
    BEST_MODEL_PATH_F1 = 'best_dog_emotion_model_f1.pth'

    print(f"Using device: {DEVICE}")

    # --- 5. 실제 데이터 로딩 ---
    print("="*50); print("데이터 로딩 중...");
    train_paths, initial_train_labels, emotion_mapping, _ = load_data_from_final_folder(
        TRAIN_POSE_DIR, TRAIN_EMOTION_LABEL_FILE
    )
    val_paths, initial_val_labels, _, _ = load_data_from_final_folder(
        VAL_POSE_DIR, VAL_EMOTION_LABEL_FILE
    )

    NUM_CLASSES = len(emotion_mapping)
    if NUM_CLASSES == 0 or not train_paths or not val_paths:
        print("오류: 훈련 또는 검증 데이터를 로드하지 못했습니다.")
        return

    print(f"\nTraining 비디오 수 (원본): {len(train_paths)}개");
    print(f"Validation 비디오 수 (원본): {len(val_paths)}개")
    print(f"감정 클래스 ({NUM_CLASSES}개): {emotion_mapping}"); print("="*50)
    
    # --- 5.5. 프레임 수 검증 (최소 30프레임 확인) ---
    print("\n[데이터 검증] 최소 프레임 수 확인 중...")
    def count_frames_in_json(json_path):
        """JSON 파일에서 프레임 수 계산"""
        try:
            with open(json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                if isinstance(data, dict):
                    first_key = list(data.keys())[0]
                    frames_dict = data[first_key]
                    if isinstance(frames_dict, dict):
                        return sum(1 for k in frames_dict.keys() if k.startswith('frame_'))
                return 0
        except:
            return 0
    
    # Train 데이터 검증
    train_frame_counts = [count_frames_in_json(p) for p in train_paths[:100]]  # 샘플 100개 검사
    train_min_frames = min(train_frame_counts) if train_frame_counts else 0
    train_avg_frames = sum(train_frame_counts) / len(train_frame_counts) if train_frame_counts else 0
    
    # Validation 데이터 검증
    val_frame_counts = [count_frames_in_json(p) for p in val_paths[:100]]  # 샘플 100개 검사
    val_min_frames = min(val_frame_counts) if val_frame_counts else 0
    val_avg_frames = sum(val_frame_counts) / len(val_frame_counts) if val_frame_counts else 0
    
    print(f"  Train 샘플 100개 검사:")
    print(f"    - 최소 프레임: {train_min_frames}프레임")
    print(f"    - 평균 프레임: {train_avg_frames:.1f}프레임")
    print(f"  Validation 샘플 100개 검사:")
    print(f"    - 최소 프레임: {val_min_frames}프레임")
    print(f"    - 평균 프레임: {val_avg_frames:.1f}프레임")
    
    if train_min_frames < 30 or val_min_frames < 30:
        print(f"  ⚠️ 경고: 30프레임 미만 데이터 발견! SEG_LEN={SEG_LEN} 사용 불가능")
        print(f"  권장: 최소 프레임 이상의 데이터셋 사용 필요")
    else:
        print(f"  ✓ 모든 샘플이 30프레임 이상입니다. SEG_LEN={SEG_LEN} 사용 가능")
    print("="*50)

    # --- 6. 통계치 계산 ---
    if not os.path.exists(STATS_PATH):
        print("\n통계 파일 생성 중 (원본 훈련 데이터 사용)...")
        if not train_paths: print("오류: 통계 계산용 데이터 없음."); return
        temp_train_dataset_for_stats = DogPoseDataset(
            json_paths=train_paths, labels=initial_train_labels, seg_len=SEG_LEN,
            stats_path=None, train=False
        )
        calculate_and_save_stats(temp_train_dataset_for_stats, STATS_PATH)
        print(f"통계 파일 생성 완료: {STATS_PATH}")
    else: print(f"\n기존 통계 파일 로드: {STATS_PATH}")

    # --- 7. 실제 데이터셋 생성 및 샘플러 가중치 계산 (수정) ---
    print("\n데이터셋 생성 및 샘플러 가중치 계산 중...")
    train_dataset = DogPoseDataset(
        json_paths=train_paths, labels=initial_train_labels, seg_len=SEG_LEN,
        stats_path=STATS_PATH, train=True
    )
    val_dataset = DogPoseDataset(
        json_paths=val_paths, labels=initial_val_labels, seg_len=SEG_LEN,
        stats_path=STATS_PATH, train=False
    )
    actual_train_len = len(train_dataset); actual_val_len = len(val_dataset)
    print(f"실제 로드된 훈련 샘플(윈도우) 수: {actual_train_len}")
    print(f"실제 로드된 검증 샘플(윈도우) 수: {actual_val_len}")
    
    # ▼▼▼ [수정] WeightedRandomSampler 활성화 (제곱근 역수 가중치) ▼▼▼
    train_sampler = None
    use_shuffle = True
    
    if actual_train_len > 0:
        try:
            actual_train_labels = [s[2] for s in train_dataset.samples] 
            counts = np.bincount(actual_train_labels, minlength=NUM_CLASSES)
            print("실제 로드된 훈련 샘플(윈도우) 감정별 분포:")
            for name, idx in sorted(emotion_mapping.items(), key=lambda item: item[1]):
                 print(f"    - {name} ({idx}): {counts[idx] if idx < len(counts) else 0}개")
            
            # 가중치 계산 (제곱근 역수)
            if all(c > 0 for c in counts):
                weights_per_class = [1.0 / math.sqrt(c) for c in counts]
                sample_weights = [weights_per_class[label] for label in actual_train_labels]
                sampler_weights = torch.DoubleTensor(sample_weights)
                train_sampler = WeightedRandomSampler(sampler_weights, num_samples=actual_train_len, replacement=True)
                print(f"WeightedRandomSampler 생성 완료 (제곱근 역수 가중치).")
                print(f"  클래스별 가중치: {[f'{w:.4f}' for w in weights_per_class]}")
                use_shuffle = False
            else:
                print("경고: 일부 클래스 부재. Sampler 미사용.")
        except Exception as e:
            print(f"경고: 샘플 라벨 추출 실패. {e}")
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

    # DataLoader 생성
    print("\nDataLoader 생성 중...")
    try:
        train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, sampler=train_sampler,
                                  num_workers=NUM_WORKERS, pin_memory=True if DEVICE=='cuda' else False,
                                  shuffle=use_shuffle) 
        val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE, shuffle=False,
                                num_workers=NUM_WORKERS, pin_memory=True if DEVICE=='cuda' else False)
        print("DataLoaders 생성 완료.")
    except Exception as e: print(f"오류: DataLoader 생성 실패 - {e}"); return

    # --- 8. 뼈대(Adjacency Matrix) 생성 (원본과 동일) ---
    ALL_KEYPOINT_NAMES = [
        "left_f_wrist", "left_f_ankle", "left_f_shoulder", "left_b_wrist", "left_b_ankle", "left_b_shoulder",
        "right_f_wrist", "right_f_ankle", "right_f_shoulder", "right_b_wrist", "right_b_ankle", "right_b_shoulder",
        "tail_s", "tail_e", "left_mid_ear", "right_mid_ear", "nose", "mouth", "left_edge_ear", "right_edge_ear"
    ]
    KEYPOINT_MAP = {name: i for i, name in enumerate(ALL_KEYPOINT_NAMES)}
    connections = [
        (KEYPOINT_MAP["left_f_shoulder"], KEYPOINT_MAP["left_f_wrist"]), (KEYPOINT_MAP["left_f_wrist"], KEYPOINT_MAP["left_f_ankle"]),
        (KEYPOINT_MAP["left_b_shoulder"], KEYPOINT_MAP["left_b_wrist"]), (KEYPOINT_MAP["left_b_wrist"], KEYPOINT_MAP["left_b_ankle"]),
        (KEYPOINT_MAP["right_f_shoulder"], KEYPOINT_MAP["right_f_wrist"]), (KEYPOINT_MAP["right_f_wrist"], KEYPOINT_MAP["right_f_ankle"]),
        (KEYPOINT_MAP["right_b_shoulder"], KEYPOINT_MAP["right_b_wrist"]), (KEYPOINT_MAP["right_b_wrist"], KEYPOINT_MAP["right_b_ankle"]),
        (KEYPOINT_MAP["left_f_shoulder"], KEYPOINT_MAP["right_f_shoulder"]), (KEYPOINT_MAP["left_b_shoulder"], KEYPOINT_MAP["right_b_shoulder"]),
        (KEYPOINT_MAP["left_f_shoulder"], KEYPOINT_MAP["left_b_shoulder"]), (KEYPOINT_MAP["right_f_shoulder"], KEYPOINT_MAP["right_b_shoulder"]),
        (KEYPOINT_MAP["left_b_shoulder"], KEYPOINT_MAP["tail_s"]), (KEYPOINT_MAP["right_b_shoulder"], KEYPOINT_MAP["tail_s"]),
        (KEYPOINT_MAP["tail_s"], KEYPOINT_MAP["tail_e"]), (KEYPOINT_MAP["nose"], KEYPOINT_MAP["mouth"]),
        (KEYPOINT_MAP["nose"], KEYPOINT_MAP["left_mid_ear"]), (KEYPOINT_MAP["nose"], KEYPOINT_MAP["right_mid_ear"]),
        (KEYPOINT_MAP["left_mid_ear"], KEYPOINT_MAP["left_edge_ear"]), (KEYPOINT_MAP["right_mid_ear"], KEYPOINT_MAP["right_edge_ear"]),
        (KEYPOINT_MAP["nose"], KEYPOINT_MAP["left_f_shoulder"]), (KEYPOINT_MAP["nose"], KEYPOINT_MAP["right_f_shoulder"]),
    ]
    A = create_normalized_adjacency(NUM_NODES, connections).to(DEVICE)

    # --- 9. 모델, 손실 함수, 옵티마이저 초기화 (수정) ---
    model = DogEmotionSTGCN(
        in_channels=C_IN, num_classes=NUM_CLASSES, A=A,
        num_nodes=NUM_NODES, edges=None
    ).to(DEVICE)

    criterion = nn.CrossEntropyLoss()
    print(f"\n일반 손실 함수 사용")

    optimizer = optim.AdamW(model.parameters(), lr=LEARNING_RATE, weight_decay=WEIGHT_DECAY)
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='min', factor=0.2, patience=5)
    
    # Mixed Precision 학습용 Scaler (RTX 5080 최적화)
    scaler = torch.cuda.amp.GradScaler() if USE_AMP else None

    print("\n모델 구성:"); print(f"  - 입력 채널: {C_IN}"); print(f"  - 노드 수: {NUM_NODES}");
    print(f"  - 감정 클래스: {NUM_CLASSES}"); print(f"  - 세그먼트 길이: {SEG_LEN}"); 
    print(f"  - 배치 크기: {BATCH_SIZE}"); print(f"  - 디바이스: {DEVICE}");
    print(f"  - Mixed Precision: {'ON' if USE_AMP else 'OFF'}");

    # --- 10. 학습(Training) 및 평가(Evaluation) 루프 (수정) ---
    print("\n" + "="*50); print("감정 분류 모델 훈련 시작 (비디오 단위 평가)"); print("="*50)

    best_val_acc = 0.0
    best_val_f1_macro = 0.0  # [수정] weighted → macro
    best_epoch_acc = 0  # Accuracy 최고 달성 epoch
    best_epoch_f1 = 0   # F1-macro 최고 달성 epoch
    patience_counter = 0
    emotion_names = [name for name, idx in sorted(emotion_mapping.items(), key=lambda item: item[1])]
    
    val_losses = [] # 스케줄러용

    for epoch in range(EPOCHS):
        # Training Phase
        model.train(); running_loss = 0.0
        train_dataset_len = actual_train_len 
        
        # ▼▼▼ [수정] Mixed Precision 학습 적용 ▼▼▼
        pbar = tqdm(train_loader, desc=f"Epoch {epoch+1}/{EPOCHS} Training")
        for batch_count, (inputs, labels, _) in enumerate(pbar):
            if inputs is None or labels is None or not isinstance(labels, torch.Tensor) or labels.dtype != torch.long or (labels == -1).any(): continue
            inputs, labels = inputs.to(DEVICE), labels.to(DEVICE)
            if labels.max() >= NUM_CLASSES or labels.min() < 0: continue
            
            optimizer.zero_grad()
            
            # Mixed Precision Forward & Backward
            if USE_AMP:
                with torch.cuda.amp.autocast():
                    outputs = model(inputs)
                    loss = criterion(outputs, labels)
                
                if torch.isnan(loss): 
                    print(f"경고: Epoch {epoch+1}, Train Batch {batch_count+1} - NaN Loss!"); 
                    continue
                
                scaler.scale(loss).backward()
                scaler.unscale_(optimizer)
                torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
                scaler.step(optimizer)
                scaler.update()
            else:
                outputs = model(inputs)
                loss = criterion(outputs, labels)
                
                if torch.isnan(loss): 
                    print(f"경고: Epoch {epoch+1}, Train Batch {batch_count+1} - NaN Loss!"); 
                    continue
                    
                loss.backward()
                torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
                optimizer.step()
            
            running_loss += loss.item() * inputs.size(0)
            pbar.set_postfix({'loss': loss.item()})
            
        epoch_loss = running_loss / train_dataset_len if train_dataset_len > 0 else 0
        # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

        # ▼▼▼▼▼ [수정] Validation Phase (Soft Voting) (오류 4 수정) ▼▼▼▼▼
        model.eval(); val_loss = 0.0
        video_outputs = defaultdict(list)
        video_true_labels = {}
        
        val_dataset_len = actual_val_len 
        if val_dataset_len == 0:
             acc, f1_macro, report_str, epoch_val_loss = 0.0, 0.0, "검증셋 비어있음.", 0.0
             print("경고: 검증셋 비어있음.")
        else:
            with torch.no_grad():
                for inputs, labels, video_indices in tqdm(val_loader, desc=f"Epoch {epoch+1}/{EPOCHS} Validation"):
                    if inputs is None or labels is None or not isinstance(labels, torch.Tensor) or labels.dtype != torch.long or (labels == -1).any(): continue
                    inputs, labels = inputs.to(DEVICE), labels.to(DEVICE)
                    if labels.max() >= NUM_CLASSES or labels.min() < 0: continue
                    
                    outputs = model(inputs)
                    if torch.isnan(outputs).any(): outputs = torch.nan_to_num(outputs)
                    
                    loss = criterion(outputs, labels)
                    if not torch.isnan(loss): val_loss += loss.item() * inputs.size(0)
                    
                    probabilities = F.softmax(outputs, dim=1)
                    
                    for i in range(len(video_indices)):
                        vid_idx = video_indices[i].item()
                        prob = probabilities[i].cpu()
                        label = labels[i].item()
                        
                        video_outputs[vid_idx].append(prob)
                        video_true_labels[vid_idx] = label 

            epoch_val_loss = val_loss / val_dataset_len if val_dataset_len > 0 else 0
            val_losses.append(epoch_val_loss) # 스케줄러용
            
            all_labels = []
            all_predicted = []
            
            for vid_idx, probs_list in video_outputs.items():
                mean_prob = torch.mean(torch.stack(probs_list), dim=0)
                final_pred = torch.argmax(mean_prob).item()
                true_label = video_true_labels[vid_idx]
                
                all_labels.append(true_label)
                all_predicted.append(final_pred)

            if len(all_labels) > 0:
                acc = accuracy_score(all_labels, all_predicted) * 100
                f1_weighted = f1_score(all_labels, all_predicted, average='weighted', zero_division=0)
                f1_macro = f1_score(all_labels, all_predicted, average='macro', zero_division=0)
                report_str = classification_report(all_labels, all_predicted, target_names=emotion_names, labels=np.arange(NUM_CLASSES), digits=4, zero_division=0)
            else: 
                acc, f1_weighted, f1_macro, report_str = 0.0, 0.0, 0.0, "평가 샘플 없음."
        # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

        # 출력 (수정)
        print(f"\n--- Epoch [{epoch+1:3d}/{EPOCHS}] ---")
        print(f"Train Loss (Sample avg): {epoch_loss:.4f}")
        print(f"Val Loss (Sample avg): {epoch_val_loss:.4f} | Val Acc (Video avg): {acc:.2f}% | Val F1 (Weighted): {f1_weighted:.4f} | Val F1 (Macro): {f1_macro:.4f}")
        print("-" * 70); print("Validation Classification Report (Video Level):"); print(report_str); print("-" * 70)
        
        # 스케줄러 스텝 (Val Loss 기준)
        scheduler.step(epoch_val_loss)

        # ▼▼▼ [수정] 모델 저장 (accuracy와 f1-macro 각각 별도 저장) ▼▼▼
        is_best_acc = not np.isnan(acc) and acc > best_val_acc
        is_best_f1 = not np.isnan(f1_macro) and f1_macro > best_val_f1_macro  # [수정] macro 사용
        
        # Accuracy 최고 모델 저장
        if is_best_acc:
            best_val_acc = acc
            best_epoch_acc = epoch + 1
            patience_counter = 0
            
            checkpoint_acc = {
                'epoch': epoch + 1,
                'model_state_dict': model.state_dict(),
                'optimizer_state_dict': optimizer.state_dict(),
                'best_acc': best_val_acc,
                'f1_macro': f1_macro,
                'f1_weighted': f1_weighted,
                'label_encoder': train_dataset.labels_map
            }
            try:
                torch.save(checkpoint_acc, BEST_MODEL_PATH_ACC)
                print(f" *** 🏆 최고 Accuracy {best_val_acc:.2f}% 갱신! (Epoch {best_epoch_acc}) → {BEST_MODEL_PATH_ACC} 저장됨 ***")
            except Exception as e:
                print(f"오류: Accuracy 모델 저장 실패 - {e}")
        
        # F1-Macro 최고 모델 저장
        if is_best_f1:
            best_val_f1_macro = f1_macro  # [수정] macro 사용
            best_epoch_f1 = epoch + 1
            patience_counter = 0
            
            checkpoint_f1 = {
                'epoch': epoch + 1,
                'model_state_dict': model.state_dict(),
                'optimizer_state_dict': optimizer.state_dict(),
                'best_f1_macro': best_val_f1_macro,  # [수정] macro 사용
                'f1_weighted': f1_weighted,
                'acc': acc,
                'label_encoder': train_dataset.labels_map
            }
            try:
                torch.save(checkpoint_f1, BEST_MODEL_PATH_F1)
                print(f" *** 🏆 최고 F1(Macro) {best_val_f1_macro:.4f} 갱신! (Epoch {best_epoch_f1}) → {BEST_MODEL_PATH_F1} 저장됨 ***")
            except Exception as e:
                print(f"오류: F1 모델 저장 실패 - {e}")
        
        if not is_best_acc and not is_best_f1:
            patience_counter += 1
            
        if patience_counter >= PATIENCE:
            print(f"\n⏹️ 조기 종료 (patience: {PATIENCE})")
            break
        # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
    
    # 최종 결과 (수정)
    print("\n" + "="*50); print("학습 완료"); print("="*50)
    print(f"🏆 최고 검증 Accuracy (비디오 단위): {best_val_acc:.2f}% (Epoch {best_epoch_acc})")
    print(f"   → 모델 저장 경로: {BEST_MODEL_PATH_ACC}")
    print(f"\n🏆 최고 검증 F1(Macro) (비디오 단위): {best_val_f1_macro:.4f} (Epoch {best_epoch_f1})")
    print(f"   → 모델 저장 경로: {BEST_MODEL_PATH_F1}")
    print("="*50)

if __name__ == '__main__':
    main()