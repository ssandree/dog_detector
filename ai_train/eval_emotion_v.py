import torch
from torch import nn
from torch.utils.data import Dataset, DataLoader
import numpy as np
import os
import sys
import glob
from pathlib import Path
import json
import random
import math
# 메트릭 및 시각화 라이브러리
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, f1_score
import matplotlib.pyplot as plt
import seaborn as sns
# 이전 스크립트에서 필요한 요소 import
# train_emotion_v는 evaluate.py와 같은 폴더에 있다고 가정
from train_emotion_v import load_data_paths_and_labels_from_emotion_labels 
from dog_emotion_model.stgcn import DogEmotionSTGCN, create_normalized_adjacency 
# common 폴더 경로 추가 (train_emotion_v와 동일한 로직)
current_file_path_eval = os.path.abspath(__file__)
ai_train_dir_eval = os.path.dirname(current_file_path_eval)
project_root_dir_eval = os.path.dirname(ai_train_dir_eval)
if project_root_dir_eval not in sys.path:
    sys.path.append(project_root_dir_eval)
from common.data_preprocess import DogPoseDataset 

# --- 헬퍼 함수: 세그먼트 생성 ---
def create_overlapping_segments(data_np, seg_len, stride):
    """NumPy 배열 데이터를 겹치는 세그먼트로 나눕니다."""
    num_frames = data_np.shape[0]
    segments = []
    if num_frames == 0: # 빈 데이터 처리
        print("Warning: Input data has 0 frames. Cannot create segments.")
        return []
    elif num_frames < seg_len:
        # 루프 패딩
        num_repeats = math.ceil(seg_len / num_frames)
        looped_data = np.tile(data_np, (num_repeats, 1, 1))
        segments.append(looped_data[:seg_len])
    else:
        start_indices = range(0, num_frames - seg_len + 1, stride)
        for start in start_indices:
            segments.append(data_np[start : start + seg_len])
        # 마지막 세그먼트 포함 확인 및 추가
        last_start = start_indices[-1] if start_indices else 0
        if last_start + seg_len < num_frames:
             segments.append(data_np[-seg_len:])

    if not segments and num_frames > 0: # Fallback for edge cases
        num_repeats = math.ceil(seg_len / num_frames)
        looped_data = np.tile(data_np, (num_repeats, 1, 1))
        return [looped_data[:seg_len]]

    return segments

