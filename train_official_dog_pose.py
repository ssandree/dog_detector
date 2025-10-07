#!/usr/bin/env python3
"""
Ultralytics 공식 Dog-Pose 데이터셋 다운로드 및 파인튜닝
24개 키포인트로 정확한 강아지 관절 추출
"""

from ultralytics import YOLO
import cv2
import numpy as np
import os
from pathlib import Path

def download_and_train_official_dog_pose():
    """공식 Dog-Pose 데이터셋 다운로드 및 파인튜닝"""
    print("🎯 Ultralytics 공식 Dog-Pose 데이터셋 파인튜닝")
    print("📊 6,773개 학습 + 1,703개 테스트 이미지")
    print("🔧 24개 키포인트 (x, y, visibility)")
    print("=" * 70)
    
    try:
        # YOLO11n-pose 모델 로드
        print("📥 YOLO11n-pose 모델 로드 중...")
        model = YOLO("yolo11n-pose.pt")
        print("✅ 모델 로드 완료")
        
        # GPU 정보 확인
        import torch
        if torch.cuda.is_available():
            gpu_name = torch.cuda.get_device_name(0)
            gpu_memory = torch.cuda.get_device_properties(0).total_memory / 1024**3
            print(f"🎮 GPU: {gpu_name} ({gpu_memory:.1f}GB)")
        else:
            print("⚠️ GPU를 사용할 수 없습니다. CPU로 학습합니다.")
        
        print(f"\n🏋️ Dog-pose 데이터셋으로 파인튜닝 시작...")
        print("📦 첫 실행 시 데이터셋 자동 다운로드 (337MB)")
        print("⏰ 예상 시간: RTX 5080 기준 약 10-15분")
        
        # 파인튜닝 실행
        results = model.train(
            data="dog-pose.yaml",           # 공식 Dog-Pose 데이터셋
            epochs=100,                     # 에폭 수 (정확한 매핑을 위한 충분한 학습)
            imgsz=640,                      # 이미지 크기
            batch=16,                       # RTX 5080에 최적화된 배치 크기
            device=0,                       # GPU 사용 (CUDA 경고 무시)
            project="DogPose_Official",     # 프로젝트 폴더
            name="yolo11n_dog24",           # 실험 이름
            patience=100,                     # 조기 종료
            save=True,                      # 모델 저장
            cache=True,                     # 캐시 사용으로 속도 향상
            workers=4,                      # 데이터 로더 워커
            verbose=True                    # 상세 출력
        )
        
        print("✅ 파인튜닝 완료!")
        
        # 학습된 모델 경로
        best_model_path = "DogPose_Official/yolo11n_dog24/weights/best.pt"
        last_model_path = "DogPose_Official/yolo11n_dog24/weights/last.pt"
        
        if os.path.exists(best_model_path):
            print(f"🏆 최고 모델: {best_model_path}")
            print(f"📄 최종 모델: {last_model_path}")
            return best_model_path
        else:
            print("❌ 학습된 모델을 찾을 수 없습니다")
            return None
            
    except Exception as e:
        print(f"❌ 파인튜닝 실패: {e}")
        import traceback
        traceback.print_exc()
        return None

def test_trained_dog_pose_model(model_path):
    """파인튜닝된 모델로 강아지 관절 검출"""
    print(f"\n🎯 파인튜닝된 모델로 강아지 관절 검출")
    print("=" * 50)
    
    if not model_path or not os.path.exists(model_path):
        print("❌ 모델을 찾을 수 없습니다")
        return
    
    try:
        # 파인튜닝된 모델 로드
        model = YOLO(model_path)
        print(f"✅ 모델 로드: {model_path}")
        
        # 테스트 이미지들
        test_images = [
            "temp_dog_images/dog_test_image.jpg"
        ]
        
        for image_path in test_images:
            if os.path.exists(image_path):
                print(f"\n🔍 분석: {image_path}")
                
                # 예측 실행 (신뢰도 낮춤)
                results = model(image_path, conf=0.3, verbose=False)
                
                if results and len(results) > 0:
                    analyze_24_keypoints(results[0], image_path, model)
                else:
                    print("❌ 검출 결과 없음")
            else:
                print(f"⚠️ 이미지를 찾을 수 없습니다: {image_path}")
                
    except Exception as e:
        print(f"❌ 검출 실패: {e}")
        import traceback
        traceback.print_exc()

