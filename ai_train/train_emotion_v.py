import torch
from torch import nn
from torch import optim
# [수정] WeightedRandomSampler 임포트
from torch.utils.data import DataLoader, WeightedRandomSampler
import numpy as np
import os
import sys
import glob
from pathlib import Path
import json
import random
from sklearn.metrics import f1_score, precision_score, accuracy_score, classification_report
import math # 제곱근 계산 위해

# --- 1. 시스템 경로 설정 ---
current_file_path = os.path.abspath(__file__)
ai_train_dir = os.path.dirname(current_file_path)
project_root_dir = os.path.dirname(ai_train_dir)
if project_root_dir not in sys.path:
    sys.path.append(project_root_dir)

# --- 2. 실제 모듈 임포트 ---
from dog_emotion_model.stgcn import DogEmotionSTGCN, create_normalized_adjacency
# 사용할 통계 계산 함수 import
from common.data_preprocess import DogPoseDataset, calculate_and_save_stats

# --- 3. 실제 데이터 로딩 함수 (오버샘플링 로직 완전 삭제) ---
def load_data_paths_and_labels_from_emotion_labels(emotion_label_file, pose_data_dir):
    """
    감정 라벨 JSON 파일을 기반으로 포즈 데이터 경로와 라벨, 감정별 개수를 생성합니다.
    (오버샘플링 로직 없음)
    """
    emotion_mapping = {
        "편안/안정": 0,
        "불안/슬픔": 1,
        "공포": 2,
        "공격성": 3
    }

    try:
        with open(emotion_label_file, 'r', encoding='utf-8') as f:
            emotion_labels = json.load(f)
    except FileNotFoundError:
        print(f"오류: 라벨 파일을 찾을 수 없습니다 - {emotion_label_file}")
        return [], [], emotion_mapping, {}
    except json.JSONDecodeError:
        print(f"오류: 라벨 파일({emotion_label_file})이 올바른 JSON 형식이 아닙니다.")
        return [], [], emotion_mapping, {}

    initial_json_paths = []
    initial_labels = []
    missing_files = []
    pose_data_path = Path(pose_data_dir)

    # 1단계: 라벨 파일 기준으로 존재하는 JSON 경로와 라벨 수집
    for video_name, emotion_info in emotion_labels.items():
        if not isinstance(emotion_info, dict): continue
        emotion = emotion_info.get('inspect_emotion', 'Unknown')
        if emotion not in emotion_mapping: continue
        base_name = video_name.replace('.mp4', '')
        json_filename = f"{base_name}.json"
        json_file_path = pose_data_path / json_filename
        if json_file_path.exists():
            initial_json_paths.append(str(json_file_path))
            initial_labels.append(emotion_mapping[emotion])
        else:
            missing_files.append(str(json_file_path))

    print(f"\n'{os.path.basename(emotion_label_file)}' 기준 (원본):")
    print(f"  > 로딩 시도 파일 수: {len(emotion_labels)}")
    print(f"  > 실제 로딩된 파일 경로 수: {len(initial_json_paths)}개")
    if missing_files: print(f"  > 누락된 파일 경로 수: {len(missing_files)}개")

    # 원본 감정별 개수 계산 및 출력
    initial_emotion_counts = {}
    for label in initial_labels:
        try:
            emotion_name = [k for k, v in emotion_mapping.items() if v == label][0]
            initial_emotion_counts[emotion_name] = initial_emotion_counts.get(emotion_name, 0) + 1
        except IndexError: continue

    print("  > 원본 감정별 분포:")
    for name, idx in sorted(emotion_mapping.items(), key=lambda item: item[1]):
         count = initial_emotion_counts.get(name, 0)
         print(f"    - {name} ({idx}): {count}개")

    # [수정] 오버샘플링 로직 없음

    # 최종 결과 반환
    return initial_json_paths, initial_labels, emotion_mapping, initial_emotion_counts