# --- 메인 평가 함수 ---
def evaluate_model(config):
    """주어진 설정을 바탕으로 모델 성능을 평가합니다."""
    print("="*50); print("모델 평가 시작"); print("="*50)
    print(f"Using device: {config['DEVICE']}")

    # --- 1. 데이터 로드 ---
    print("\n[1/5] 검증 데이터 로딩 중...")
    # ▼▼▼▼▼ [수정] is_training_set=False 인자 삭제 ▼▼▼▼▼
    val_paths, val_labels, emotion_mapping, _ = load_data_paths_and_labels_from_emotion_labels(
        config['VAL_EMOTION_LABEL_FILE'],
        f"{config['POSE_DATA_DIR']}/Validation" 
    )
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
    NUM_CLASSES = len(emotion_mapping)
    if not val_paths:
        print("오류: 평가할 검증 데이터가 없습니다.")
        return
    print(f"  > 평가 데이터 경로 수: {len(val_paths)}개")
    emotion_names = [name for name, idx in sorted(emotion_mapping.items(), key=lambda item: item[1])]

    # --- 2. 통계치 로드 ---
    print("\n[2/5] 통계 파일 로딩 중...")
    try:
        stats = torch.load(config['STATS_PATH'], map_location='cpu')
        mean = stats['mean']
        std = stats['std']
        # [추가] 로드된 통계 채널 수 확인
        if mean.shape[0] != config['C_IN']:
             print(f"오류: 설정된 채널 수({config['C_IN']})와 통계 파일의 채널 수({mean.shape[0]})가 다릅니다.")
             return
        print(f"  > 통계 파일 로드 완료: {config['STATS_PATH']}")
    except FileNotFoundError:
        print(f"오류: 통계 파일({config['STATS_PATH']}) 없음. 훈련을 먼저 실행하세요.")
        return
    except Exception as e:
        print(f"오류: 통계 파일 로딩 실패 - {e}")
        return

    # --- 3. 모델 구조 및 가중치 로드 ---
    print("\n[3/5] 모델 로딩 중...")
    # 뼈대 생성
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
    A = create_normalized_adjacency(config['NUM_NODES'], connections).to(config['DEVICE'])

    # 모델 구조 생성
    model = DogEmotionSTGCN(
        in_channels=config['C_IN'], num_classes=NUM_CLASSES, A=A,
        num_nodes=config['NUM_NODES'], edges=None
    ).to(config['DEVICE'])

    # 학습된 가중치 로드
    try:
        model.load_state_dict(torch.load(config['BEST_MODEL_PATH'], map_location=config['DEVICE']))
        model.eval() # 평가 모드
        print(f"  > 모델 가중치 로드 완료: {config['BEST_MODEL_PATH']}")
    except FileNotFoundError:
        print(f"오류: 모델 파일({config['BEST_MODEL_PATH']}) 없음. 훈련을 먼저 실행하세요.")
        return
    except Exception as e:
        print(f"오류: 모델 가중치 로딩 실패 - {e}")
        return

    # --- 4. 평가 실행 (평균 집계 방식) ---
    print("\n[4/5] 평가 실행 중 (평균 집계 방식)...")
    all_video_labels = []
    all_video_predicted = []

    # 임시 Dataset 인스턴스 (전처리 함수 사용 목적)
    # labels=[] 전달, train=False 명시
    temp_dataset = DogPoseDataset([], [], config['SEG_LEN'], config['STATS_PATH'], train=False)
    if temp_dataset.mean is None or temp_dataset.std is None:
         print("오류: 통계 로딩 실패.")
         return
    # mean, std를 target device로 미리 이동
    mean_dev = temp_dataset.mean.to(config['DEVICE'])
    std_dev = temp_dataset.std.to(config['DEVICE']).clamp(min=1e-6) # 0 방지

    processed_count = 0
    total_count = len(val_paths)

    with torch.no_grad():
        for i, (json_path, label) in enumerate(zip(val_paths, val_labels)):
            try:
                # 4.1. 비디오 데이터 로드 (_load_data 사용, 성공 인덱스 무시)
                video_data_list, _ = temp_dataset._load_data([json_path])
                if not video_data_list: continue
                video_np = video_data_list[0] # (T_full, V, C)

                # 4.2. 스무딩/보간 (선택적) - 필요시 주석 해제
                # video_np = temp_dataset._smooth_and_interpolate(video_np)

                # 4.3. 겹치는 세그먼트 생성
                segments_np = create_overlapping_segments(video_np, config['SEG_LEN'], config['STRIDE'])
                if not segments_np: continue

                segment_outputs = []
                for segment in segments_np:
                    # 4.4. 각 세그먼트 전처리 (Augment X)
                    seg_normalized = temp_dataset._normalize(segment) # 어깨 정규화
                    seg_tensor = torch.from_numpy(seg_normalized).float().permute(2, 0, 1) # (C, T, V)
                    
                    # 표준화 (미리 이동된 mean/std 사용)
                    permuted = seg_tensor.permute(1, 2, 0) # (T, V, C)
                    permuted = (permuted - mean_dev.cpu()) / std_dev.cpu() # CPU 계산 후 이동 (혹은 둘 다 GPU)
                    seg_tensor = permuted.permute(2, 0, 1).to(config['DEVICE']) # (C, T, V)

                    seg_tensor = seg_tensor.unsqueeze(0).unsqueeze(-1) # (1, C, T, V, M)

                    # 4.5. 모델 예측
                    output = model(seg_tensor) # (1, NUM_CLASSES)
                    segment_outputs.append(output)

                if not segment_outputs: continue

                # 4.6. 예측 결과 집계 (평균)
                stacked_outputs = torch.cat(segment_outputs, dim=0) # (Num_Segments, NUM_CLASSES)
                avg_output = torch.mean(stacked_outputs, dim=0) # (NUM_CLASSES)
                _, predicted_label = torch.max(avg_output, 0)

                all_video_labels.append(label)
                all_video_predicted.append(predicted_label.item()) # .item() 사용

                processed_count += 1
                if (processed_count) % 50 == 0: # 진행 상황 표시 (processed_count 기준)
                     print(f"  > {processed_count}/{total_count} 비디오 처리 완료...")

            except Exception as e:
                print(f"오류: {os.path.basename(json_path)} 처리 중 문제 발생 - {e}")
                import traceback
                traceback.print_exc() # 상세 오류 출력

    print(f"  > 총 {processed_count}개 비디오 평가 완료.")

    # --- 5. 최종 결과 리포트 및 시각화 ---
    print("\n[5/5] 최종 성능 리포트 생성 중...")
    if not all_video_labels:
        print("오류: 평가된 샘플이 없습니다.")
        return

    # 최종 메트릭 계산
    accuracy = accuracy_score(all_video_labels, all_video_predicted) * 100
    f1_macro = f1_score(all_video_labels, all_video_predicted, average='macro', zero_division=0)
    report = classification_report(all_video_labels, all_video_predicted,
                                   target_names=emotion_names,
                                   labels=np.arange(NUM_CLASSES), digits=4, zero_division=0)

    print("\n" + "="*70); print("                 최종 평가 결과 (평균 집계 방식)"); print("="*70)
    print(f"Overall Accuracy: {accuracy:.2f}%"); print(f"Overall F1-Score (Macro): {f1_macro:.4f}")
    print("-" * 70); print("Classification Report:"); print(report); print("-" * 70)

    # 혼동 행렬 시각화
    try:
        cm = confusion_matrix(all_video_labels, all_video_predicted, labels=np.arange(NUM_CLASSES))
        plt.figure(figsize=(8, 6))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                    xticklabels=emotion_names, yticklabels=emotion_names, annot_kws={"size": 12}) # 글자 크기 조절
        plt.xlabel('Predicted Label', fontsize=12)
        plt.ylabel('True Label', fontsize=12)
        plt.title('Confusion Matrix (Mean Aggregation)', fontsize=14)
        plt.xticks(rotation=45, ha='right'); plt.yticks(rotation=0) # 라벨 회전
        plt.tight_layout()
        cm_filename = "confusion_matrix_eval.png"
        plt.savefig(cm_filename)
        print(f"혼동 행렬 이미지 저장 완료: {cm_filename}")
    except Exception as e:
        print(f"오류: 혼동 행렬 생성 실패 - {e}")
        print("팁: matplotlib, seaborn 설치 확인 및 한글 폰트 설정 확인")

# --- 메인 실행 블록 ---
if __name__ == '__main__':
    # 평가 설정값 (train_emotion_v.py와 일치 또는 조정)
    config = {
        'NUM_NODES': 20,
        'SEG_LEN': 60,       # 훈련 시 사용했던 세그먼트 길이
        'C_IN': 3,
        'STRIDE': 22,        # 세그먼트 추출 간격 (SEG_LEN의 절반 정도)
        'DEVICE': torch.device('cuda' if torch.cuda.is_available() else 'cpu'),
        'POSE_DATA_DIR': '../pose_data',
        'VAL_EMOTION_LABEL_FILE': '../pose_data/Validation_label/validation_emotion_labels.json',
        'STATS_PATH': 'dog_pose_stats.pt', # 훈련 시 생성된 통계 파일
        'BEST_MODEL_PATH': 'best_dog_emotion_model_f1.pth' # 훈련 시 저장된 최고 모델
    }
    evaluate_model(config)

