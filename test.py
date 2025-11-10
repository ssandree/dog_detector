#!/usr/bin/env python3
"""
MP4 → 포즈 + 오디오 → 감정 탐지 전체 플로우 테스트 스크립트
성능평가 기능 포함: CSV 라벨과 비교하여 정확도 측정
SSD에 있는 MP4 파일로 ai_core_module.py 기능 테스트
"""

import os
import sys
import json
import pandas as pd
import numpy as np
from pathlib import Path
import time
from datetime import datetime
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns
from typing import Optional

# ai_core_module import
try:
    from ai_core_module import AIModelInterface, DogDetectionCore, VideoProcessor
    print("✅ ai_core_module 성공적으로 import")
except ImportError as e:
    print(f"❌ ai_core_module import 실패: {e}")
    print("   현재 디렉토리에 ai_core_module.py가 있는지 확인하세요.")
    sys.exit(1)

def find_mp4_files(directory: str) -> list:
    """지정된 디렉토리에서 MP4 파일들을 찾기"""
    mp4_files = []
    directory_path = Path(directory)
    
    if not directory_path.exists():
        print(f"❌ 디렉토리 없음: {directory}")
        return []
    
    # MP4 파일 검색
    for mp4_file in directory_path.rglob("*.mp4"):
        mp4_files.append(str(mp4_file))
    
    for mp4_file in directory_path.rglob("*.MP4"):  # 대문자도 검색
        mp4_files.append(str(mp4_file))
    
    return mp4_files

def load_emotion_labels(csv_path: str) -> dict:
    """CSV 파일에서 감정 라벨 로드"""
    try:
        df = pd.read_csv(csv_path, encoding='utf-8')
        print(f"📋 라벨 파일 로드: {csv_path}")
        print(f"   총 {len(df)}개 데이터")
        print(f"   컬럼: {list(df.columns)}")
        
        # 파일명과 감정 라벨 매핑 딕셔너리 생성
        labels_dict = {}
        
        # CSV 구조에 따라 다르게 처리
        if 'filename' in df.columns and 'emotion' in df.columns:
            for _, row in df.iterrows():
                filename = row['filename']
                emotion = row['emotion']
                labels_dict[filename] = emotion
        elif 'video_file' in df.columns and 'label' in df.columns:
            for _, row in df.iterrows():
                filename = row['video_file']
                emotion = row['label']
                labels_dict[filename] = emotion
        else:
            # 첫 번째 컬럼을 파일명, 두 번째 컬럼을 라벨로 가정
            for _, row in df.iterrows():
                filename = row.iloc[0]
                emotion = row.iloc[1]
                labels_dict[filename] = emotion
        
        print(f"   감정 라벨 종류: {set(labels_dict.values())}")
        return labels_dict
        
    except Exception as e:
        print(f"❌ 라벨 파일 로드 실패: {e}")
        return {}

def normalize_emotion_label(emotion: str) -> str:
    """감정 라벨 정규화 (다양한 표기법 통일)"""
    emotion = emotion.strip().lower()
    
    # 감정 매핑 테이블
    emotion_mapping = {
        # 편안/안정
        '편안': '편안/안정',
        '안정': '편안/안정',
        'calm': '편안/안정',
        'relaxed': '편안/안정',
        'peaceful': '편안/안정',
        
        # 불안/슬픔
        '불안': '불안/슬픔',
        '슬픔': '불안/슬픔',
        'anxiety': '불안/슬픔',
        'sad': '불안/슬픔',
        'worried': '불안/슬픔',
        
        # 공포
        '공포': '공포',
        'fear': '공포',
        'scared': '공포',
        'afraid': '공포',
        
        # 공격성
        '공격성': '공격성',
        '공격적': '공격성',
        'aggressive': '공격성',
        'angry': '공격성',
        'hostile': '공격성'
    }
    
    return emotion_mapping.get(emotion, emotion)

