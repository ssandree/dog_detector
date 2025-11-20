#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import pandas as pd
import numpy as np
from pathlib import Path
import time
from datetime import datetime
import tempfile
import shutil
from sklearn.metrics import confusion_matrix, classification_report, f1_score, precision_score, recall_score
import matplotlib.pyplot as plt
import seaborn as sns

# API 서비스 모듈 import 
sys.path.append(str(Path(__file__).parent / "API"))
from API.ai_service import get_ai_service

class EmotionEvaluator:
    def __init__(self):
        print("🔧 AI 서비스 초기화 중...")
        # API에서 사용하는 것과 동일한 방식으로 AI 서비스 가져오기
        self.ai_service = get_ai_service()
        print("✅ AI 서비스 준비 완료")
        
        # 감정 레이블 매핑 (폴더명 -> 예상되는 API 응답)
        self.emotion_mapping = {
            "편안_안정": "편안/안정",
            "불안_슬픔": "불안/슬픔", 
            "공격성": "공격성",
            "공포": "공포"
        }
    
    def find_test_videos(self, test_data_dir="test_data"):
        """test_data 폴더에서 평가용 비디오 파일들 찾기"""
        test_path = Path(test_data_dir)
        video_info = []
        
        if not test_path.exists():
            print(f"❌ 테스트 데이터 폴더를 찾을 수 없습니다: {test_data_dir}")
            return []
        
        print(f"📁 테스트 폴더 스캔 중: {test_data_dir}")
        
        for emotion_folder in test_path.iterdir():
            if emotion_folder.is_dir():
                emotion_name = emotion_folder.name
                print(f"   📂 감정 폴더: {emotion_name}")
                
                video_files = list(emotion_folder.glob("*.mp4"))
                print(f"      🎬 발견된 MP4 파일: {len(video_files)}개")
                
                for video_file in video_files:
                    video_info.append({
                        'path': str(video_file),
                        'emotion_folder': emotion_name,
                        'filename': video_file.name,
                        'is_noise': self.is_noise_video(video_file)
                    })
        
        return video_info
    
    def is_noise_video(self, video_path):
        """파일명에 noise가 들어있는지 확인 (음성 제외 처리용)"""
        filename = Path(video_path).name.lower()
        return 'noise' in filename
    
    async def analyze_single_video(self, video_path, true_emotion_folder):
        """
        API 서버의 analyze_video_from_url과 동일한 로직
        단, 클라우드 다운로드 대신 test_data 폴더에서 직접 로드
        """
        try:
            print(f"🎬 분석 중: {Path(video_path).name}")
            
            # 한글 경로 문제 해결을 위해 임시 파일로 복사 (API 서버와 동일한 방식)
            with tempfile.NamedTemporaryFile(delete=False, suffix='.mp4') as temp_file:
                temp_path = temp_file.name
                
                # 원본 파일을 임시 파일로 복사 (클라우드 다운로드 대신)
                shutil.copy2(video_path, temp_path)
                
                file_size = os.path.getsize(temp_path)
                print(f"   📁 파일 복사 완료: {file_size/1024/1024:.1f}MB")
            
            # API 서버와 동일: MP4 완전 분석 실행 (음성 분리 + 포즈 + 감정)
            print("   🔍 MP4 완전 분석 시작...")
            start_time = time.time()
            
            analysis_result = await self.ai_service.process_mp4_complete(temp_path)
            
            processing_time = time.time() - start_time
            
            # 임시 파일 삭제 (API 서버와 동일)
            try:
                os.unlink(temp_path)
            except:
                pass
            
            # 결과 처리
            if "error" in analysis_result:
                print(f"   ❌ 분석 실패: {analysis_result['error']}")
                return self._create_error_result(video_path, true_emotion_folder, analysis_result['error'], processing_time)
            
            # API 응답에서 결과 추출
            emotion_analysis = analysis_result["analysis"]["emotion_analysis"]
            patella_analysis = analysis_result["analysis"]["patella_analysis"]
            
            predicted_emotion = emotion_analysis["primary_emotion"]
            confidence = emotion_analysis.get("confidence", 0.0)
            analysis_mode = emotion_analysis.get("analysis_mode", "unknown")
            audio_available = emotion_analysis.get("audio_available", False)
            emotion_probabilities = emotion_analysis.get("emotion_probabilities", {})
            
            # 음성 모델의 arousal/valence 분포 추출
            arousal_distribution = emotion_analysis.get("arousal_distribution", {})
            valence_distribution = emotion_analysis.get("valence_distribution", {})
            arousal_pred = emotion_analysis.get("arousal", None)
            valence_pred = emotion_analysis.get("valence", None)
            
            # 정답 여부 확인
            is_correct = self._check_prediction_accuracy(true_emotion_folder, predicted_emotion)
            
            print(f"   ✅ 예측: {predicted_emotion} (신뢰도: {confidence:.2f}, 모드: {analysis_mode})")
            if arousal_pred and valence_pred:
                print(f"   🎵 음성: Arousal={arousal_pred}, Valence={valence_pred}")
            if not audio_available and not self.is_noise_video(video_path):
                print(f"   ⚠️  음성 없음 감지됨 (noise 파일 아님)")
            
            return {
                'video_path': str(video_path),
                'filename': Path(video_path).name,
                'true_emotion_folder': true_emotion_folder,
                'expected_emotion': self.emotion_mapping.get(true_emotion_folder, "unknown"),
                'predicted_emotion': predicted_emotion,
                'is_correct': is_correct,
                'is_noise_video': self.is_noise_video(video_path),
                'confidence': confidence,
                'processing_time': processing_time,
                'analysis_mode': analysis_mode,
                'audio_available': audio_available,
                'patella_status': patella_analysis.get("status", "unknown"),
                'emotion_probabilities': emotion_probabilities,
                'arousal': arousal_pred,
                'valence': valence_pred,
                'arousal_distribution': arousal_distribution,
                'valence_distribution': valence_distribution,
                'status': 'success'
            }
            
        except Exception as e:
            print(f"   💥 예외 발생: {str(e)}")
            return self._create_error_result(video_path, true_emotion_folder, str(e), 0.0)
    
    def _check_prediction_accuracy(self, true_emotion_folder, predicted_emotion):
        """정답 여부 확인"""
        if true_emotion_folder not in self.emotion_mapping:
            return False
        expected_emotion = self.emotion_mapping[true_emotion_folder]
        return predicted_emotion == expected_emotion
    
    def _create_error_result(self, video_path, true_emotion_folder, error_msg, processing_time):
        """에러 결과 생성"""
        return {
            'video_path': str(video_path),
            'filename': Path(video_path).name,
            'true_emotion_folder': true_emotion_folder,
            'expected_emotion': self.emotion_mapping.get(true_emotion_folder, "unknown"),
            'predicted_emotion': 'ERROR',
            'is_correct': False,
            'is_noise_video': self.is_noise_video(video_path),
            'confidence': 0.0,
            'processing_time': processing_time,
            'analysis_mode': 'error',
            'audio_available': False,
            'patella_status': 'error',
            'emotion_probabilities': {},
            'status': 'error',
            'error_message': error_msg
        }
    
    async def run_evaluation(self, max_videos_per_emotion=None):
        """전체 평가 실행"""
        print("=" * 70)
        print("🚀 감정 인식 정확도 평가 시작 (API 서버 방식)")
        print("=" * 70)
        
        all_videos = self.find_test_videos()
        
        if not all_videos:
            print("❌ 평가할 비디오가 없습니다.")
            return
        
        print(f"\n📊 총 {len(all_videos)}개의 비디오 발견")
        
        # 감정별 비디오 수 제한
        if max_videos_per_emotion:
            filtered_videos = []
            emotion_counts = {}
            
            for video in all_videos:
                emotion = video['emotion_folder']
                if emotion not in emotion_counts:
                    emotion_counts[emotion] = 0
                
                if emotion_counts[emotion] < max_videos_per_emotion:
                    filtered_videos.append(video)
                    emotion_counts[emotion] += 1
            
            all_videos = filtered_videos
            print(f"📝 감정별 {max_videos_per_emotion}개씩 제한: {len(all_videos)}개 평가 예정")
        
        # 감정별 분포 출력
        emotion_counts = {}
        for video in all_videos:
            emotion = video['emotion_folder']
            emotion_counts[emotion] = emotion_counts.get(emotion, 0) + 1
        
        print(f"\n📈 감정별 비디오 수:")
        for emotion, count in emotion_counts.items():
            print(f"   {emotion}: {count}개")
        
        results = []
        total_start_time = time.time()
        
        for i, video_info in enumerate(all_videos, 1):
            print(f"\n[{i:2d}/{len(all_videos)}]", end=" ")
            result = await self.analyze_single_video(video_info['path'], video_info['emotion_folder'])
            results.append(result)
            
            # 진행률 표시
            if i % 5 == 0 or i == len(all_videos):
                elapsed = time.time() - total_start_time
                avg_time = elapsed / i
                remaining = (len(all_videos) - i) * avg_time
                print(f"\n⏰ 진행률: {i}/{len(all_videos)} ({i/len(all_videos)*100:.1f}%) - 예상 남은 시간: {remaining/60:.1f}분")
        
        total_time = time.time() - total_start_time
        print(f"\n🏁 전체 평가 완료! 총 소요시간: {total_time/60:.1f}분")
        
        # 결과 분석 및 저장
        self.analyze_and_save_results(results)
    
    def analyze_and_save_results(self, results):
        """결과 분석 및 CSV 저장"""
        if not results:
            print("❌ 분석할 결과가 없습니다.")
            return
        
        df = pd.DataFrame(results)
        
        # 기본 통계
        total_videos = len(results)
        successful_tests = len(df[df['status'] == 'success'])
        correct_predictions = len(df[df['is_correct'] == True])
        
        accuracy = correct_predictions / successful_tests if successful_tests > 0 else 0
        
        print("\n" + "=" * 70)
        print("📊 평가 결과 분석")
        print("=" * 70)
        print(f"총 비디오 수: {total_videos}")
        print(f"성공한 분석: {successful_tests}")
        print(f"정확한 예측: {correct_predictions}")
        print(f"🎯 전체 정확도 (Accuracy): {accuracy:.2%}")
        
        # 성공한 테스트만 필터링
        success_df = df[df['status'] == 'success'].copy()
        
        if not success_df.empty:
            # sklearn metrics를 위한 데이터 준비
            y_true = success_df['expected_emotion'].tolist()
            y_pred = success_df['predicted_emotion'].tolist()
            
            # 전체 평가 지표 계산
            print(f"\n📈 전체 평가 지표:")
            try:
                # Macro average (각 클래스에 동등한 가중치)
                precision_macro = precision_score(y_true, y_pred, average='macro', zero_division=0)
                recall_macro = recall_score(y_true, y_pred, average='macro', zero_division=0)
                f1_macro = f1_score(y_true, y_pred, average='macro', zero_division=0)
                
                # Weighted average (클래스 빈도에 따른 가중치)
                precision_weighted = precision_score(y_true, y_pred, average='weighted', zero_division=0)
                recall_weighted = recall_score(y_true, y_pred, average='weighted', zero_division=0)
                f1_weighted = f1_score(y_true, y_pred, average='weighted', zero_division=0)
                
                print(f"   [Macro Average]")
                print(f"   Precision: {precision_macro:.4f}")
                print(f"   Recall:    {recall_macro:.4f}")
                print(f"   F1 Score:  {f1_macro:.4f}")
                
                print(f"\n   [Weighted Average]")
                print(f"   Precision: {precision_weighted:.4f}")
                print(f"   Recall:    {recall_weighted:.4f}")
                print(f"   F1 Score:  {f1_weighted:.4f}")
                
            except Exception as e:
                print(f"   ⚠️ 평가 지표 계산 중 오류: {e}")
            
            # 상세 Classification Report
            print(f"\n📋 클래스별 상세 평가:")
            try:
                report = classification_report(y_true, y_pred, zero_division=0, digits=4)
                print(report)
            except Exception as e:
                print(f"   ⚠️ Classification Report 생성 중 오류: {e}")
            
            # Confusion Matrix 생성 및 저장
            print(f"\n🔢 혼동 행렬 (Confusion Matrix):")
            try:
                labels = sorted(list(set(y_true + y_pred)))
                cm = confusion_matrix(y_true, y_pred, labels=labels)
                
                # 텍스트로 출력
                print(f"\n   레이블 순서: {labels}")
                print(f"   (행: 실제값, 열: 예측값)")
                print("\n   ", end="")
                for label in labels:
                    print(f"{label[:8]:>10s}", end=" ")
                print()
                
                for i, label in enumerate(labels):
                    print(f"   {label[:8]:10s}", end=" ")
                    for j in range(len(labels)):
                        print(f"{cm[i][j]:10d}", end=" ")
                    print()
                
                # 혼동 행렬 시각화
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                plt.figure(figsize=(10, 8))
                sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                           xticklabels=labels, yticklabels=labels,
                           cbar_kws={'label': '예측 개수'})
                plt.title('Confusion Matrix - 감정 분류 모델 평가', fontsize=14, pad=20)
                plt.ylabel('실제 감정 (True Label)', fontsize=12)
                plt.xlabel('예측 감정 (Predicted Label)', fontsize=12)
                plt.tight_layout()
                
                cm_filename = f"confusion_matrix_{timestamp}.png"
                plt.savefig(cm_filename, dpi=300, bbox_inches='tight')
                print(f"\n   💾 혼동 행렬 이미지 저장: {cm_filename}")
                plt.close()
                
            except Exception as e:
                print(f"   ⚠️ 혼동 행렬 생성 중 오류: {e}")
                import traceback
                traceback.print_exc()
        
        # 감정별 정확도
        print(f"\n🎭 감정별 정확도:")
        success_df = df[df['status'] == 'success']
        if not success_df.empty:
            emotion_stats = success_df.groupby('true_emotion_folder').agg({
                'is_correct': ['count', 'sum'],
                'confidence': 'mean'
            })
            emotion_stats.columns = ['total', 'correct', 'avg_confidence']
            emotion_stats['accuracy'] = emotion_stats['correct'] / emotion_stats['total']
            
            for emotion, row in emotion_stats.iterrows():
                print(f"   {emotion:10s}: {row['accuracy']:6.2%} ({row['correct']:2.0f}/{row['total']:2.0f}) - 평균신뢰도: {row['avg_confidence']:.3f}")
        
        # 노이즈 vs 일반 비디오 비교
        print(f"\n🔊 노이즈 vs 일반 비디오:")
        if not success_df.empty:
            noise_stats = success_df.groupby('is_noise_video').agg({
                'is_correct': ['count', 'sum'],
                'confidence': 'mean'
            })
            noise_stats.columns = ['total', 'correct', 'avg_confidence']
            noise_stats['accuracy'] = noise_stats['correct'] / noise_stats['total']
            
            for is_noise, row in noise_stats.iterrows():
                video_type = "노이즈 비디오" if is_noise else "일반 비디오"
                print(f"   {video_type:10s}: {row['accuracy']:6.2%} ({row['correct']:2.0f}/{row['total']:2.0f}) - 평균신뢰도: {row['avg_confidence']:.3f}")
        
        # 분석 모드별 통계
        print(f"\n🔍 분석 모드별 통계:")
        if not success_df.empty:
            mode_stats = success_df.groupby('analysis_mode').agg({
                'is_correct': ['count', 'sum'],
                'confidence': 'mean'
            })
            mode_stats.columns = ['total', 'correct', 'avg_confidence']
            mode_stats['accuracy'] = mode_stats['correct'] / mode_stats['total']
            
            for mode, row in mode_stats.iterrows():
                print(f"   {mode:12s}: {row['accuracy']:6.2%} ({row['correct']:2.0f}/{row['total']:2.0f}) - 평균신뢰도: {row['avg_confidence']:.3f}")
        
        # Arousal/Valence 분포 통계 (음성 모델 분석)
        print(f"\n🎵 음성 모델 Arousal/Valence 분석:")
        audio_available_df = success_df[success_df['audio_available'] == True]
        if not audio_available_df.empty:
            # Arousal 분포
            arousal_counts = audio_available_df['arousal'].value_counts()
            if not arousal_counts.empty:
                print(f"   [Arousal 분포] (총 {len(audio_available_df)}개)")
                for arousal, count in arousal_counts.items():
                    if arousal:
                        print(f"      {arousal:10s}: {count:3d}개 ({count/len(audio_available_df)*100:5.1f}%)")
            
            # Valence 분포
            valence_counts = audio_available_df['valence'].value_counts()
            if not valence_counts.empty:
                print(f"\n   [Valence 분포] (총 {len(audio_available_df)}개)")
                for valence, count in valence_counts.items():
                    if valence:
                        print(f"      {valence:10s}: {count:3d}개 ({count/len(audio_available_df)*100:5.1f}%)")
            
            # Arousal/Valence 조합 분석
            print(f"\n   [Arousal-Valence 조합 상위 5개]")
            av_combinations = audio_available_df[audio_available_df['arousal'].notna() & audio_available_df['valence'].notna()]
            if not av_combinations.empty:
                combo_counts = av_combinations.groupby(['arousal', 'valence']).size().sort_values(ascending=False).head(5)
                for i, (count) in enumerate(combo_counts, 1):
                    arousal = combo_counts.index[i-1][0]
                    valence = combo_counts.index[i-1][1]
                    print(f"      {i}. {arousal:8s} + {valence:10s}: {count:3d}개 ({count/len(av_combinations)*100:5.1f}%)")
        else:
            print(f"   ⚠️ 음성이 있는 비디오가 없습니다.")
        
        # 신뢰도 분포 분석
        print(f"\n📈 신뢰도 분포:")
        confidence_values = success_df['confidence']
        if not confidence_values.empty:
            print(f"   평균: {confidence_values.mean():.3f}")
            print(f"   최대: {confidence_values.max():.3f}")
            print(f"   최소: {confidence_values.min():.3f}")
            print(f"   표준편차: {confidence_values.std():.3f}")
            
            # 신뢰도 0인 비디오 수
            zero_conf_count = len(success_df[success_df['confidence'] == 0.0])
            print(f"   신뢰도 0.0인 비디오: {zero_conf_count}개 ({zero_conf_count/len(success_df)*100:.1f}%)")
        
        # 에러 분석
        error_df = df[df['status'] == 'error']
        if not error_df.empty:
            print(f"\n❌ 에러 분석:")
            print(f"   에러 발생 비디오: {len(error_df)}개")
            error_messages = error_df['error_message'].value_counts()
            for error_msg, count in error_messages.items():
                print(f"   '{error_msg}': {count}개")
        
        # CSV 파일 저장
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        csv_filename = f"emotion_evaluation_results_{timestamp}.csv"
        df.to_csv(csv_filename, index=False, encoding='utf-8-sig')
        print(f"\n💾 상세 결과 저장: {csv_filename}")
        
        return accuracy

async def main():
    try:
        # 환경 설정 (API 서버와 동일)
        os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"
        os.environ["PYTHONIOENCODING"] = "utf-8"
        os.environ["PYTHONUTF8"] = "1"
        
        # Windows 콘솔 인코딩
        import locale
        try:
            locale.setlocale(locale.LC_ALL, 'Korean_Korea.UTF-8')
        except:
            try:
                locale.setlocale(locale.LC_ALL, 'ko_KR.UTF-8')
            except:
                pass
        
        print("🌏 환경 설정 완료")
        
        evaluator = EmotionEvaluator()
        
        # 전체 평가 실행 (제한 없음 = 모든 비디오)
        await evaluator.run_evaluation(max_videos_per_emotion=None)
        
    except KeyboardInterrupt:
        print("\n\n⚠️ 사용자에 의해 평가가 중단되었습니다.")
    except Exception as e:
        print(f"\n❌ 평가 중 오류 발생: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())