import json
import random
import numpy as np
import torch
from torch.utils.data import Dataset, DataLoader
from scipy.signal import savgol_filter
import pandas as pd
import math
from tqdm import tqdm # Caching 진행률 표시

# --- 통계 계산 함수 (수정) ---
def calculate_and_save_stats(dataset, stats_path):
    """
    (tensor, label, video_idx) 3개를 반환하는 데이터셋용 통계 계산
    (Wrapper가 없다고 가정하고 dataset.processed_data에 접근)
    """
    loader = DataLoader(dataset, batch_size=64, shuffle=False, num_workers=0) 
    all_data = []
    print("Calculating statistics from the training set (might take time)...")
    
    try:
        # ▼▼▼ [수정] .raw_data -> .processed_data ▼▼▼
        if not hasattr(dataset, 'processed_data'):
             raise ValueError("Dataset structure incorrect. Expected dataset.processed_data")

        for data, _, _ in loader: # (tensor, label, video_idx) 3개 반환
            if isinstance(data, torch.Tensor) and data.nelement() > 0:
                 all_data.append(data)
        
        if not all_data:
            print("Error: No valid data loaded to calculate statistics.")
            try: c_in = dataset.processed_data[0].shape[2] if len(dataset.processed_data) > 0 else 3
            except: c_in = 3
            return {'mean': torch.zeros(c_in), 'std': torch.ones(c_in)}
        
        try:
            stacked_data = torch.cat(all_data, dim=0)
            c_dim_data = stacked_data.permute(0, 2, 3, 4, 1).contiguous().view(-1, stacked_data.shape[1])
            if c_dim_data.dtype != torch.float32: c_dim_data = c_dim_data.float()
            mean = torch.mean(c_dim_data, dim=0)
            std = torch.std(c_dim_data, dim=0)
            std[std < 1e-6] = 1.0
        except Exception as e:
             print(f"Error during statistics calculation: {e}")
             try: c_in = dataset.processed_data[0].shape[2] if len(dataset.processed_data) > 0 else 3
             except: c_in = 3
             return {'mean': torch.zeros(c_in), 'std': torch.ones(c_in)}
        
        stats = {'mean': mean, 'std': std}
        try:
            torch.save(stats, stats_path)
            print(f"Statistics saved to {stats_path}")
            print(f"  Mean: {mean.numpy()}")
            print(f"  Std: {std.numpy()}")
        except Exception as e: print(f"Error saving statistics file: {e}")
        return stats

    except Exception as outer_e:
        print(f"FATAL Error in calculate_and_save_stats: {outer_e}")
        return {'mean': torch.zeros(3), 'std': torch.ones(3)}
# ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