def test_single_mp4(mp4_path: str, ai_interface: AIModelInterface, true_label: Optional[str] = None) -> dict:
    """단일 MP4 파일 테스트 (성능평가 포함)"""
    print(f"\n🎬 테스트 시작: {Path(mp4_path).name}")
    if true_label:
        print(f"📋 정답 라벨: {true_label}")
    print("="*60)
    
    start_time = time.time()
    
    try:
        # 파일 정보 출력
        file_size = os.path.getsize(mp4_path) / (1024*1024)  # MB
        print(f"📄 파일 크기: {file_size:.1f}MB")
        
        # AI 분석 실행
        result = ai_interface.analyze_mp4_complete(mp4_path)
        
        processing_time = time.time() - start_time
        
        if "error" in result:
            print(f"❌ 분석 실패: {result['error']}")
            return {
                "filename": Path(mp4_path).name,
                "success": False,
                "error": result["error"],
                "processing_time": processing_time,
                "file_size_mb": file_size,
                "true_label": true_label,
                "predicted_label": None,
                "correct_prediction": False
            }
        
        # 결과 출력
        emotion_analysis = result["analysis"]["emotion_analysis"]
        predicted_emotion = emotion_analysis["primary_emotion"]
        confidence = emotion_analysis["confidence"]
        analysis_mode = emotion_analysis["analysis_mode"]
        
        print(f"🎯 예측 감정: {predicted_emotion}")
        print(f"🎲 신뢰도: {confidence:.3f}")
        print(f"🔧 분석 모드: {analysis_mode}")
        
        # 성능 평가
        correct_prediction = False
        if true_label:
            normalized_true = normalize_emotion_label(true_label)
            normalized_pred = normalize_emotion_label(predicted_emotion)
            correct_prediction = normalized_true == normalized_pred
            
            if correct_prediction:
                print(f"✅ 정답! (예측: {normalized_pred}, 정답: {normalized_true})")
            else:
                print(f"❌ 오답! (예측: {normalized_pred}, 정답: {normalized_true})")
        
        # 감정 확률 분포
        if "emotion_probabilities" in emotion_analysis:
            print("📊 감정 확률 분포:")
            for emotion, prob in emotion_analysis["emotion_probabilities"].items():
                print(f"   {emotion}: {prob:.3f}")
        
        print(f"⏱️ 처리 시간: {processing_time:.2f}초")
        
        return {
            "filename": Path(mp4_path).name,
            "success": True,
            "processing_time": processing_time,
            "file_size_mb": file_size,
            "predicted_emotion": predicted_emotion,
            "confidence": confidence,
            "analysis_mode": analysis_mode,
            "emotion_probabilities": emotion_analysis.get("emotion_probabilities", {}),
            "true_label": true_label,
            "predicted_label": normalize_emotion_label(predicted_emotion),
            "correct_prediction": correct_prediction,
            "full_result": result
        }
        
    except Exception as e:
        processing_time = time.time() - start_time
        print(f"💥 예외 발생: {e}")
        import traceback
        traceback.print_exc()
        
        return {
            "filename": Path(mp4_path).name,
            "success": False,
            "error": str(e),
            "processing_time": processing_time,
            "file_size_mb": file_size if 'file_size' in locals() else 0,
            "true_label": true_label,
            "predicted_label": None,
            "correct_prediction": False
        }

