import json
import random
import numpy as np
import torch
from torch.utils.data import Dataset, DataLoader

# calculate_and_save_stats 함수는 변경할 필요가 없습니다.
# Dataset이 세그먼트를 반환하므로, 그 결과물로 통계를 계산하는 것은 동일하게 유효합니다.
def calculate_and_save_stats(dataset, stats_path):
    """
    주어진 데이터셋(훈련셋)에 대해 평균과 표준편차를 계산하고 파일로 저장합니다.
    """
    loader = DataLoader(dataset, batch_size=64, shuffle=False, num_workers=4)
    all_data = []
    print("Calculating statistics from the training set...")
    for data, _ in loader:
        all_data.append(data)
    stacked_data = torch.cat(all_data, dim=0)
    c_dim_data = stacked_data.permute(0, 2, 3, 4, 1).contiguous().view(-1, stacked_data.shape[1])
    mean = torch.mean(c_dim_data, dim=0)
    std = torch.std(c_dim_data, dim=0)
    std[std == 0] = 1.0
    stats = {'mean': mean, 'std': std}
    torch.save(stats, stats_path)
    print(f"Statistics saved to {stats_path}")
    print(f"Mean: {mean.numpy()}")
    print(f"Std: {std.numpy()}")
    return stats

class DogPoseDataset(Dataset):
    """
    (설명은 이전과 동일)
    """
    # ▼▼▼▼▼ [수정] __init__ 메서드: max_frames를 seg_len으로 변경 ▼▼▼▼▼
    def __init__(self, json_paths, labels, seg_len, stats_path=None, train=True):
        self.labels = labels
        self.seg_len = seg_len  # 고정된 세그먼트 길이
        self.train = train
        self.data = self._load_data(json_paths)
        
        self.mean = None
        self.std = None
        if stats_path:
            try:
                stats = torch.load(stats_path)
                self.mean = stats['mean']
                self.std = stats['std']
            except FileNotFoundError:
                print(f"Warning: Statistics file not found at {stats_path}. Standardization will be skipped.")
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        sample = self.data[idx].copy()
        label = self.labels[idx]

        # ▼▼▼▼▼ [수정] 패딩 대신 랜덤/중앙 샘플링 로직 적용 ▼▼▼▼▼
        num_frames = sample.shape[0]
        if num_frames > self.seg_len:
            if self.train:
                # 훈련 시: 랜덤한 시작점에서 세그먼트 길이만큼 자름 (Data Augmentation)
                start_idx = random.randint(0, num_frames - self.seg_len)
                sample = sample[start_idx : start_idx + self.seg_len]
            else:
                # 테스트 시: 중앙에서 세그먼트 길이만큼 자름 (일관성 유지)
                start_idx = (num_frames - self.seg_len) // 2
                sample = sample[start_idx : start_idx + self.seg_len]
        else:
            # 영상 길이가 세그먼트보다 짧으면 패딩
            sample = self._pad(sample, self.seg_len)
        # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

        # 정규화 및 증강 (순서는 그대로 유지)
        sample = self._normalize(sample)
        if self.train:
            sample = self._augment(sample)

        final_tensor = torch.from_numpy(sample).permute(2, 0, 1).float()
        
        # 표준화 단계 (순서는 그대로 유지)
        if self.mean is not None and self.std is not None:
            permuted_tensor = final_tensor.permute(1, 2, 0)
            permuted_tensor = (permuted_tensor - self.mean) / self.std
            final_tensor = permuted_tensor.permute(2, 0, 1)
            
        final_tensor = final_tensor.unsqueeze(-1)
        return final_tensor, label

    def _load_data(self, json_paths):
        # 이 리스트는 train_emotion_v.py의 ALL_KEYPOINT_NAMES와
        # 순서/이름이 100% 동일해야 합니다.
        ALL_KEYPOINT_NAMES = [
            "left_f_wrist", "left_f_ankle", "left_f_shoulder",
            "left_b_wrist", "left_b_ankle", "left_b_shoulder", 
            "right_f_wrist", "right_f_ankle", "right_f_shoulder",
            "right_b_wrist", "right_b_ankle", "right_b_shoulder",
            "tail_s", "tail_e", "left_mid_ear", "right_mid_ear",
            "nose", "mouth", "left_edge_ear", "right_edge_ear"
        ]

        data_list = []
        for path in json_paths:
            # ... (JSON 로딩 로직)
            try:
                with open(path, 'r') as f:
                    json_content = json.load(f)
                dog_id = list(json_content.keys())[0]
                json_data = json_content[dog_id]
                # (ai_core_module.py와의 호환성을 위해 'frames' 키 체크)
                if 'frames' in json_data: 
                    json_data = json_data['frames']
            except Exception as e:
                print(f"Error loading {path}: {e}")
                continue

            sorted_frames = sorted(json_data.items(), key=lambda item: int(item[0].split('_')[1]))
            
            frames_data = []
            for frame_key, keypoints_dict in sorted_frames:
                
                # [수정된 핵심 로직] 순서를 보장하도록 ALL_KEYPOINT_NAMES 리스트로 조회
                frame_joints = []
                for name in ALL_KEYPOINT_NAMES:
                    # .get()을 사용하여 키가 없어도 0으로 채움
                    kp_data = keypoints_dict.get(name, {'x': 0, 'y': 0, 'confidence': 0})
                    # (x, y, c) 3개 값을 리스트로 추가
                    frame_joints.append([kp_data.get('x', 0), kp_data.get('y', 0), kp_data.get('confidence', 0)])
                
                frames_data.append(frame_joints)

            if frames_data: # 데이터가 있을 때만 추가
                data_list.append(np.array(frames_data))
                
        return data_list


    def _normalize(self, sample):
        # ... (이전과 동일)
        left_shoulder_idx, right_shoulder_idx = 2, 8
        for i, frame in enumerate(sample):
            left_shoulder = frame[left_shoulder_idx, :2]
            right_shoulder = frame[right_shoulder_idx, :2]
            if np.all(left_shoulder != 0) and np.all(right_shoulder != 0):
                center = (left_shoulder + right_shoulder) / 2
                sample[i, :, :2] = sample[i, :, :2] - center
        return sample

    def _augment(self, sample):
        # ... (이전과 동일)
        if random.random() > 0.5:
            shear_factor = random.uniform(-0.3, 0.3)
            M = np.array([[1, shear_factor], [0, 1]])
            sample[:, :, :2] = sample[:, :, :2] @ M.T
        if random.random() > 0.5:
            angle = random.uniform(-20, 20)
            rad_angle = np.deg2rad(angle)
            c, s = np.cos(rad_angle), np.sin(rad_angle)
            M = np.array([[c, -s], [s, c]])
            sample[:, :, :2] = sample[:, :, :2] @ M.T
        return sample

    # ▼▼▼▼▼ [수정] _pad 메서드가 길이를 인자로 받도록 변경 ▼▼▼▼▼
    def _pad(self, sample, target_len):
        padded_sample = np.zeros((target_len, sample.shape[1], sample.shape[2]))
        if sample.shape[0] >= target_len:
            # 이 경우는 거의 발생하지 않지만 안전장치로 둠
            padded_sample = sample[:target_len]
        else:
            padded_sample[:sample.shape[0]] = sample
        return padded_sample
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

