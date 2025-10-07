#!/usr/bin/env python3
"""
슬개골 탈구 위험도 탐지 모델
"""

import numpy as np
import math
from typing import Dict, List, Tuple
from datetime import datetime

class PatellaDetector:
    """관절 데이터를 이용한 슬개골 탈구 위험도 분석"""
    
    def __init__(self):
        """초기화"""
        self.risk_thresholds = {
            'low': 0.3,
            'medium': 0.6,
            'high': 0.8
        }
        
        # 관련 키포인트 정의
        self.left_leg_points = ['left_b_shoulder', 'left_b_wrist', 'left_b_ankle']
        self.right_leg_points = ['right_b_shoulder', 'right_b_wrist', 'right_b_ankle']
    
    def analyze_patella_risk(self, keypoint_data: Dict) -> Dict:
        """
        슬개골 탈구 위험도 분석
        
        Args:
            keypoint_data: 키포인트 데이터
            
        Returns:
            슬개골 분석 결과
        """
        if 'frames' in keypoint_data:
            # 영상 데이터인 경우
            return self._analyze_video_patella(keypoint_data)
        else:
            # 단일 프레임인 경우
            return self._analyze_frame_patella(keypoint_data)
    
    def _analyze_frame_patella(self, frame_data: Dict) -> Dict:
        """단일 프레임 슬개골 분석"""
        keypoints = frame_data.get('keypoints', {})
        
        if not keypoints:
            return self._get_normal_result()
        
        # 양쪽 다리 분석
        left_analysis = self._analyze_leg_alignment(keypoints, 'left')
        right_analysis = self._analyze_leg_alignment(keypoints, 'right')
        
        # 전체 위험도 계산
        overall_risk = max(left_analysis['risk_score'], right_analysis['risk_score'])
        risk_level = self._categorize_risk(overall_risk)
        
        return {
            'risk_level': risk_level,
            'overall_risk_score': overall_risk,
            'left_leg': left_analysis,
            'right_leg': right_analysis,
            'recommendations': self._generate_recommendations(overall_risk),
            'confidence': min(left_analysis['confidence'], right_analysis['confidence']),
            'timestamp': datetime.now().isoformat()
        }
    
    def _analyze_leg_alignment(self, keypoints: Dict, side: str) -> Dict:
        """다리 정렬 상태 분석"""
        if side == 'left':
            points = self.left_leg_points
        else:
            points = self.right_leg_points
        
        # 키포인트 추출
        leg_points = {}
        for point_name in points:
            if point_name in keypoints:
                leg_points[point_name] = keypoints[point_name]
        
        if len(leg_points) < 2:
            return {
                'risk_score': 0.0,
                'confidence': 0.0,
                'alignment_angle': None,
                'issues': ['insufficient_keypoints']
            }
        
        # 다리 정렬 각도 계산
        alignment_issues = []
        risk_factors = []
        
        # 1. 관절 각도 분석
        if len(leg_points) >= 3:
            angle_analysis = self._calculate_joint_angles(leg_points, side)
            alignment_issues.extend(angle_analysis['issues'])
            risk_factors.append(angle_analysis['risk_factor'])
        
        # 2. 다리 직선성 분석
        if len(leg_points) >= 2:
            straightness = self._analyze_leg_straightness(leg_points, side)
            alignment_issues.extend(straightness['issues'])
            risk_factors.append(straightness['risk_factor'])
        
        # 종합 위험도 계산
        risk_score = np.mean(risk_factors) if risk_factors else 0.0
        confidence = len(leg_points) / 3.0  # 키포인트 완성도 기반
        
        return {
            'risk_score': risk_score,
            'confidence': confidence,
            'alignment_issues': alignment_issues,
            'joint_angles': angle_analysis.get('angles', {}),
            'straightness_score': straightness.get('score', 0.0)
        }
    
    def _calculate_joint_angles(self, leg_points: Dict, side: str) -> Dict:
        """관절 각도 계산"""
        if side == 'left':
            shoulder_key = 'left_b_shoulder'
            wrist_key = 'left_b_wrist'
            ankle_key = 'left_b_ankle'
        else:
            shoulder_key = 'right_b_shoulder'
            wrist_key = 'right_b_wrist'
            ankle_key = 'right_b_ankle'
        
        angles = {}
        issues = []
        risk_factor = 0.0
        
        if all(key in leg_points for key in [shoulder_key, wrist_key, ankle_key]):
            # 무릎 각도 계산 (어깨-무릎-발목)
            shoulder = leg_points[shoulder_key]
            wrist = leg_points[wrist_key]  # 무릎 역할
            ankle = leg_points[ankle_key]
            
            # 벡터 계산
            v1 = np.array([shoulder['x'] - wrist['x'], shoulder['y'] - wrist['y']])
            v2 = np.array([ankle['x'] - wrist['x'], ankle['y'] - wrist['y']])
            
            # 각도 계산
            cos_angle = np.dot(v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2))
            cos_angle = np.clip(cos_angle, -1.0, 1.0)
            angle = math.degrees(math.acos(cos_angle))
            
            angles['knee_angle'] = angle
            
            # 비정상 각도 체크
            if angle < 120 or angle > 160:  # 정상 범위 벗어남
                issues.append(f'{side}_knee_abnormal_angle')
                risk_factor = min(0.8, abs(140 - angle) / 40)  # 정상각도 140도 기준
        
        return {
            'angles': angles,
            'issues': issues,
            'risk_factor': risk_factor
        }
    
    def _analyze_leg_straightness(self, leg_points: Dict, side: str) -> Dict:
        """다리 직선성 분석"""
        if side == 'left':
            points_order = ['left_b_shoulder', 'left_b_wrist', 'left_b_ankle']
        else:
            points_order = ['right_b_shoulder', 'right_b_wrist', 'right_b_ankle']
        
        available_points = [leg_points[key] for key in points_order if key in leg_points]
        
        if len(available_points) < 2:
            return {'score': 0.0, 'issues': [], 'risk_factor': 0.0}
        
        # 점들이 일직선상에 있는지 확인
        if len(available_points) == 3:
            # 세 점의 직선성 측정
            p1, p2, p3 = available_points
            
            # 선분의 기울기
            slope1 = (p2['y'] - p1['y']) / (p2['x'] - p1['x'] + 1e-8)
            slope2 = (p3['y'] - p2['y']) / (p3['x'] - p2['x'] + 1e-8)
            
            # 기울기 차이로 직선성 측정
            slope_diff = abs(slope1 - slope2)
            straightness_score = max(0, 1 - slope_diff / 2)
            
            issues = []
            risk_factor = 0.0
            
            if straightness_score < 0.7:
                issues.append(f'{side}_leg_misalignment')
                risk_factor = 1 - straightness_score
            
            return {
                'score': straightness_score,
                'issues': issues,
                'risk_factor': risk_factor
            }
        
        return {'score': 0.5, 'issues': [], 'risk_factor': 0.0}
    
    def _analyze_video_patella(self, video_data: Dict) -> Dict:
        """영상 전체 슬개골 분석"""
        frames = video_data.get('frames', {})
        frame_analyses = []
        
        # 각 프레임별 분석
        for frame_key, frame_data in frames.items():
            analysis = self._analyze_frame_patella(frame_data)
            if analysis['confidence'] > 0.5:  # 신뢰할 만한 분석만
                frame_analyses.append(analysis)
        
        if not frame_analyses:
            return self._get_normal_result()
        
        # 프레임별 결과 통합
        left_risks = [a['left_leg']['risk_score'] for a in frame_analyses]
        right_risks = [a['right_leg']['risk_score'] for a in frame_analyses]
        
        # 평균 위험도
        avg_left_risk = np.mean(left_risks)
        avg_right_risk = np.mean(right_risks)
        overall_risk = max(avg_left_risk, avg_right_risk)
        
        # 위험도 변화 분석
        left_trend = self._analyze_risk_trend(left_risks)
        right_trend = self._analyze_risk_trend(right_risks)
        
        return {
            'risk_level': self._categorize_risk(overall_risk),
            'overall_risk_score': overall_risk,
            'left_leg': {
                'average_risk': avg_left_risk,
                'trend': left_trend,
                'consistency': np.std(left_risks)
            },
            'right_leg': {
                'average_risk': avg_right_risk,
                'trend': right_trend,
                'consistency': np.std(right_risks)
            },
            'frame_count': len(frame_analyses),
            'recommendations': self._generate_recommendations(overall_risk),
            'analysis_type': 'video',
            'timestamp': datetime.now().isoformat()
        }
    
    def _analyze_risk_trend(self, risk_scores: List[float]) -> str:
        """위험도 변화 트렌드 분석"""
        if len(risk_scores) < 3:
            return 'insufficient_data'
        
        # 선형 회귀로 트렌드 계산
        x = np.arange(len(risk_scores))
        slope = np.polyfit(x, risk_scores, 1)[0]
        
        if slope > 0.01:
            return 'increasing'
        elif slope < -0.01:
            return 'decreasing'
        else:
            return 'stable'
    
    def _categorize_risk(self, risk_score: float) -> str:
        """위험도 점수를 등급으로 변환"""
        if risk_score < self.risk_thresholds['low']:
            return 'low'
        elif risk_score < self.risk_thresholds['medium']:
            return 'medium'
        elif risk_score < self.risk_thresholds['high']:
            return 'high'
        else:
            return 'very_high'
    
    def _generate_recommendations(self, risk_score: float) -> List[str]:
        """위험도에 따른 권고사항 생성"""
        recommendations = []
        
        if risk_score < 0.3:
            recommendations = [
                "정기적인 운동으로 근력 유지",
                "적정 체중 관리",
                "정기 건강검진 권장"
            ]
        elif risk_score < 0.6:
            recommendations = [
                "수의사 상담 권장",
                "격한 운동 피하기",
                "체중 관리 필수",
                "관절 보조제 고려"
            ]
        else:
            recommendations = [
                "즉시 수의사 진료 필요",
                "운동 제한",
                "전문적인 치료 계획 수립",
                "정기적인 모니터링 필요"
            ]
        
        return recommendations
    
    def _get_normal_result(self) -> Dict:
        """정상 결과 반환"""
        return {
            'risk_level': 'low',
            'overall_risk_score': 0.0,
            'left_leg': {'risk_score': 0.0, 'confidence': 0.0},
            'right_leg': {'risk_score': 0.0, 'confidence': 0.0},
            'recommendations': ["데이터 부족으로 정확한 분석 불가"],
            'confidence': 0.0,
            'timestamp': datetime.now().isoformat()
        }