def evaluate_performance(test_results: list) -> dict:
    """성능평가 계산 및 시각화"""
    print("\n📊 성능 평가 분석")
    print("="*60)
    
    # 성공한 테스트만 필터링
    successful_tests = [r for r in test_results if r["success"] and r["true_label"] is not None]
    
    if not successful_tests:
        print("❌ 성능 평가할 데이터가 없습니다.")
        return {}
    
    # 정답/예측 라벨 추출
    true_labels = [r["true_label"] for r in successful_tests]
    pred_labels = [r["predicted_label"] for r in successful_tests]
    
    # 정확도 계산
    accuracy = accuracy_score(true_labels, pred_labels)
    print(f"🎯 전체 정확도: {accuracy:.3f} ({accuracy*100:.1f}%)")
    
    # 클래스별 성능 리포트
    emotion_classes = ['편안/안정', '불안/슬픔', '공포', '공격성']
    available_classes = list(set(true_labels + pred_labels))
    
    print(f"\n📋 분류 보고서:")
    try:
        class_report = classification_report(
            true_labels, pred_labels, 
            labels=available_classes,
            target_names=available_classes,
            output_dict=True
        )
        
        for emotion in available_classes:
            if emotion in class_report and isinstance(class_report[emotion], dict):
                metrics = class_report[emotion]
                precision = metrics.get('precision', 0) if isinstance(metrics, dict) else 0
                recall = metrics.get('recall', 0) if isinstance(metrics, dict) else 0
                f1_score = metrics.get('f1-score', 0) if isinstance(metrics, dict) else 0
                support = metrics.get('support', 0) if isinstance(metrics, dict) else 0
                
                print(f"   {emotion}:")
                print(f"      정밀도: {precision:.3f}")
                print(f"      재현율: {recall:.3f}")
                print(f"      F1-점수: {f1_score:.3f}")
                print(f"      지원수: {support}")
    except Exception as e:
        print(f"   ⚠️ 분류 보고서 생성 실패: {e}")
    
    # 혼동 행렬 생성 및 시각화
    try:
        cm = confusion_matrix(true_labels, pred_labels, labels=available_classes)
        
        plt.figure(figsize=(10, 8))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                   xticklabels=available_classes, 
                   yticklabels=available_classes)
        plt.title('감정 분류 혼동 행렬 (Confusion Matrix)')
        plt.xlabel('예측 라벨')
        plt.ylabel('실제 라벨')
        plt.tight_layout()
        
        # 파일로 저장
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        cm_file = f"confusion_matrix_{timestamp}.png"
        plt.savefig(cm_file, dpi=300, bbox_inches='tight')
        plt.show()
        print(f"💾 혼동 행렬 저장: {cm_file}")
        
    except Exception as e:
        print(f"⚠️ 혼동 행렬 생성 실패: {e}")
    
    # 신뢰도 분석
    confidences = [r["confidence"] for r in successful_tests if "confidence" in r]
    correct_predictions = [r["correct_prediction"] for r in successful_tests]
    
    if confidences:
        avg_confidence = np.mean(confidences)
        correct_confidence = np.mean([conf for conf, correct in zip(confidences, correct_predictions) if correct])
        wrong_confidence = np.mean([conf for conf, correct in zip(confidences, correct_predictions) if not correct])
        
        print(f"\n🎲 신뢰도 분석:")
        print(f"   평균 신뢰도: {avg_confidence:.3f}")
        print(f"   정답 평균 신뢰도: {correct_confidence:.3f}")
        if not np.isnan(wrong_confidence):
            print(f"   오답 평균 신뢰도: {wrong_confidence:.3f}")
    
    # 처리 시간 분석
    processing_times = [r["processing_time"] for r in successful_tests]
    if processing_times:
        print(f"\n⏱️ 처리 시간 분석:")
        print(f"   평균: {np.mean(processing_times):.2f}초")
        print(f"   최소: {np.min(processing_times):.2f}초")
        print(f"   최대: {np.max(processing_times):.2f}초")
    
    return {
        "accuracy": accuracy,
        "total_samples": len(successful_tests),
        "classification_report": class_report if 'class_report' in locals() else {},
        "confusion_matrix": cm.tolist() if 'cm' in locals() else [],
        "available_classes": available_classes,
        "avg_confidence": avg_confidence if 'avg_confidence' in locals() else 0,
        "avg_processing_time": np.mean(processing_times) if processing_times else 0
    }

