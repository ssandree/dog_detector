#!/usr/bin/env python3
"""
강아지 키포인트 모델 추가 훈련 (Resume Training)
현재 모델에서 계속 훈련하여 성능 향상
"""

from ultralytics import YOLO
import torch

def resume_dog_pose_training():
    """기존 모델에서 추가 훈련"""
    print("🔄 강아지 키포인트 모델 추가 훈련")
    print("="*60)
    
    # 기존 최고 성능 모델 로드
    model = YOLO("DogPose_Official/yolo11n_dog24/weights/best.pt")
    print("✅ 기존 모델 로드 완료")
    
    # GPU 확인
    if torch.cuda.is_available():
        print(f"🎮 GPU: {torch.cuda.get_device_name(0)}")
    
    print("🏋️  추가 훈련 시작...")
    print("⚙️  설정: 낮은 학습률, 데이터 증강 강화")
    
    # 추가 훈련 실행 (안정성 개선)
    results = model.train(
        data="dog-pose.yaml",
        epochs=50,                    # 추가 50 에폭
        imgsz=640,
        batch=16,                     # 배치 크기 감소 (메모리 절약)
        device=0,
        project="DogPose_Official",
        name="yolo11n_dog24_v24",    # 새로운 버전명
        resume=False,                 # 새로운 실험으로 시작
        
        # 안정성 설정
        workers=4,                    # worker 수 감소 (Windows 안정성)
        cache=False,                  # 캐시 비활성화 (메모리 절약)
        
        # 개선된 하이퍼파라미터
        lr0=0.0001,                  # 낮은 초기 학습률 (Fine-tuning)
        lrf=0.00001,                 # 최종 학습률
        momentum=0.9,
        weight_decay=0.0005,
        
        # 강화된 데이터 증강
        degrees=15.0,                # 회전 각도 증가
        translate=0.2,               # 이동 증가  
        scale=0.9,                   # 크기 조절 증가
        shear=10.0,                  # 전단 변형
        perspective=0.0005,          # 원근 변형
        flipud=0.5,                  # 상하 뒤집기
        fliplr=0.5,                  # 좌우 뒤집기
        mosaic=1.0,                  # 모자이크 증강
        mixup=0.15,                  # Mixup 적용
        copy_paste=0.3,              # Copy-Paste 증강
        
        # 조기 종료 설정
        patience=20,
        save=True
    )
    
    print("🎉 추가 훈련 완료!")
    return results

if __name__ == "__main__":
    results = resume_dog_pose_training()
