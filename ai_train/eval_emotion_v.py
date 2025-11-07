import torch
from torch import nn
from torch.utils.data import DataLoader
import torch.nn.functional as F
import numpy as np
import os
import sys
from pathlib import Path
from collections import defaultdict
from tqdm import tqdm
# 메트릭 및 시각화 라이브러리
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, f1_score
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.font_manager as fm
import platform

# 한글 폰트 설정
if platform.system() == 'Windows':
    plt.rcParams['font.family'] = 'Malgun Gothic'
elif platform.system() == 'Darwin':  # macOS
    plt.rcParams['font.family'] = 'AppleGothic'
else:  # Linux
    plt.rcParams['font.family'] = 'NanumGothic'
plt.rcParams['axes.unicode_minus'] = False

# train_emotion_v에서 함수 import
from train_emotion_v import load_data_from_final_folder
from dog_emotion_model.stgcn import DogEmotionSTGCN, create_normalized_adjacency 

# common 폴더 경로 추가
current_file_path_eval = os.path.abspath(__file__)
ai_train_dir_eval = os.path.dirname(current_file_path_eval)
project_root_dir_eval = os.path.dirname(ai_train_dir_eval)
if project_root_dir_eval not in sys.path:
    sys.path.append(project_root_dir_eval)
from common.data_preprocess_emotion import DogPoseDataset 


def evaluate_model(config):
    """train_emotion_v.py의 validation 방식과 완전히 동일하게 평가"""
    print("="*50); print("모델 평가 시작"); print("="*50)
    print(f"Using device: {config['DEVICE']}")

    # --- 1. 데이터 로드 (train_emotion_v.py와 동일) ---
    print("\n[1/4] 검증 데이터 로딩 중...")
    val_paths, val_labels, emotion_mapping, _ = load_data_from_final_folder(
        f"{config['POSE_DATA_DIR']}/Validation_final",
        config['VAL_EMOTION_LABEL_FILE']
    )
    NUM_CLASSES = len(emotion_mapping)
    if not val_paths:
        print("오류: 평가할 검증 데이터가 없습니다.")
        return
    print(f"  > 평가 데이터 경로 수: {len(val_paths)}개")
    emotion_names = [name for name, idx in sorted(emotion_mapping.items(), key=lambda item: item[1])]

    # --- 2. Dataset 및 DataLoader 생성 (train_emotion_v.py와 동일) ---
    print("\n[2/4] Dataset 및 DataLoader 생성 중...")
    val_dataset = DogPoseDataset(
        json_paths=val_paths, 
        labels=val_labels, 
        seg_len=config['SEG_LEN'],
        stats_path=config['STATS_PATH'], 
        train=False  # Augmentation 비활성화
    )
    
    val_loader = DataLoader(
        val_dataset, 
        batch_size=config['BATCH_SIZE'], 
        shuffle=False,
        num_workers=0,
        drop_last=False
    )
    
    actual_val_len = len(val_dataset)
    print(f"  > 검증 샘플(윈도우) 수: {actual_val_len}개")

    # --- 3. 모델 로드 (train_emotion_v.py와 동일) ---
    print("\n[3/4] 모델 로딩 중...")
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

    model = DogEmotionSTGCN(
        in_channels=config['C_IN'], num_classes=NUM_CLASSES, A=A,
        num_nodes=config['NUM_NODES'], edges=None
    ).to(config['DEVICE'])

    try:
        checkpoint = torch.load(config['BEST_MODEL_PATH'], map_location=config['DEVICE'])
        if isinstance(checkpoint, dict) and 'model_state_dict' in checkpoint:
            model.load_state_dict(checkpoint['model_state_dict'])
            print(f"  > 모델 가중치 로드 완료: {config['BEST_MODEL_PATH']}")
            if 'epoch' in checkpoint:
                print(f"  > 학습된 Epoch: {checkpoint['epoch']}")
        else:
            model.load_state_dict(checkpoint)
            print(f"  > 모델 가중치 로드 완료: {config['BEST_MODEL_PATH']}")
        model.eval()
    except FileNotFoundError:
        print(f"오류: 모델 파일({config['BEST_MODEL_PATH']}) 없음.")
        return
    except Exception as e:
        print(f"오류: 모델 가중치 로딩 실패 - {e}")
        return

    # --- 4. 평가 실행 (train_emotion_v.py의 Validation Phase와 완전히 동일) ---
    print("\n[4/4] 평가 실행 중 (Soft Voting - train_emotion_v.py와 동일 방식)...")
    
    model.eval()
    video_outputs = defaultdict(list)
    video_true_labels = {}
    
    if actual_val_len == 0:
        print("경고: 검증셋 비어있음.")
        return
    
    with torch.no_grad():
        for inputs, labels, video_indices in tqdm(val_loader, desc="평가 진행 중"):
            if inputs is None or labels is None or not isinstance(labels, torch.Tensor) or labels.dtype != torch.long or (labels == -1).any(): 
                continue
            inputs, labels = inputs.to(config['DEVICE']), labels.to(config['DEVICE'])
            if labels.max() >= NUM_CLASSES or labels.min() < 0: 
                continue
            
            outputs = model(inputs)
            if torch.isnan(outputs).any(): 
                outputs = torch.nan_to_num(outputs)
            
            probabilities = F.softmax(outputs, dim=1)
            
            for i in range(len(video_indices)):
                vid_idx = video_indices[i].item()
                prob = probabilities[i].cpu()
                label = labels[i].item()
                
                video_outputs[vid_idx].append(prob)
                video_true_labels[vid_idx] = label 

    # 비디오별 집계
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
        print("오류: 평가 샘플 없음.")
        return

    # --- 5. 결과 출력 ---
    print("\n" + "="*70)
    print(f"모델: {config['BEST_MODEL_PATH']}")
    print("="*70)
    print(f"Overall Accuracy (Video Level): {acc:.2f}%")
    print(f"Overall F1-Score (Weighted): {f1_weighted:.4f}")
    print(f"Overall F1-Score (Macro): {f1_macro:.4f}")
    print("-" * 70)
    print("Classification Report:")
    print(report_str)
    print("-" * 70)

    # 혼동 행렬 시각화
    try:
        cm = confusion_matrix(all_labels, all_predicted, labels=np.arange(NUM_CLASSES))
        plt.figure(figsize=(8, 6))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                    xticklabels=emotion_names, yticklabels=emotion_names, annot_kws={"size": 12})
        plt.xlabel('Predicted Label', fontsize=12)
        plt.ylabel('True Label', fontsize=12)
        model_name = config['BEST_MODEL_PATH'].replace('.pth', '')
        plt.title(f'Confusion Matrix - {model_name}', fontsize=14)
        plt.xticks(rotation=45, ha='right')
        plt.yticks(rotation=0)
        plt.tight_layout()
        cm_filename = f"confusion_matrix_{model_name}.png"
        plt.savefig(cm_filename)
        print(f"혼동 행렬 이미지 저장 완료: {cm_filename}")
    except Exception as e:
        print(f"오류: 혼동 행렬 생성 실패 - {e}")


