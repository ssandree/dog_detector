# Common 모듈 초기화
"""
강아지 감정 및 슬개골 탈구 감지 시스템 - 공통 유틸리티 모듈
"""

__version__ = "1.0.0"
__author__ = "AI Team - Capstone Design"

# 주요 클래스들을 쉽게 import 할 수 있도록
from .models.dog_detection import DogDetector

__all__ = [
    'DogDetector'
]