def main():
    """메인 실행 함수"""
    # --- 4. 하이퍼파라미터 및 설정 ---
    NUM_NODES = 20
    SEG_LEN = 60      # 비디오 세그먼트 길이 (프레임 단위)
    C_IN = 3          # 입력 채널 수 (x, y, confidence)
    # NUM_CLASSES는 데이터 로딩 후 결정됨
    EPOCHS = 200       # 총 학습 에포크
    BATCH_SIZE = 128  # 배치 크기 (조절 가능)
    LEARNING_RATE = 1e-3 # 학습률 (조절 가능, 1e-5 또는 1e-4)
    WEIGHT_DECAY = 1e-4    # 가중치 감쇠
    DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    NUM_WORKERS = 12   # 오류 시 0, 안정적이면 4, 8, 12 등

    # 경로 설정
    POSE_DATA_DIR = '../pose_data'
    TRAIN_EMOTION_LABEL_FILE = '../pose_data/Training_label/training_emotion_labels.json'
    VAL_EMOTION_LABEL_FILE = '../pose_data/Validation_label/validation_emotion_labels.json'
    STATS_PATH = 'dog_pose_stats.pt'
    BEST_MODEL_PATH = 'best_dog_emotion_model_f1.pth'

    print(f"Using device: {DEVICE}")

    # --- 5. 실제 데이터 로딩 ---
    print("="*50); print("실제 감정 라벨 데이터를 로딩합니다...");
    # [수정] is_training_set=True 제거, 원본 분포(initial_train_counts_dict) 받기
    train_paths, initial_train_labels, emotion_mapping, initial_train_counts_dict = load_data_paths_and_labels_from_emotion_labels(
        TRAIN_EMOTION_LABEL_FILE, f"{POSE_DATA_DIR}/Training"
    )
    val_paths, initial_val_labels, _, _ = load_data_paths_and_labels_from_emotion_labels(
        VAL_EMOTION_LABEL_FILE, f"{POSE_DATA_DIR}/Validation"
    )

    NUM_CLASSES = len(emotion_mapping)
    if NUM_CLASSES == 0 or not train_paths or not val_paths:
        print("오류: 훈련 또는 검증 데이터를 로드하지 못했습니다.")
        return

    print(f"\nTraining 경로 수 (원본): {len(train_paths)}개");
    print(f"Validation 경로 수 (원본): {len(val_paths)}개")
    print(f"감정 클래스 ({NUM_CLASSES}개): {emotion_mapping}"); print("="*50)

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

    # --- 7. 실제 데이터셋 생성 및 샘플러 가중치 계산 ---
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
    print(f"실제 로드된 훈련 샘플 수: {actual_train_len}")
    print(f"실제 로드된 검증 샘플 수: {actual_val_len}")
    actual_train_labels = train_dataset.labels # Dataset 내부의 필터링된 라벨

    # ▼▼▼▼▼ [수정] WeightedRandomSampler 로직 복원 ▼▼▼▼▼
    train_sampler = None
    use_shuffle = True
    if actual_train_len > 0:
        counts = np.bincount(actual_train_labels, minlength=NUM_CLASSES)
        print("실제 로드된 훈련 데이터 감정별 분포:")
        for name, idx in sorted(emotion_mapping.items(), key=lambda item: item[1]):
             print(f"    - {name} ({idx}): {counts[idx] if idx < len(counts) else 0}개")

        if NUM_CLASSES > 0 and all(c > 0 for c in counts) and len(actual_train_labels) == actual_train_len:
            # 제곱근 역수 가중치 계산
            weights_per_class = [1.0 / c for c in counts]
            sample_weights = [weights_per_class[label] for label in actual_train_labels]
            sampler_weights = torch.DoubleTensor(sample_weights)
            train_sampler = WeightedRandomSampler(sampler_weights, num_samples=actual_train_len, replacement=True)
            print("WeightedRandomSampler 생성 완료 (제곱근 역수 가중치).")
            use_shuffle = False
        else:
             if len(actual_train_labels) != actual_train_len: print("경고: Dataset 라벨/데이터 수 불일치. Sampler 미사용.")
             elif not all(c > 0 for c in counts): print("경고: 훈련 데이터에 일부 클래스 부재. Sampler 미사용.")
             train_sampler, use_shuffle = None, True
    else: print("경고: 훈련 데이터 없음. Sampler 미사용."); train_sampler, use_shuffle = None, True
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

    # DataLoader 생성
    print("\nDataLoader 생성 중...")
    try:
        train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, sampler=train_sampler,
                                  num_workers=NUM_WORKERS, pin_memory=True if DEVICE=='cuda' else False,
                                  shuffle=use_shuffle) # sampler 사용 시 shuffle=False
        val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE, shuffle=False,
                                num_workers=NUM_WORKERS, pin_memory=True if DEVICE=='cuda' else False)
        print("DataLoaders 생성 완료.")
    except Exception as e: print(f"오류: DataLoader 생성 실패 - {e}"); return

    # --- 8. 뼈대(Adjacency Matrix) 생성 ---
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

    # --- 9. 모델, 손실 함수, 옵티마이저 초기화 ---
    model = DogEmotionSTGCN(
        in_channels=C_IN, num_classes=NUM_CLASSES, A=A,
        num_nodes=NUM_NODES, edges=None
    ).to(DEVICE)

    # ▼▼▼▼▼ [수정] 가중 손실 함수 로직 제거 (샘플러 사용) ▼▼▼▼▼
    criterion = nn.CrossEntropyLoss()
    print("\n일반 손실 함수 사용 (WeightedRandomSampler 적용됨).")
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

    optimizer = optim.AdamW(model.parameters(), lr=LEARNING_RATE, weight_decay=WEIGHT_DECAY)
    
    # 학습률 스케줄러 (Val Loss 기준)
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='min', factor=0.2, patience=5, verbose=True)

    print("\n모델 구성:"); print(f"  - 입력 채널: {C_IN}"); print(f"  - 노드 수: {NUM_NODES}");
    print(f"  - 감정 클래스: {NUM_CLASSES}"); print(f"  - 세그먼트 길이: {SEG_LEN}"); print(f"  - 디바이스: {DEVICE}");

    # --- 10. 학습(Training) 및 평가(Evaluation) 루프 ---
    print("\n" + "="*50); print("감정 분류 모델 훈련 시작"); print("="*50)

    best_val_f1 = 0.0
    emotion_names = [name for name, idx in sorted(emotion_mapping.items(), key=lambda item: item[1])]

    for epoch in range(EPOCHS):
        # Training Phase
        model.train(); running_loss = 0.0
        train_dataset_len = len(train_dataset)
        if train_dataset_len == 0: epoch_loss = 0.0; print("경고: 훈련셋 비어있음.")
        else:
            for batch_count, (inputs, labels) in enumerate(train_loader):
                if inputs is None or labels is None or not isinstance(labels, torch.Tensor) or labels.dtype != torch.long or (labels == -1).any(): continue
                inputs, labels = inputs.to(DEVICE), labels.to(DEVICE)
                if labels.max() >= NUM_CLASSES or labels.min() < 0: continue
                optimizer.zero_grad()
                outputs = model(inputs)
                loss = criterion(outputs, labels)
                if torch.isnan(loss): print(f"경고: Epoch {epoch+1}, Train Batch {batch_count+1} - NaN Loss!"); continue
                loss.backward()
                torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
                optimizer.step()
                running_loss += loss.item() * inputs.size(0)
            epoch_loss = running_loss / train_dataset_len if train_dataset_len > 0 else 0

        # Validation Phase
        model.eval(); val_loss = 0.0; all_labels = []; all_predicted = []
        val_dataset_len = len(val_dataset)
        if val_dataset_len == 0: acc, f1_macro, report, epoch_val_loss = 0.0, 0.0, "검증셋 비어있음.", 0.0; print("경고: 검증셋 비어있음.")
        else:
            with torch.no_grad():
                for inputs, labels in val_loader:
                    if inputs is None or labels is None or not isinstance(labels, torch.Tensor) or labels.dtype != torch.long or (labels == -1).any(): continue
                    inputs, labels = inputs.to(DEVICE), labels.to(DEVICE)
                    if labels.max() >= NUM_CLASSES or labels.min() < 0: continue
                    outputs = model(inputs)
                    if torch.isnan(outputs).any(): outputs = torch.nan_to_num(outputs)
                    loss = criterion(outputs, labels)
                    if not torch.isnan(loss): val_loss += loss.item() * inputs.size(0)
                    _, predicted = torch.max(outputs.data, 1)
                    all_labels.extend(labels.cpu().numpy()); all_predicted.extend(predicted.cpu().numpy())
            epoch_val_loss = val_loss / val_dataset_len if val_dataset_len > 0 else 0
            if len(all_labels) > 0:
                acc = accuracy_score(all_labels, all_predicted) * 100
                f1_macro = f1_score(all_labels, all_predicted, average='macro', zero_division=0)
                try: report = classification_report(all_labels, all_predicted, target_names=emotion_names, labels=np.arange(NUM_CLASSES), digits=4, zero_division=0)
                except ValueError as e: report = f"리포트 오류: {e}"
            else: acc, f1_macro, report = 0.0, 0.0, "평가 샘플 없음."

        # 출력
        print(f"\n--- Epoch [{epoch+1:3d}/{EPOCHS}] ---"); print(f"Train Loss: {epoch_loss:.4f} | Val Loss: {epoch_val_loss:.4f} | Overall Acc: {acc:.2f}% | Overall F1(Macro): {f1_macro:.4f}")
        print("-" * 70); print("Validation Classification Report:"); print(report); print("-" * 70)
        
        # 스케줄러 스텝 (Val Loss 기준)
        scheduler.step(epoch_val_loss)

        # 모델 저장
        if not np.isnan(f1_macro) and f1_macro > best_val_f1:
            best_val_f1 = f1_macro
            try: torch.save(model.state_dict(), BEST_MODEL_PATH); print(" *** 최고 F1(Macro) 갱신! 모델 저장됨 ***")
            except Exception as e: print(f"오류: 모델 저장 실패 - {e}")
    
    # 최종 결과
    print("\n" + "="*50); print("학습 완료"); print("="*50)
    print(f"최고 검증 F1(Macro): {best_val_f1:.4f}" if not np.isnan(best_val_f1) else "N/A"); print(f"모델 저장 경로: {BEST_MODEL_PATH}")

if __name__ == '__main__':
    main()

