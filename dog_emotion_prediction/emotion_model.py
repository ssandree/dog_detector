#!/usr/bin/env python3
"""
관절 데이터 기반 감정 탐지 모델
"""

import numpy as np
import math
from typing import Dict, List
from datetime import datetime

class EmotionDetector:
    """관절 데이터를 이용한 강아지 감정 분석"""
    
    def __init__(self):
        """초기화"""
        self.emotion_weights = {
            'tail_movement': 0.35,    # 꼬리 움직임
            'ear_position': 0.25,     # 귀 위치
            'body_posture': 0.30,     # 전체 자세
            'head_orientation': 0.10  # 머리 방향
        }
    
    def analyze_emotion(self, keypoint_data: Dict) -> Dict:
        """
        키포인트 데이터로 감정 분석
        
        Args:
            keypoint_data: 키포인트 데이터 (단일 프레임 또는 시계열)
            
        Returns:
            감정 분석 결과
        """
        if 'frames' in keypoint_data:
            # 여러 프레임 데이터인 경우
            return self._analyze_video_emotion(keypoint_data)
        else:
            # 단일 프레임 데이터인 경우
            return self._analyze_frame_emotion(keypoint_data)
    
    def _analyze_frame_emotion(self, frame_data: Dict) -> Dict:
        """단일 프레임 감정 분석"""
        keypoints = frame_data.get('keypoints', {})
        
        if not keypoints:
            return self._get_neutral_emotion()
        
        # 각 특징별 점수 계산
        tail_score = self._analyze_tail_emotion(keypoints)
        ear_score = self._analyze_ear_emotion(keypoints)
        posture_score = self._analyze_posture_emotion(keypoints)
        head_score = self._analyze_head_emotion(keypoints)
        
        # 가중 평균으로 최종 감정 점수 계산
        emotion_scores = {
            'happy': (
                tail_score['happy'] * self.emotion_weights['tail_movement'] +
                ear_score['happy'] * self.emotion_weights['ear_position'] +
                posture_score['happy'] * self.emotion_weights['body_posture'] +
                head_score['happy'] * self.emotion_weights['head_orientation']
            ),
            'alert': (
                tail_score['alert'] * self.emotion_weights['tail_movement'] +
                ear_score['alert'] * self.emotion_weights['ear_position'] +
                posture_score['alert'] * self.emotion_weights['body_posture'] +
                head_score['alert'] * self.emotion_weights['head_orientation']
            ),
            'fearful': (
                tail_score['fearful'] * self.emotion_weights['tail_movement'] +
                ear_score['fearful'] * self.emotion_weights['ear_position'] +
                posture_score['fearful'] * self.emotion_weights['body_posture'] +
                head_score['fearful'] * self.emotion_weights['head_orientation']
            ),
            'relaxed': (
                tail_score['relaxed'] * self.emotion_weights['tail_movement'] +
                ear_score['relaxed'] * self.emotion_weights['ear_position'] +
                posture_score['relaxed'] * self.emotion_weights['body_posture'] +
                head_score['relaxed'] * self.emotion_weights['head_orientation']
            )
        }
        
        # 정규화
        total_score = sum(emotion_scores.values())
        if total_score > 0:
            emotion_scores = {k: v/total_score for k, v in emotion_scores.items()}
        
        # 주요 감정 결정
        primary_emotion = max(emotion_scores, key=emotion_scores.get)
        confidence = emotion_scores[primary_emotion]
        
        return {
            'primary_emotion': primary_emotion,
            'confidence': confidence,
            'emotion_scores': emotion_scores,
            'features': {
                'tail': tail_score,
                'ear': ear_score,
                'posture': posture_score,
                'head': head_score
            },
            'timestamp': datetime.now().isoformat()
        }
    
    def _analyze_tail_emotion(self, keypoints: Dict) -> Dict:
        """꼬리 위치로 감정 분석"""
        scores = {'happy': 0, 'alert': 0, 'fearful': 0, 'relaxed': 0}
        
        tail_start = keypoints.get('tail_s')
        tail_end = keypoints.get('tail_e')
        
        if tail_start and tail_end:
            # 꼬리 각도 계산
            dx = tail_end['x'] - tail_start['x']
            dy = tail_end['y'] - tail_start['y']
            angle = math.atan2(-dy, dx) * 180 / math.pi
            
            if angle > 30:  # 꼬리가 위로
                scores['happy'] = 0.8
                scores['alert'] = 0.6
            elif angle < -30:  # 꼬리가 아래로
                scores['fearful'] = 0.9
            else:  # 수평
                scores['relaxed'] = 0.7
        
        return scores
    
    def _analyze_ear_emotion(self, keypoints: Dict) -> Dict:
        """귀 위치로 감정 분석"""
        scores = {'happy': 0, 'alert': 0, 'fearful': 0, 'relaxed': 0}
        
        left_mid = keypoints.get('left_mid_ear')
        left_edge = keypoints.get('left_edge_ear')
        
        if left_mid and left_edge:
            # 귀의 방향 분석
            if left_edge['x'] > left_mid['x']:  # 귀가 앞으로
                scores['alert'] = 0.8
                scores['happy'] = 0.5
            elif left_edge['x'] < left_mid['x']:  # 귀가 뒤로
                scores['fearful'] = 0.7
            else:
                scores['relaxed'] = 0.6
        
        return scores
    
    def _analyze_posture_emotion(self, keypoints: Dict) -> Dict:
        """전체 자세로 감정 분석"""
        scores = {'happy': 0, 'alert': 0, 'fearful': 0, 'relaxed': 0}
        
        # 어깨 높이 비교
        front_shoulders = []
        back_shoulders = []
        
        if 'left_f_shoulder' in keypoints:
            front_shoulders.append(keypoints['left_f_shoulder']['y'])
        if 'right_f_shoulder' in keypoints:
            front_shoulders.append(keypoints['right_f_shoulder']['y'])
        if 'left_b_shoulder' in keypoints:
            back_shoulders.append(keypoints['left_b_shoulder']['y'])
        if 'right_b_shoulder' in keypoints:
            back_shoulders.append(keypoints['right_b_shoulder']['y'])
        
        if front_shoulders and back_shoulders:
            avg_front = sum(front_shoulders) / len(front_shoulders)
            avg_back = sum(back_shoulders) / len(back_shoulders)
            height_diff = avg_front - avg_back
            
            if height_diff > 20:  # Play bow 자세
                scores['happy'] = 0.9
            elif height_diff < -20:  # 웅크린 자세
                scores['fearful'] = 0.7
            else:
                scores['relaxed'] = 0.6
                scores['alert'] = 0.4
        
        return scores
    
    def _analyze_head_emotion(self, keypoints: Dict) -> Dict:
        """머리 방향으로 감정 분석"""
        scores = {'happy': 0, 'alert': 0, 'fearful': 0, 'relaxed': 0}
        
        nose = keypoints.get('nose')
        mouth = keypoints.get('mouth')
        
        if nose and mouth:
            if nose['y'] < mouth['y']:  # 머리를 들고 있음
                scores['alert'] = 0.6
                scores['happy'] = 0.4
            else:
                scores['relaxed'] = 0.5
        
        return scores
    
    def _analyze_video_emotion(self, video_data: Dict) -> Dict:
        """영상 전체 감정 분석"""
        frames = video_data.get('frames', {})
        frame_emotions = []
        
        # 각 프레임별 감정 분석
        for frame_key, frame_data in frames.items():
            emotion_result = self._analyze_frame_emotion(frame_data)
            frame_emotions.append(emotion_result)
        
        if not frame_emotions:
            return self._get_neutral_emotion()
        
        # 전체 영상의 감정 통계
        emotion_counts = {'happy': 0, 'alert': 0, 'fearful': 0, 'relaxed': 0}
        confidence_sum = {'happy': 0, 'alert': 0, 'fearful': 0, 'relaxed': 0}
        
        for emotion in frame_emotions:
            primary = emotion['primary_emotion']
            emotion_counts[primary] += 1
            confidence_sum[primary] += emotion['confidence']
        
        # 가장 많이 나타난 감정 결정
        primary_emotion = max(emotion_counts, key=emotion_counts.get)
        avg_confidence = confidence_sum[primary_emotion] / max(emotion_counts[primary_emotion], 1)
        
        return {
            'primary_emotion': primary_emotion,
            'confidence': avg_confidence,
            'frame_count': len(frame_emotions),
            'emotion_distribution': emotion_counts,
            'analysis_type': 'video',
            'timestamp': datetime.now().isoformat()
        }
    
    def _get_neutral_emotion(self) -> Dict:
        """중립 감정 반환"""
        return {
            'primary_emotion': 'neutral',
            'confidence': 0.5,
            'emotion_scores': {
                'happy': 0.25, 'alert': 0.25, 
                'fearful': 0.25, 'relaxed': 0.25
            },
            'timestamp': datetime.now().isoformat()
        }