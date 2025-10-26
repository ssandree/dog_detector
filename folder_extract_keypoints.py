#!/usr/bin/env python3
"""
강아지 관절 데이터 추출기 (폴더별 통합 JSON)
- 각 비디오 폴더의 모든 이미지 → 하나의 JSON 파일
- 강아지_id{프레임{x,y,confidence}} 구조로 바로 저장
- 멀티프로세싱으로 속도 개선
"""

import os
import sys
import cv2
import numpy as np
from pathlib import Path
import json
from datetime import datetime
from typing import List, Dict, Tuple, Optional
import multiprocessing as mp
from concurrent.futures import ProcessPoolExecutor, as_completed
import logging
from tqdm import tqdm
import re

# AI 코어 모듈 import (ai_core_module.py가 같은 폴더에 있다고 가정)
sys.path.append(str(Path(__file__).parent))
from ai_core_module import DogDetectionCore 
# 위 라인은 실제 환경에 맞게 주석 해제 또는 수정해주세요.
# 여기서는 임시 클래스로 대체합니다.


# 로깅 설정 (출력 최소화)
logging.basicConfig(level=logging.WARNING)

class DogFolderExtractor:
    """폴더별 강아지 관절 추출기"""
    
    def __init__(self, max_workers=None):
        """초기화"""
        print("🚀 폴더별 강아지 관절 추출기 초기화")
        self.max_workers = max_workers if max_workers is not None else (os.cpu_count() or 1)
        print(f"🔧 멀티프로세싱: {self.max_workers}개 워커")
        self.input_path = Path(r"D:\반려동물 구분을 위한 동물 영상")
        self.output_path = Path("pose_data") # 저장 폴더명 변경
        self.output_path.mkdir(exist_ok=True)
        self.image_extensions = {'.jpg', '.jpeg', '.png', '.bmp'}
        print(f"📁 입력: {self.input_path}")
        print(f"📁 출력: {self.output_path}")
    
    def scan_video_folders(self) -> List[Tuple[Path, Path]]:
        """비디오 폴더들 스캔"""
        print("🔍 비디오 폴더 스캔 중...")
        video_folders = []
        for dataset_type in ["Training", "Validation"]:
            base_path = self.input_path / dataset_type / "DOG" / "raw"
            if not base_path.exists():
                print(f"❌ 경로 없음: {base_path}")
                continue
            print(f"📂 스캔 중: {base_path}")
            for category_folder in base_path.iterdir():
                if category_folder.is_dir() and category_folder.name.startswith("[원천]"):
                    category_name = category_folder.name[4:]
                    inner_folder = category_folder / category_name
                    if inner_folder.exists() and inner_folder.is_dir():
                        for video_folder in inner_folder.iterdir():
                            if video_folder.is_dir():
                                has_images = any(f.suffix.lower() in self.image_extensions for f in video_folder.iterdir())
                                if has_images:
                                    # 저장 경로를 데이터셋 타입별 하위 폴더로 분리
                                    dataset_output_dir = self.output_path / dataset_type
                                    dataset_output_dir.mkdir(parents=True, exist_ok=True)
                                    output_file = dataset_output_dir / f"{video_folder.name}.json"
                                    if not output_file.exists():
                                        video_folders.append((video_folder, output_file))
        print(f"📹 처리할 비디오 폴더: {len(video_folders)}개")
        return video_folders
    
    def extract_frame_number(self, filename: str) -> int:
        """파일명에서 프레임 번호 추출"""
        match = re.search(r'frame[_-]?(\d+)', filename.lower())
        if match: return int(match.group(1))
        numbers = re.findall(r'\d+', filename)
        if numbers: return int(numbers[-1])
        return 0

ALL_KEYPOINT_NAMES = [
    "left_f_wrist", "left_f_ankle", "left_f_shoulder",
    "left_b_wrist", "left_b_ankle", "left_b_shoulder", 
    "right_f_wrist", "right_f_ankle", "right_f_shoulder",
    "right_b_wrist", "right_b_ankle", "right_b_shoulder",
    "tail_s", "tail_e", "left_mid_ear", "right_mid_ear",
    "nose", "mouth", "left_edge_ear", "right_edge_ear"
]
# ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

