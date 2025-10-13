#!/usr/bin/env python3
"""
🚀 AI API 서버 실행 스크립트
프론트/백엔드 연결 테스트용
"""

import subprocess
import sys
import time
import requests
from pathlib import Path

def check_dependencies():
    """필수 패키지 확인"""
    print("📦 패키지 의존성 확인...")
    
    required_packages = [
        "fastapi", "uvicorn", "ultralytics", "opencv-python", 
        "torch", "torchvision", "numpy", "requests"
    ]
    
    missing_packages = []
    for package in required_packages:
        try:
            __import__(package.replace("-", "_"))
            print(f"✅ {package}")
        except ImportError:
            missing_packages.append(package)
            print(f"❌ {package}")
    
    if missing_packages:
        print(f"\n⚠️ 누락된 패키지: {', '.join(missing_packages)}")
        print("설치 명령어:")
        print(f"pip install {' '.join(missing_packages)}")
        return False
    
    print("✅ 모든 패키지 설치 완료")
    return True

def check_model_files():
    """AI 모델 파일 확인"""
    print("\n🤖 AI 모델 파일 확인...")
    
    model_path = Path("DogPose_Official/yolo11n_dog24/weights/best.pt")
    
    if model_path.exists():
        print(f"✅ 학습된 모델: {model_path}")
        print(f"   파일 크기: {model_path.stat().st_size / 1024 / 1024:.1f}MB")
        return True
    else:
        print(f"❌ 모델 파일 없음: {model_path}")
        print("💡 해결 방법:")
        print("   python train_official_dog_pose.py  # 모델 학습 실행")
        return False

def start_api_server():
    """API 서버 시작"""
    print("\n🚀 AI API 서버 시작...")
    print("="*50)
    print("📡 엔드포인트:")
    print("   - POST /api/detect-realtime    (실시간 탐지)")
    print("   - POST /api/analyze-video-url  (영상 분석)")
    print("   - GET  /api/status             (서버 상태)")
    print("   - GET  /docs                   (API 문서)")
    print("="*50)
    print("🌐 서버 주소: http://localhost:8000")
    print("📚 API 문서: http://localhost:8000/docs")
    print("="*50)
    print("⚠️ 서버 중지: Ctrl+C")
    print()
    
    try:
        # uvicorn으로 서버 실행
        subprocess.run([
            sys.executable, "-m", "uvicorn", 
            "api_server:app", 
            "--host", "0.0.0.0", 
            "--port", "8000",
            "--reload"
        ])
    except KeyboardInterrupt:
        print("\n🛑 서버 중지됨")

def main():
    """메인 실행 함수"""
    print("🎯 AI API 서버 준비 체크")
    print("="*50)
    
    # 1. 패키지 확인
    if not check_dependencies():
        return
    
    # 2. 모델 파일 확인  
    if not check_model_files():
        return
    
    # 3. API 서버 시작
    start_api_server()

if __name__ == "__main__":
    main()