def main():
    """메인 테스트 함수 (성능평가 포함)"""
    print("🐕 강아지 감정 분석 MP4 테스트 + 성능 평가")
    print("="*60)
    
    # CSV 라벨 파일 경로 입력
    csv_path = input("📋 감정 라벨 CSV 파일 경로를 입력하세요 (엔터: 라벨 없이 테스트): ").strip()
    emotion_labels = {}
    
    if csv_path and os.path.exists(csv_path):
        emotion_labels = load_emotion_labels(csv_path)
        print(f"✅ {len(emotion_labels)}개 라벨 로드됨")
    elif csv_path:
        print(f"❌ CSV 파일을 찾을 수 없음: {csv_path}")
        print("라벨 없이 테스트를 진행합니다.")
    else:
        print("라벨 없이 테스트를 진행합니다.")
    
    # 1. 테스트할 MP4 파일들 찾기
    test_directories = [
        ".",  # 현재 디렉토리
        "test_videos",  # test_videos 폴더 (있다면)
        "videos",       # videos 폴더 (있다면)
        # 필요하면 추가 경로 지정
    ]
    
    all_mp4_files = []
    for directory in test_directories:
        mp4_files = find_mp4_files(directory)
        all_mp4_files.extend(mp4_files)
    
    # 중복 제거
    all_mp4_files = list(set(all_mp4_files))
    
    if not all_mp4_files:
        print("❌ 테스트할 MP4 파일을 찾을 수 없습니다.")
        print("   다음 중 하나를 시도해보세요:")
        print("   1. 현재 디렉토리에 MP4 파일 복사")
        print("   2. 'test_videos' 폴더 생성 후 MP4 파일 넣기")
        print("   3. 아래 코드에서 test_directories에 MP4 파일 경로 추가")
        return
    
    print(f"📁 발견된 MP4 파일 {len(all_mp4_files)}개:")
    for i, mp4_file in enumerate(all_mp4_files, 1):
        file_size = os.path.getsize(mp4_file) / (1024*1024)
        print(f"   {i}. {Path(mp4_file).name} ({file_size:.1f}MB)")
    
    # 2. AI 인터페이스 초기화
    print(f"\n🤖 AI 인터페이스 초기화 중...")
    try:
        ai_interface = AIModelInterface()
        print("✅ AI 인터페이스 초기화 완료")
    except Exception as e:
        print(f"❌ AI 인터페이스 초기화 실패: {e}")
        print("   모델 파일들이 올바른 위치에 있는지 확인하세요.")
        return
    
    # 3. 각 MP4 파일 테스트 (라벨 매칭 포함)
    test_results = []
    total_start_time = time.time()
    
    for i, mp4_file in enumerate(all_mp4_files, 1):
        print(f"\n{'='*20} 테스트 {i}/{len(all_mp4_files)} {'='*20}")
        
        # 파일명에서 라벨 찾기
        filename = Path(mp4_file).name
        true_label = None
        
        # 다양한 파일명 형식으로 라벨 매칭 시도
        for label_key in emotion_labels.keys():
            if label_key in filename or filename in label_key:
                true_label = emotion_labels[label_key]
                break
        
        # 정확한 매칭이 안 되면 확장자 제거해서 시도
        if not true_label:
            filename_without_ext = Path(mp4_file).stem
            true_label = emotion_labels.get(filename_without_ext)
        
        result = test_single_mp4(mp4_file, ai_interface, true_label)
        test_results.append(result)
    
    # 4. 전체 결과 요약
    total_end_time = time.time()
    total_time = total_end_time - total_start_time
    
    print(f"\n🏁 전체 테스트 완료!")
    print("="*60)
    print(f"⏱️ 총 소요시간: {total_time:.2f}초")
    print(f"📊 테스트 결과 요약:")
    
    successful_tests = [r for r in test_results if r["success"]]
    failed_tests = [r for r in test_results if not r["success"]]
    
    print(f"   ✅ 성공: {len(successful_tests)}개")
    print(f"   ❌ 실패: {len(failed_tests)}개")
    
    if successful_tests:
        avg_time = sum(r["processing_time"] for r in successful_tests) / len(successful_tests)
        avg_size = sum(r["file_size_mb"] for r in successful_tests) / len(successful_tests)
        print(f"   📈 평균 처리시간: {avg_time:.2f}초")
        print(f"   📈 평균 파일크기: {avg_size:.1f}MB")
    
    # 5. 성능 평가 (라벨이 있는 경우)
    labeled_tests = [r for r in test_results if r["success"] and r.get("true_label")]
    if labeled_tests:
        print(f"\n📊 성능 평가 가능한 데이터: {len(labeled_tests)}개")
        performance_results = evaluate_performance(test_results)
    else:
        print(f"\n⚠️ 라벨이 있는 데이터가 없어 성능 평가를 건너뜁니다.")
        performance_results = {}
    
    # 6. 상세 결과 저장 (선택적)
    save_results = input("\n💾 상세 결과를 JSON 파일로 저장하시겠습니까? (y/n): ").lower().strip()
    if save_results in ['y', 'yes']:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        result_file = f"performance_test_results_{timestamp}.json"
        
        save_data = {
            "test_summary": {
                "total_files": len(all_mp4_files),
                "successful": len(successful_tests),
                "failed": len(failed_tests),
                "labeled_tests": len(labeled_tests),
                "total_time": total_time,
                "timestamp": timestamp,
                "csv_labels_file": csv_path if csv_path else None
            },
            "performance_metrics": performance_results,
            "detailed_results": test_results
        }
        
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump(save_data, f, indent=2, ensure_ascii=False, default=str)
        
        print(f"✅ 결과 저장됨: {result_file}")
        if performance_results:
            print(f"🎯 최종 정확도: {performance_results.get('accuracy', 0)*100:.1f}%")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⏹️ 사용자에 의해 중단됨")
    except Exception as e:
        print(f"\n💥 프로그램 오류: {e}")
        import traceback
        traceback.print_exc()