def process_video_folder(folder_info: Tuple[Path, Path]) -> Dict:
    """비디오 폴더 처리 (멀티프로세싱용)"""
    video_folder, output_file = folder_info
    
    try:
        model_path = "DogPose_Official/yolo11n_dog24_v242/weights/best.pt"
        detector = DogDetectionCore(model_path)
        
        dog_id = video_folder.name
        
        image_files = []
        for file_path in video_folder.iterdir():
            if file_path.suffix.lower() in {'.jpg', '.jpeg', '.png', '.bmp'}:
                match = re.search(r'(\d+)', file_path.stem)
                frame_num = int(match.group(1)) if match else 0
                image_files.append((frame_num, file_path))
        
        image_files.sort(key=lambda x: x[0])
        
        if not image_files:
            return {"success": False, "error": "이미지 파일 없음", "folder": video_folder.name}
        
        simplified_frames = {}
        processed_count = 0
        detected_count = 0
        
        for frame_num, image_path in image_files:
            try:
                image = cv2.imread(str(image_path))
                if image is None:
                    continue
                
                detection_result = detector.detect_dog_in_frame(image)
                
                if detection_result['detected'] and detection_result.get('keypoints'):
                    
                    # ▼▼▼▼▼ 2. [신규] 누락된 관절을 0으로 채우는 로직 ▼▼▼▼▼
                    detected_keypoints = detection_result['keypoints']
                    full_keypoints = {}
                    
                    for keypoint_name in ALL_KEYPOINT_NAMES:
                        if keypoint_name in detected_keypoints:
                            # 탐지된 관절은 그대로 사용
                            full_keypoints[keypoint_name] = detected_keypoints[keypoint_name]
                        else:
                            # 탐지되지 않은 관절은 0으로 채움
                            full_keypoints[keypoint_name] = {
                                "x": 0,
                                "y": 0,
                                "confidence": 0.0
                            }
                    # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
                    
                    frame_key = f"frame_{frame_num}"
                    simplified_frames[frame_key] = full_keypoints # 보정된 데이터로 저장
                    detected_count += 1
                
                processed_count += 1
                
            except Exception:
                continue
        
        final_result = {dog_id: simplified_frames}
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(final_result, f, indent=2, ensure_ascii=False)
        
        return {
            "success": True,
            "folder": video_folder.name,
            "processed": processed_count,
            "detected": detected_count
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "folder": video_folder.name
        }

def main():
    """메인 실행"""
    print("=" * 60)
    print("🎬 폴더별 강아지 관절 추출기 (간소화 버전)")
    print("=" * 60)
    
    extractor = DogFolderExtractor()
    video_folders = extractor.scan_video_folders()
    
    if not video_folders:
        print("❌ 처리할 비디오 폴더가 없습니다.")
        return
    
    print(f"🚀 {len(video_folders)}개 폴더 처리 시작")
    
    successful, failed, total_processed, total_detected = 0, 0, 0, 0
    
    with ProcessPoolExecutor(max_workers=extractor.max_workers) as executor:
        with tqdm(total=len(video_folders), desc="폴더 처리", unit="개") as pbar:
            futures = {executor.submit(process_video_folder, folder_info): folder_info for folder_info in video_folders}
            for future in as_completed(futures):
                result = future.result()
                if result["success"]:
                    successful += 1
                    total_processed += result.get("processed", 0)
                    total_detected += result.get("detected", 0)
                else:
                    failed += 1
                pbar.update(1)
                pbar.set_postfix({"성공": successful, "실패": failed, "감지": total_detected})
    
    print("\n" + "=" * 60)
    print("🎉 처리 완료!")
    print(f"📊 총 폴더: {len(video_folders)}개")
    print(f"✅ 성공: {successful}개")
    print(f"❌ 실패: {failed}개")
    print(f"🖼️  총 처리 이미지: {total_processed}개")
    print(f"🐕 강아지 감지: {total_detected}개")
    print(f"📈 감지율: {total_detected/total_processed*100:.1f}%" if total_processed > 0 else "0%")
    print(f"📁 결과 저장: {extractor.output_path}")
    
    summary = {
        "processing_date": datetime.now().isoformat(),
        "total_folders": len(video_folders),
        "successful_folders": successful,
        "failed_folders": failed,
        "total_processed_images": total_processed,
        "total_detected_images": total_detected,
        "overall_detection_rate": f"{total_detected/total_processed*100:.1f}%" if total_processed > 0 else "0%",
        "multiprocessing_workers": extractor.max_workers
    }
    summary_file = extractor.output_path / "summary_extraction.json"
    with open(summary_file, 'w', encoding='utf-8') as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)
    
    print(f"📋 요약 파일: {summary_file}")

if __name__ == "__main__":
    mp.freeze_support()
    main()