# --- 사용 예시 ---
if __name__ == '__main__':
    # 가상 데이터 경로와 라벨 생성
    dummy_train_paths = ['train_dog1.json', 'train_dog2.json', 'train_dog3.json']
    dummy_train_labels = [0, 1, 0]
    dummy_test_paths = ['test_dog1.json', 'test_dog2.json']
    dummy_test_labels = [1, 0]
    
    # 가상 JSON 파일 생성
    for i, path in enumerate(dummy_train_paths + dummy_test_paths):
        dog_id = f"dog_{i}"
        frames_dict = {}
        # 100~200 프레임 사이의 랜덤 길이 영상 생성
        for f_idx in range(random.randint(50, 100)):
            frames_dict[f"frame_{f_idx}"] = {f"joint_{j}": {"x":random.random(), "y":random.random(), "confidence":random.random()} for j in range(20)}
        with open(path, 'w') as f:
            json.dump({dog_id: frames_dict}, f)

    # ▼▼▼▼▼ [수정] max_frames 대신 seg_len 사용 ▼▼▼▼▼
    STATS_PATH = 'dog_pose_stats.pt'
    SEG_LEN = 60 # 60프레임짜리 세그먼트로 훈련

    # 1. 훈련 데이터셋으로 통계치 계산
    temp_train_dataset = DogPoseDataset(json_paths=dummy_train_paths, labels=dummy_train_labels, seg_len=SEG_LEN, train=False)
    calculate_and_save_stats(temp_train_dataset, STATS_PATH)
    
    print("\n--- Applying saved statistics to all datasets ---")

    # 2. 훈련/테스트 데이터셋 최종 생성
    train_dataset = DogPoseDataset(json_paths=dummy_train_paths, labels=dummy_train_labels, seg_len=SEG_LEN, stats_path=STATS_PATH, train=True)
    test_dataset = DogPoseDataset(json_paths=dummy_test_paths, labels=dummy_test_labels, seg_len=SEG_LEN, stats_path=STATS_PATH, train=False)

    # 3. 데이터로더 생성
    train_loader = DataLoader(train_dataset, batch_size=2)
    
    # 훈련 로더에서 데이터 확인
    print("\n--- Train Loader Output ---")
    for data, label in train_loader:
        # 출력되는 데이터의 프레임 길이(T)가 seg_len과 일치하는지 확인
        print(f"Train Batch Data Shape: {data.shape}") # [2, 3, 60, 20, 1] 형태가 나와야 함
        break
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