def analyze_24_keypoints(result, image_path, model):
    """24개 키포인트 분석 및 시각화"""
    print(f"🎯 Dog-Pose 24개 키포인트 분석")
    print("-" * 40)
    
    # 이미지 로드
    image = cv2.imread(image_path)
    h, w = image.shape[:2]
    print(f"📐 이미지 크기: {w}x{h}")
    
    # 검출된 객체 처리
    detected_dogs = 0
    if result.boxes is not None and len(result.boxes) > 0:
        for i, box in enumerate(result.boxes):
            conf = float(box.conf[0])
            cls = int(box.cls[0])
            
            print(f"\n🐕 검출 #{i+1}: {model.names[cls]} (신뢰도: {conf:.3f})")
            detected_dogs += 1
            
            # 바운딩 박스
            x1, y1, x2, y2 = map(int, box.xyxy[0])
            cv2.rectangle(image, (x1, y1), (x2, y2), (0, 255, 0), 3)
            cv2.putText(image, f'Dog {conf:.2f}', 
                       (x1, y1-10), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)
    
    # 키포인트 처리
    if result.keypoints is not None and len(result.keypoints) > 0:
        keypoints = result.keypoints.data[0]
        
        # Dog-Pose 데이터셋의 24개 키포인트 정의 (실제 분석 결과)
        keypoint_names = [
            "L_Front_Ankle",  # 0. 왼쪽 앞발목
            "R_Front_Ankle",  # 1. 오른쪽 앞발목 ⭐
            "L_Back_Ankle",   # 2. 왼쪽 뒷발목
            "R_Back_Ankle",   # 3. 오른쪽 뒷발목
            "L_Front_Knee",   # 4. 왼쪽 앞무릎
            "R_Front_Knee",   # 5. 오른쪽 앞무릎
            "L_Back_Knee",    # 6. 왼쪽 뒷무릎
            "R_Back_Knee",    # 7. 오른쪽 뒷무릎
            "L_Shoulder",     # 8. 왼쪽 어깨
            "R_Shoulder",     # 9. 오른쪽 어깨
            "L_Hip",          # 10. 왼쪽 엉덩이
            "R_Hip",          # 11. 오른쪽 엉덩이
            "Neck",           # 12. 목
            "Spine_Mid",      # 13. 척추 중간
            "Tail_Base",      # 14. 꼬리 시작
            "Tail_Mid",       # 15. 꼬리 중간
            "Nose",           # 16. 코
            "L_Eye",          # 17. 왼쪽 눈
            "R_Eye",          # 18. 오른쪽 눈
            "L_Ear_Base",     # 19. 왼쪽 귀 기준점
            "R_Ear_Base",     # 20. 오른쪽 귀 기준점
            "L_Ear_Tip",      # 21. 왼쪽 귀 끝
            "R_Ear_Tip",      # 22. 오른쪽 귀 끝
            "Tail_End"        # 23. 꼬리 끝
        ]
        
        visible_count = 0
        high_conf_count = 0
        
        print(f"\n📍 24개 키포인트 검출 결과:")
        
        # 키포인트 그룹별 색상
        keypoint_colors = {
            'head': (255, 100, 100),      # 머리 - 연한 빨강
            'neck': (100, 255, 100),      # 목 - 연한 초록
            'front': (100, 100, 255),     # 앞다리 - 연한 파랑
            'body': (255, 255, 100),      # 몸통 - 노랑
            'back': (255, 100, 255),      # 뒷다리 - 자홍
            'tail': (100, 255, 255)       # 꼬리 - 시안
        }
        
        # 키포인트 그룹 분류
        def get_keypoint_color(idx):
            if idx < 5:       return keypoint_colors['head']    # 0-4: 머리
            elif idx < 6:     return keypoint_colors['neck']    # 5: 목
            elif idx < 12:    return keypoint_colors['front']   # 6-11: 앞다리
            elif idx < 15:    return keypoint_colors['body']    # 12-14: 몸통
            elif idx < 19:    return keypoint_colors['back']    # 15-18: 뒷다리
            elif idx < 22:    return keypoint_colors['tail']    # 19-21: 꼬리
            else:             return keypoint_colors['head']    # 22-23: 귀 끝
        
        for j, (x, y, visibility) in enumerate(keypoints):
            x, y, visibility = float(x), float(y), float(visibility)
            
            if j < len(keypoint_names):
                name = keypoint_names[j]
            else:
                name = f"Keypoint_{j+1}"
            
            if visibility > 0.3 and x > 0 and y > 0:  # 낮은 임계값
                visible_count += 1
                
                if visibility > 0.7:
                    high_conf_count += 1
                    mark = "🎯"
                elif visibility > 0.5:
                    mark = "👍"
                else:
                    mark = "📍"
                
                print(f"   {mark} {j+1:2d}. {name:15s}: ({x:6.1f}, {y:6.1f}) 신뢰도: {visibility:.3f}")
                
                # 키포인트 그리기
                center = (int(x), int(y))
                color = get_keypoint_color(j)
                
                # 신뢰도에 따른 크기
                radius = max(4, int(visibility * 10))
                cv2.circle(image, center, radius, color, -1)
                cv2.circle(image, center, radius + 2, (255, 255, 255), 2)
                
                # 번호 표시
                cv2.putText(image, str(j+1), (int(x)+10, int(y)-10), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
                cv2.putText(image, str(j+1), (int(x)+10, int(y)-10), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 0), 1)
        
        total_keypoints = 24
        detection_rate = (visible_count / total_keypoints) * 100
        
        print(f"\n✅ 최종 검출 결과:")
        print(f"   검출된 강아지: {detected_dogs}마리")
        print(f"   검출 키포인트: {visible_count}/{total_keypoints}개 ({detection_rate:.1f}%)")
        print(f"   고신뢰도: {high_conf_count}개 (신뢰도 0.7 이상)")
        
        # 관절별 검출 통계
        head_points = sum(1 for i in range(5) if len(keypoints) > i and keypoints[i][2] > 0.3)
        front_points = sum(1 for i in range(6, 12) if len(keypoints) > i and keypoints[i][2] > 0.3)
        back_points = sum(1 for i in range(15, 19) if len(keypoints) > i and keypoints[i][2] > 0.3)
        tail_points = sum(1 for i in range(19, 22) if len(keypoints) > i and keypoints[i][2] > 0.3)
        
        print(f"\n📊 부위별 검출:")
        print(f"   머리: {head_points}/5개")
        print(f"   앞다리: {front_points}/6개")
        print(f"   뒷다리: {back_points}/4개")
        print(f"   꼬리: {tail_points}/3개")
        
        # 결과 저장
        output_path = f"temp_dog_images/official_dog_pose_24keypoints.jpg"
        cv2.imwrite(output_path, image)
        print(f"\n💾 결과 저장: {output_path}")
        
        return output_path
    else:
        print("❌ 키포인트가 검출되지 않았습니다")
        return None

def main():
    """메인 함수"""
    print("🎯 Ultralytics 공식 Dog-Pose 데이터셋 파인튜닝")
    print("📖 공식 문서: https://docs.ultralytics.com/ko/datasets/pose/dog-pose/")
    print("🎮 RTX 5080 GPU 가속 사용")
    print("=" * 70)
    
    # 1. 파인튜닝 실행
    model_path = download_and_train_official_dog_pose()
    
    if model_path:
        # 2. 파인튜닝된 모델로 테스트
        test_trained_dog_pose_model(model_path)
        print(f"\n✅ 강아지 24개 키포인트 추출 완료!")
        print(f"🏆 모델: {model_path}")
    else:
        print("❌ 파인튜닝 실패")

if __name__ == "__main__":
    main()