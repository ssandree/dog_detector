#!/usr/bin/env python3
"""
AI 모델 패키징 스크립트
백엔드 팀원에게 전달할 파일들을 정리하고 압축
"""

import os
import shutil
import zipfile
from pathlib import Path

def create_ai_package():
    """AI 모델과 코드를 백엔드 배포용으로 패키징"""
    
    base_dir = Path(__file__).parent
    package_dir = base_dir / "AI_PACKAGE_FOR_BACKEND"
    
    # 패키지 디렉토리 생성
    if package_dir.exists():
        shutil.rmtree(package_dir)
    package_dir.mkdir()
    
    # 복사할 파일/폴더 목록
    files_to_copy = [
        # 핵심 AI 코드
        "ai_core_module.py",
        
        # API 서버 코드
        "API/api_server.py",
        "API/ai_service.py", 
        "API/API_DOCS.md",
        "API/SETUP_README.md",
        "API/test_backend_integration.py",
        
        # 🔥 모델 구조 정의 파일들 (중요!)
        "dog_emotion_model/emotion_model.py",
        "dog_emotion_model/stgcn.py", 
        "dog_emotion_model/vggish_loader.py",
        "dog_pattela_model/patella_model.py",
        
        # 🔥 훈련/로더 모듈 (중요!)
        "ai_train/train_emotion_a.py",  # DogVGGishTrainer 클래스
        "ai_train/train_emotion_v.py",  # 추가 훈련 모듈
        
        # 공통 전처리 모듈
        "common/data_preprocess_emotion.py",
        "common/data_preprocess_patella.py",
        
        # 🔥 관절 추출 관련 (중요!)
        "folder_extract_keypoints.py",  # 관절점 추출 로직
        
        # 모델 가중치 파일들
        "ai_train/best_dog_emotion_model_f1.pth",
        "ai_train/audio_emotion_model.pt", 
        "ai_train/dog_pose_stats.pt",
        
        "dog_pattela_model/patella_model.pt",
        "dog_pattela_model/patella_stats_seg60.pt",
        
        # YOLO 모델과 설정 
        "DogPose_Official/yolo11n_dog24_v242/weights/best.pt",
        "DogPose_Official/yolo11n_dog24_v242/args.yaml",  # YOLO 설정 파일
        
        # 설정 파일들
        "requirements.txt",
        "AI_DEPLOYMENT_GUIDE.md",
        
        # 🔥 Python 패키지 초기화 파일들 (중요!)
        "dog_emotion_model/__init__.py",
        "dog_pattela_model/__init__.py", 
        "common/__init__.py",
        "ai_train/__init__.py"
    ]
    
    # 파일 복사
    copied_files = []
    missing_files = []
    
    for file_path in files_to_copy:
        src = base_dir / file_path
        dst = package_dir / file_path
        
        if src.exists():
            # 디렉토리 생성
            dst.parent.mkdir(parents=True, exist_ok=True)
            
            if src.is_file():
                shutil.copy2(src, dst)
                copied_files.append(file_path)
                file_size = src.stat().st_size / (1024*1024)  # MB
                print(f"✅ 복사 완료: {file_path} ({file_size:.1f}MB)")
            else:
                shutil.copytree(src, dst)
                copied_files.append(file_path)
                print(f"✅ 폴더 복사: {file_path}")
        else:
            missing_files.append(file_path)
            print(f"❌ 파일 없음: {file_path}")
    
    # 실행 스크립트 생성
    start_script = package_dir / "start_ai_server.py"
    with open(start_script, 'w', encoding='utf-8') as f:
        f.write('''#!/usr/bin/env python3
"""
AI 서버 시작 스크립트 - 백엔드 배포용
"""
import sys
import subprocess
from pathlib import Path

def main():
    print("🤖 강아지 감정 분석 AI 서버 시작")
    print("=" * 50)
    
    # 현재 디렉토리 확인
    current_dir = Path(__file__).parent
    api_dir = current_dir / "API"
    
    if not api_dir.exists():
        print("❌ API 폴더를 찾을 수 없습니다.")
        return
    
    # 필요한 패키지 설치 확인
    try:
        import torch
        import cv2
        import fastapi
        import uvicorn
        print("✅ 필요한 패키지들이 설치되어 있습니다.")
    except ImportError as e:
        print(f"❌ 패키지 설치 필요: pip install -r requirements.txt")
        print(f"   누락된 패키지: {e}")
        return
    
    # API 서버 실행
    api_server_path = api_dir / "api_server.py"
    
    print(f"🚀 API 서버 실행: {api_server_path}")
    print("📡 서버 주소: http://localhost:8000")
    print("📚 API 문서: http://localhost:8000/docs")
    print("⏹️ 종료: Ctrl+C")
    print("=" * 50)
    
    # 서버 실행
    subprocess.run([sys.executable, str(api_server_path)], cwd=current_dir)

if __name__ == "__main__":
    main()
''')
    
    # README 생성
    readme_path = package_dir / "README.md"
    with open(readme_path, 'w', encoding='utf-8') as f:
        f.write(f'''# 🤖 강아지 감정 분석 AI 시스템 - 백엔드 배포 패키지

## 📦 패키지 내용
- **AI 코드**: {len([f for f in copied_files if f.endswith('.py')])}개 파이썬 파일
- **AI 모델**: {len([f for f in copied_files if f.endswith(('.pt', '.pth'))])}개 모델 파일 
- **문서**: API 명세서, 설정 가이드 포함

## 🚀 빠른 시작
1. `pip install -r requirements.txt`
2. `python start_ai_server.py`
3. 브라우저에서 `http://localhost:8000/docs` 확인

## 📡 API 엔드포인트
- `POST /api/analyze-video-url` - 비디오 URL 분석
- `POST /api/analyze-video-file` - 비디오 파일 업로드 분석

## 📋 응답 형식
```json
{{
  "emotion": "편안/안정",        // 감정 분석 결과
  "patella_status": "정상"      // 슬개골 탈구 분석 결과  
}}
```

## 📞 지원
AI 담당자 연락처: [여기에 연락처 입력]

---
*패키지 생성 시간: {copied_files}*
*포함된 파일 수: {len(copied_files)}개*
''')
    
    # 결과 요약
    print("\n" + "=" * 60)
    print("📦 AI 백엔드 배포 패키지 생성 완료!")
    print(f"📁 위치: {package_dir}")
    print(f"✅ 복사된 파일: {len(copied_files)}개")
    
    if missing_files:
        print(f"⚠️ 누락된 파일: {len(missing_files)}개")
        for file in missing_files:
            print(f"   - {file}")
    
    total_size = sum((package_dir / f).stat().st_size for f in copied_files if (package_dir / f).exists()) / (1024*1024)
    print(f"💾 총 크기: {total_size:.1f}MB")
    
    print("\n🎯 다음 단계:")
    print("1. AI_PACKAGE_FOR_BACKEND 폴더를 백엔드 담당자에게 전달")
    print("2. 백엔드 서버에서 압축 해제 후 start_ai_server.py 실행")
    print("3. API 연동 테스트 진행")

if __name__ == "__main__":
    create_ai_package()