if __name__ == '__main__':
    # train_emotion_v.py와 완전히 동일한 설정
    config = {
        'NUM_NODES': 20,
        'SEG_LEN': 30,
        'C_IN': 3,
        'BATCH_SIZE': 128,  # train과 동일
        'DEVICE': torch.device('cuda' if torch.cuda.is_available() else 'cpu'),
        'POSE_DATA_DIR': '../pose_data',
        'VAL_EMOTION_LABEL_FILE': '../pose_data/validation_final_labels.json',
        'STATS_PATH': 'dog_pose_stats.pt',
        'BEST_MODEL_PATH': 'best_dog_emotion_model_f1.pth'
    }
    
    print("\n" + "="*80)
    print("두 가지 모델 평가 시작 (train_emotion_v.py와 동일한 방식)")
    print("="*80)
    
    # 1. Accuracy 최고 모델 평가
    print("\n[모델 1/2] Accuracy 최고 모델 평가")
    print("="*80)
    config['BEST_MODEL_PATH'] = 'best_dog_emotion_model_acc.pth'
    evaluate_model(config)
    
    # 2. F1-Macro 최고 모델 평가
    print("\n\n[모델 2/2] F1-Macro 최고 모델 평가")
    print("="*80)
    config['BEST_MODEL_PATH'] = 'best_dog_emotion_model_f1.pth'
    evaluate_model(config)
    
    print("\n" + "="*80)
    print("평가 완료!")
    print("="*80)
