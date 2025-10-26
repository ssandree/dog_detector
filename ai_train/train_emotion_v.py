import torch
from torch import nn
from torch import optim
from torch.utils.data import DataLoader
import numpy as np
import os
import sys
import glob
from pathlib import Path
import json # (더미 데이터 생성을 위해 추가)
import random # (더미 데이터 생성을 위해 추가)

# --- 1. 시스템 경로 설정 ---
# (ai_train 폴더 밖의 common 폴더를 찾기 위해)
current_file_path = os.path.abspath(__file__)
ai_train_dir = os.path.dirname(current_file_path)
project_root_dir = os.path.dirname(ai_train_dir)
if project_root_dir not in sys.path:
    sys.path.append(project_root_dir)

# --- 2. 실제 모듈 임포트 ---
# (모델)
from dog_emotion_model.stgcn import DogEmotionSTGCN, create_normalized_adjacency
# (진짜 데이터셋)
from common.data_processing.data_preprocess import DogPoseDataset, calculate_and_save_stats

# --- 3. (주석 처리) 실제 데이터 경로 스캔 함수 ---
# (나중에 실제 데이터 준비되면 주석 해제 후 사용)
# def load_data_paths_and_labels(data_root_dir):
#     """
#     폴더 구조(e.g., .../Training/happy/*.json)를 기반으로 
#     JSON 파일 경로 리스트와 라벨 리스트를 생성합니다.
#     """
#     json_paths = []
#     labels = []
#     emotion_mapping = {}
#     current_label_id = 0
#     
#     data_root = Path(data_root_dir)
#     emotion_folders = [f for f in data_root.iterdir() if f.is_dir()]
#     
#     for emotion_folder in emotion_folders:
#         emotion_name = emotion_folder.name
#         if emotion_name not in emotion_mapping:
#             emotion_mapping[emotion_name] = current_label_id
#             current_label_id += 1
#         
#         label_id = emotion_mapping[emotion_name]
#         
#         files = glob.glob(str(emotion_folder / "*.json"))
#         for file_path in files:
#             json_paths.append(str(file_path))
#             labels.append(label_id)
#             
#     return json_paths, labels, emotion_mapping

# --- 4. 하이퍼파라미터 및 설정 ---
NUM_NODES = 20
SEG_LEN = 45  # 세그먼트 길이
C_IN = 3      # 채널 수 (x, y, confidence)
NUM_CLASSES = 2 # (임시) 더미 라벨 0, 1

# (학습 설정)
EPOCHS = 10 # (임시) 더미 데이터이므로 10회만
BATCH_SIZE = 2
LEARNING_RATE = 0.001
DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
STATS_PATH = 'dog_pose_stats_dummy.pt' # (임시) 더미 통계 파일

print(f"Using device: {DEVICE}")

# --- 5. (수정) 임시 더미 데이터 생성 ---
# (나중에 실제 데이터 준비되면 이 블록 전체 삭제)
print("="*30)
print("경고: 실제 데이터 로딩이 주석 처리되었습니다.")
print("임시 더미 JSON 파일과 라벨을 생성합니다...")

# (data_preprocess.py의 main 블록에서 코드 차용)
ALL_KEYPOINT_NAMES_DUMMY = [ f"joint_{j}" for j in range(20) ]
dummy_train_paths = ['dummy_train_dog1.json', 'dummy_train_dog2.json', 'dummy_train_dog3.json', 'dummy_train_dog4.json']
dummy_train_labels = [0, 1, 0, 1]
dummy_val_paths = ['dummy_val_dog1.json', 'dummy_val_dog2.json']
dummy_val_labels = [1, 0]

for i, path in enumerate(dummy_train_paths + dummy_val_paths):
    dog_id = f"dog_{i}"
    frames_dict = {}
    # 60~100 프레임 사이의 랜덤 길이 영상 생성
    for f_idx in range(random.randint(60, 100)):
        frames_dict[f"frame_{f_idx}"] = {name: {"x":random.random(), "y":random.random(), "confidence":random.random()} for name in ALL_KEYPOINT_NAMES_DUMMY}
    with open(path, 'w') as f:
        json.dump({dog_id: frames_dict}, f)

