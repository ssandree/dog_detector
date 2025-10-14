import json
import random
import numpy as np
import torch
from torch.utils.data import Dataset, DataLoader

# ▼▼▼▼▼ 1. [신규] 훈련셋 통계 계산 및 저장 함수 ▼▼▼▼▼
def calculate_and_save_stats(dataset, stats_path):
    """
    주어진 데이터셋(훈련셋)에 대해 평균과 표준편차를 계산하고 파일로 저장합니다.
    Args:
        dataset (Dataset): 통계치를 계산할 데이터셋 객체 (반드시 훈련셋이어야 함)
        stats_path (str): 통계치를 저장할 파일 경로
    """
    # 데이터 로더를 사용해 모든 데이터를 효율적으로 순회
    # 여기서는 통계 계산이 목적이므로 shuffle=False, batch_size는 적당히 크게 설정
    loader = DataLoader(dataset, batch_size=64, shuffle=False)
    
    all_data = []
    print("Calculating statistics from the training set...")
    for data, _ in loader:
        all_data.append(data)
    
    # 모든 배치를 하나의 큰 텐서로 결합
    stacked_data = torch.cat(all_data, dim=0)
    
    # (N, C, T, V, M) -> (N*T*V*M, C) 형태로 펼쳐서 C축(x,y,c)에 대해 계산
    # .permute()는 차원 순서를 바꾸는 함수
    c_dim_data = stacked_data.permute(0, 2, 3, 4, 1).contiguous().view(-1, stacked_data.shape[1])
    
    mean = torch.mean(c_dim_data, dim=0)
    std = torch.std(c_dim_data, dim=0)
    
    # std가 0인 경우를 방지 (분모가 0이 되면 안 됨)
    std[std == 0] = 1.0

    stats = {'mean': mean, 'std': std}
    torch.save(stats, stats_path)
    print(f"Statistics saved to {stats_path}")
    print(f"Mean: {mean.numpy()}")
    print(f"Std: {std.numpy()}")
    return stats
# ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

class DogPoseDataset(Dataset):
    """
    (설명은 이전과 동일)
    """
    # ▼▼▼▼▼ 2. [수정] __init__ 메서드: stats_path 추가 ▼▼▼▼▼
    def __init__(self, json_paths, labels, max_frames, stats_path=None, train=True):
        self.labels = labels
        self.max_frames = max_frames
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

        sample = self._normalize(sample)

        if self.train:
            sample = self._augment(sample)

        padded_sample = self._pad(sample)
        final_tensor = torch.from_numpy(padded_sample).permute(2, 0, 1).float()
        
        # ▼▼▼▼▼ 3. [수정] __getitem__: 표준화 단계 추가 ▼▼▼▼▼
        if self.mean is not None and self.std is not None:
            # (C, T, V) -> (T, V, C) 로 바꿔서 표준화 적용
            permuted_tensor = final_tensor.permute(1, 2, 0)
            permuted_tensor = (permuted_tensor - self.mean) / self.std
            # 다시 원래 순서 (C, T, V)로 복원
            final_tensor = permuted_tensor.permute(2, 0, 1)
        # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
            
        final_tensor = final_tensor.unsqueeze(-1)

        return final_tensor, label

    # _load_data, _normalize, _augment, _pad 메서드는 이전과 동일
    def _load_data(self, json_paths):
        data_list = []
        for path in json_paths:
            with open(path, 'r') as f:
                json_data = json.load(f)
            frames_data = [frame['joints'] for frame in json_data['frames']]
            data_list.append(np.array(frames_data))
        return data_list

    def _normalize(self, sample):
        left_shoulder_idx, right_shoulder_idx = 2, 8
        for i, frame in enumerate(sample):
            left_shoulder = frame[left_shoulder_idx, :2]
            right_shoulder = frame[right_shoulder_idx, :2]
            if np.all(left_shoulder != 0) and np.all(right_shoulder != 0):
                center = (left_shoulder + right_shoulder) / 2
                sample[i, :, :2] = sample[i, :, :2] - center
        return sample

    def _augment(self, sample):
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

    def _pad(self, sample):
        padded_sample = np.zeros((self.max_frames, sample.shape[1], sample.shape[2]))
        if sample.shape[0] >= self.max_frames:
            padded_sample = sample[:self.max_frames]
        else:
            padded_sample[:sample.shape[0]] = sample
        return padded_sample