# --- 데이터셋 클래스 (슬라이딩 윈도우 적용) ---
class DogPoseDataset(Dataset):
    # ▼▼▼▼▼ [수정] __init__ (전처리 캐싱 로직 추가) ▼▼▼▼▼
    def __init__(self, json_paths, labels, seg_len, stats_path=None, train=True):
        self.seg_len = seg_len
        self.train = train
        
        # 1. 원본 데이터 로드
        original_json_paths = list(json_paths)
        original_labels = list(labels) # train.py에서 인코딩된 라벨이 들어옴
        try:
            # raw_data_list는 스무딩 전의 원본
            raw_data_list, loaded_indices = self._load_data(original_json_paths)
            self.labels_map = {}
            for i, video_idx in enumerate(loaded_indices):
                # i = raw_data_list의 인덱스
                self.labels_map[i] = original_labels[video_idx]
        except Exception as e:
             print(f"Error during data loading process: {e}")
             raw_data_list, self.labels_map = [], {}

        # 1.5. [핵심 수정] 스무딩/보간 전처리를 __init__에서 1회만 수행
        print(f"Applying pre-processing (smoothing/interpolation) to {len(raw_data_list)} videos...")
        self.processed_data = [] # 스무딩/보간이 완료된 데이터
        for video_array in tqdm(raw_data_list, desc="Pre-processing videos"):
            self.processed_data.append(self._smooth_and_interpolate(video_array))
        print("Pre-processing complete.")
        del raw_data_list # 메모리 확보

        # 통계 로드
        self.mean, self.std = None, None
        if stats_path:
            try:
                stats = torch.load(stats_path, map_location='cpu')
                self.mean, self.std = stats['mean'], stats['std']
                print(f"Loaded statistics from {stats_path}")
            except Exception as e: print(f"Warning: Failed to load stats '{stats_path}': {e}")
        if self.mean is None or self.std is None:
             print("Warning: Stats not loaded. Standardization will be skipped.")
             try: num_channels = self.processed_data[0].shape[2] if self.processed_data else 3
             except: num_channels = 3
             self.mean, self.std = torch.zeros(num_channels), torch.ones(num_channels)
        
        # 좌우 반전 맵 (이전과 동일)
        self.flip_pairs = [
            (0, 6), (1, 7), (2, 8),     # 앞다리
            (3, 9), (4, 10), (5, 11),   # 뒷다리
            (14, 15), (18, 19)          # 귀
        ]
        
        # 2. 슬라이딩 윈도우 샘플 생성 (stride=1로 모든 프레임 활용)
        self.samples = []
        stride = 1  # 모든 프레임 사용
        
        for video_idx in range(len(self.processed_data)):
            video_data = self.processed_data[video_idx] # 스무딩된 데이터 기준
            label = self.labels_map[video_idx]
            num_frames = video_data.shape[0]
            
            if num_frames < self.seg_len:
                self.samples.append((video_idx, -1, label))
            else:
                for start_frame in range(0, num_frames - self.seg_len + 1, stride):
                    self.samples.append((video_idx, start_frame, label))
        
        print(f"  -> {'Train' if train else 'Val'} set: {len(self.processed_data)} videos generated {len(self.samples)} samples (seg_len={seg_len}, stride={stride})")
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

    def __len__(self):
        return len(self.samples)

    # ▼▼▼▼▼ [수정] __getitem__ (스무딩 제거) ▼▼▼▼▼
    def __getitem__(self, idx):
        if not (0 <= idx < len(self.samples)):
             num_joints = 20; num_channels = self.mean.shape[0] if self.mean is not None else 3
             return torch.zeros((num_channels, self.seg_len, num_joints, 1)), -1, -1 # 3개 반환

        video_idx, start_frame, label = self.samples[idx]
        
        # 1. [수정] 스무딩/보간이 완료된 데이터(processed_data)에서 복사
        sample_processed = self.processed_data[video_idx].copy()

        # [삭제] _smooth_and_interpolate 호출 제거 (이미 __init__에서 완료)
        # sample = self._smooth_and_interpolate(sample_raw) 

        num_frames = sample_processed.shape[0]
        if num_frames == 0:
            num_joints = 20; num_channels = self.mean.shape[0] if self.mean is not None else 3
            return torch.zeros((num_channels, self.seg_len, num_joints, 1)), torch.tensor(label).long(), video_idx

        # 2. 샘플링 / 패딩
        if start_frame == -1:
            sample = self._pad_zero(sample_processed, self.seg_len) # 제로 패딩
        else:
            sample = sample_processed[start_frame : start_frame + self.seg_len]
            if sample.shape[0] < self.seg_len:
                sample = self._pad_zero(sample, self.seg_len)
            
        # 3. 정규화
        sample = self._normalize_and_scale(sample)

        # 4. ▼▼▼ [수정] 차등 증강 복원 (소수 클래스만) ▼▼▼
        if self.train:
            augment_loops = 0
            for _ in range(augment_loops):
                sample = self._augment(sample)
            # else: label == 0 (편안/안정)은 증강 안 함
        # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

        # 5. 텐서 변환
        final_tensor = torch.from_numpy(sample).float().permute(2, 0, 1)

        # 6. 표준화
        try:
            if self.mean is not None and self.std is not None and final_tensor.shape[0] == self.mean.shape[0]:
                mean_dev = self.mean.to(final_tensor.device)
                std_dev = self.std.to(final_tensor.device).clamp(min=1e-6)
                permuted_tensor = final_tensor.permute(1, 2, 0)
                permuted_tensor = (permuted_tensor - mean_dev) / std_dev
                final_tensor = permuted_tensor.permute(2, 0, 1)
            elif self.mean is not None and self.std is not None:
                 print(f"Warning: Channel mismatch (data {final_tensor.shape[0]}, stats {self.mean.shape[0]}). Skipping standardization.")
        except Exception as e: print(f"Error during standardization: {e}. Skipping.")

        # 7. 멤버 차원 추가
        final_tensor = final_tensor.unsqueeze(-1)
        label_tensor = torch.tensor(label).long()

        # 8. (텐서, 라벨, 비디오_인덱스) 3개 반환
        return final_tensor, label_tensor, video_idx
    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

    # --- 이하 헬퍼 함수들은 모두 그대로 유지 ---
    
    def _load_data(self, json_paths):
        ALL_KEYPOINT_NAMES = [
            "left_f_wrist", "left_f_ankle", "left_f_shoulder",
            "left_b_wrist", "left_b_ankle", "left_b_shoulder",
            "right_f_wrist", "right_f_ankle", "right_f_shoulder",
            "right_b_wrist", "right_b_ankle", "right_b_shoulder",
            "tail_s", "tail_e", "left_mid_ear", "right_mid_ear",
            "nose", "mouth", "left_edge_ear", "right_edge_ear"
        ]
        NUM_JOINTS = len(ALL_KEYPOINT_NAMES)
        NUM_CHANNELS = 3 # x, y, c
        data_list = []
        successfully_loaded_indices = []
        for idx, path in enumerate(json_paths):
            try:
                with open(path, 'r', encoding='utf-8') as f: json_content = json.load(f)
                first_key = list(json_content.keys())[0]
                if first_key.endswith(('.mp4', '.json')): json_data = json_content[first_key]
                else: json_data = json_content[first_key].get('frames', json_content[first_key])
                if not json_data: continue
                try:
                    sorted_frames = sorted(json_data.items(), key=lambda item: int(str(item[0]).split('_')[1]))
                except (ValueError, IndexError):
                    sorted_frames = sorted(json_data.items())
                if not sorted_frames: continue
                frames_data = []
                valid_frame_found = False
                for frame_key, keypoints_dict in sorted_frames:
                    if not isinstance(keypoints_dict, dict): continue
                    frame_joints = []
                    for name in ALL_KEYPOINT_NAMES:
                        kp_data = keypoints_dict.get(name, {'x': 0, 'y': 0, 'confidence': 0})
                        x, y, c = kp_data.get('x', 0), kp_data.get('y', 0), kp_data.get('confidence', 0)
                        frame_joints.append([x, y, c])
                    frames_data.append(frame_joints)
                    if np.any(np.array(frame_joints)[:,:2] != 0):
                        valid_frame_found = True
                
                if frames_data and valid_frame_found:
                     data_array = np.array(frames_data, dtype=np.float32)
                     if data_array.shape[1:] == (NUM_JOINTS, NUM_CHANNELS):
                         data_list.append(data_array)
                         successfully_loaded_indices.append(idx)
            except FileNotFoundError: pass
            except json.JSONDecodeError: print(f"Warning: Invalid JSON: {path}")
            except Exception as e: print(f"Error loading {path}: {type(e).__name__} - {e}")
        return data_list, successfully_loaded_indices
    
    def _smooth_and_interpolate(self, sample: np.ndarray,
                                 confidence_threshold: float = 0.3,
                                 window_length: int = 5, polyorder: int = 2):
        num_frames_in = sample.shape[0]
        if num_frames_in == 0: return sample
        num_joints = sample.shape[1]
        processed_sample = sample.copy()
        coords = processed_sample[:, :, :2].copy()
        confidences = processed_sample[:, :, 2]
        coords[confidences < confidence_threshold] = np.nan
        for j in range(num_joints):
            s_x = pd.Series(coords[:, j, 0])
            s_y = pd.Series(coords[:, j, 1])
            s_x_filled = s_x.interpolate(method='linear', limit_direction='both', limit_area='inside').ffill().bfill()
            s_y_filled = s_y.interpolate(method='linear', limit_direction='both', limit_area='inside').ffill().bfill()
            processed_sample[:, j, 0] = s_x_filled.values
            processed_sample[:, j, 1] = s_y_filled.values
        processed_sample = np.nan_to_num(processed_sample)
        safe_window_length = min(window_length, num_frames_in);
        if safe_window_length % 2 == 0: safe_window_length -= 1
        if safe_window_length < 3: return processed_sample
        safe_polyorder = min(polyorder, safe_window_length - 1)
        if safe_polyorder < 1: safe_polyorder = 1
        if num_frames_in >= safe_window_length:
            try:
                for j in range(num_joints):
                    processed_sample[:, j, 0] = savgol_filter(processed_sample[:, j, 0], safe_window_length, safe_polyorder)
                    processed_sample[:, j, 1] = savgol_filter(processed_sample[:, j, 1], safe_window_length, safe_polyorder)
            except ValueError: pass
        return processed_sample

    def _normalize_and_scale(self, sample):
        """
        [수정] (Median IQR 스케일링)
        시퀀스 전체(비디오 원본)에서 유효한 '모든 관절의 퍼짐 정도(IQR)'의 "중간값"을 찾아 
        단 하나의 스케일 값으로 시퀀스 전체를 정규화합니다.
        """
        processed_sample = sample.copy()
        all_frame_scales = []

        # 1. 시퀀스 전체를 스캔하여 유효한 스케일(퍼짐 정도) 값 수집
        for i in range(processed_sample.shape[0]):
            frame_coords_xy = processed_sample[i, :, :2]
            valid_coords = frame_coords_xy[np.any(frame_coords_xy != 0, axis=1)]
            
            if valid_coords.shape[0] < 2: 
                continue

            x_q1, x_q3 = np.percentile(valid_coords[:, 0], [25, 75])
            y_q1, y_q3 = np.percentile(valid_coords[:, 1], [25, 75])
            frame_scale = (x_q3 - x_q1) + (y_q3 - y_q1)
            
            if frame_scale > 1e-6: 
                all_frame_scales.append(frame_scale)

        # 2. 시퀀스의 대표 스케일 값(중간값) 결정
        if all_frame_scales:
            median_scale = np.median(all_frame_scales)
        else:
            median_scale = 1.0 
            
        # 3. 시퀀스 전체를 '단 하나의' 대표 스케일 값으로 정규화
        for i in range(processed_sample.shape[0]):
            frame = processed_sample[i]
            frame_coords_xy = frame[:, :2]
            
            valid_coords = frame_coords_xy[np.any(frame_coords_xy != 0, axis=1)]
            if valid_coords.shape[0] > 0:
                center = np.median(valid_coords, axis=0)
            else:
                center = np.array([0, 0]) 
            
            processed_sample[i, :, :2] = processed_sample[i, :, :2] - center
            
            if median_scale > 1e-6:
                processed_sample[i, :, :2] = processed_sample[i, :, :2] / median_scale
        
        return processed_sample

    def _augment(self, sample):
        processed_sample = sample.copy()
        augment_prob = 0.5  # [수정] 0.8 -> 0.5 (각 증강 50% 확률로 낮춤)

        if random.random() < augment_prob:
            shear_factor = random.uniform(-0.3, 0.3)
            M = np.array([[1, shear_factor], [0, 1]], dtype=np.float32)
            processed_sample[:, :, :2] = processed_sample[:, :, :2] @ M.T
        if random.random() < augment_prob:
            angle = random.uniform(-10, 10)
            rad_angle = np.deg2rad(angle)
            c, s = np.cos(rad_angle), np.sin(rad_angle)
            M = np.array([[c, -s], [s, c]], dtype=np.float32)
            processed_sample[:, :, :2] = processed_sample[:, :, :2] @ M.T
        if random.random() < augment_prob:
            processed_sample[:, :, 0] = -processed_sample[:, :, 0]
            for left_idx, right_idx in self.flip_pairs:
                if 0 <= left_idx < processed_sample.shape[1] and 0 <= right_idx < processed_sample.shape[1]:
                    temp = processed_sample[:, left_idx, :].copy()
                    processed_sample[:, left_idx, :] = processed_sample[:, right_idx, :]
                    processed_sample[:, right_idx, :] = temp
        return processed_sample

    def _pad_zero(self, sample, target_len):
        num_frames = sample.shape[0]
        num_joints = 20; num_channels = 3
        if num_frames == 0:
             return np.zeros((target_len, num_joints, num_channels), dtype=np.float32)
        if sample.shape[1:] != (num_joints, num_channels):
             return np.zeros((target_len, num_joints, num_channels), dtype=np.float32)
        padded_sample = np.zeros((target_len, num_joints, num_channels), dtype=np.float32)
        copy_len = min(num_frames, target_len)
        padded_sample[:copy_len] = sample[:copy_len]
        return padded_sample

    def _pad_loop(self, sample, target_len):
        num_frames = sample.shape[0]
        num_joints = 20; num_channels = 3
        if num_frames == 0:
             return np.zeros((target_len, num_joints, num_channels), dtype=np.float32)
        if sample.shape[1:] != (num_joints, num_channels):
             return np.zeros((target_len, num_joints, num_channels), dtype=np.float32)
        num_repeats = math.ceil(target_len / num_frames)
        looped_data = np.tile(sample, (num_repeats, 1, 1))
        padded_sample = looped_data[:target_len]
        return padded_sample