train_paths = dummy_train_paths
train_labels = dummy_train_labels
val_paths = dummy_val_paths
val_labels = dummy_val_labels

print(f"임시 JSON 파일 생성 완료: {len(train_paths) + len(val_paths)}개")
print("="*30)

# --- 6. 통계치 계산 (최초 1회) ---
if not os.path.exists(STATS_PATH):
    print("Statistics file not found. Calculating from dummy data...")
    temp_train_dataset = DogPoseDataset(
        json_paths=train_paths, 
        labels=train_labels, 
        seg_len=SEG_LEN, 
        stats_path=None, 
        train=False
    )
    calculate_and_save_stats(temp_train_dataset, STATS_PATH)
else:
    print(f"Loading existing dummy statistics from {STATS_PATH}")

# --- 7. 실제 데이터셋 및 로더 생성 ---
print("Creating final datasets using dummy data...")
train_dataset = DogPoseDataset(
    json_paths=train_paths,
    labels=train_labels,
    seg_len=SEG_LEN,
    stats_path=STATS_PATH,
    train=True # 훈련 시 증강 켜기
)
val_dataset = DogPoseDataset(
    json_paths=val_paths,
    labels=val_labels,
    seg_len=SEG_LEN,
    stats_path=STATS_PATH,
    train=False # 검증 시 증강 끄기
)

train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True)
val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE, shuffle=False)
print("DataLoaders created.")

# --- 8. 뼈대(Adjacency Matrix) 생성 ---
ALL_KEYPOINT_NAMES = [
    "left_f_wrist", "left_f_ankle", "left_f_shoulder",
    "left_b_wrist", "left_b_ankle", "left_b_shoulder", 
    "right_f_wrist", "right_f_ankle", "right_f_shoulder",
    "right_b_wrist", "right_b_ankle", "right_b_shoulder",
    "tail_s", "tail_e", "left_mid_ear", "right_mid_ear",
    "nose", "mouth", "left_edge_ear", "right_edge_ear"
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
    in_channels=C_IN,
    num_classes=NUM_CLASSES, # 임시 (2)
    A=A,
    num_nodes=NUM_NODES,
    edges=None
).to(DEVICE)

criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE)

# --- 10. 학습(Training) 및 평가(Evaluation) 루프 ---
print("\n--- Start Training (with Dummy Data) ---")
best_val_acc = 0.0

for epoch in range(EPOCHS):
    model.train()
    running_loss = 0.0
    for inputs, labels in train_loader:
        inputs = inputs.to(DEVICE)
        labels = labels.to(DEVICE)
        
        optimizer.zero_grad()
        outputs = model(inputs)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        running_loss += loss.item() * inputs.size(0)
    
    epoch_loss = running_loss / len(train_dataset)

    model.eval()
    val_loss = 0.0
    correct = 0
    total = 0
    with torch.no_grad():
        for inputs, labels in val_loader:
            inputs = inputs.to(DEVICE)
            labels = labels.to(DEVICE)
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            val_loss += loss.item() * inputs.size(0)
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
            
    epoch_val_loss = val_loss / len(val_dataset)
    epoch_val_acc = 100 * correct / total
    
    print(f"Epoch [{epoch+1}/{EPOCHS}] | "
          f"Train Loss: {epoch_loss:.4f} | "
          f"Val Loss: {epoch_val_loss:.4f} | "
          f"Val Acc: {epoch_val_acc:.2f}%")

    if epoch_val_acc > best_val_acc:
        best_val_acc = epoch_val_acc
        torch.save(model.state_dict(), 'best_model_dummy.pth') # 임시 모델 저장
        print(f"*** 최고 성능 갱신! 임시 모델 저장됨 ***")

print("\n--- 학습 완료 (Dummy Data) ---")

# (생성된 임시 파일 삭제)
print("Cleaning up dummy files...")
for path in dummy_train_paths + dummy_val_paths:
    os.remove(path)
if os.path.exists(STATS_PATH):
    os.remove(STATS_PATH)
print("Done.")