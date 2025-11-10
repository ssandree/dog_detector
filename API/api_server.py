#!/usr/bin/env python3
"""
AI API 서버 - 프론트엔드와 직접 통신
실시간 강아지 탐지 및 영상 분석 API
"""

from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
import asyncio
from typing import Dict, Optional
import io
from datetime import datetime
import requests
import tempfile
import os
from pathlib import Path

# AI 서비스 import
from ai_service import get_ai_service

# FastAPI 앱 생성
app = FastAPI(
    title="Dog Detection AI API",
    description="강아지 탐지 및 건강 분석 API",
    version="1.0.0"
)

# CORS 설정 (프론트엔드 연결용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 실제 배포시에는 특정 도메인으로 제한
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# AI 서비스 인스턴스
ai_service = get_ai_service()

@app.get("/")
async def root():
    """API 상태 확인"""
    return {"message": "강아지 AI 분석 서버가 실행중입니다 🐕"}

@app.post("/api/detect-realtime")
async def detect_dog_realtime(
    file: UploadFile = File(...),
    camera_id: str = Form(...)
):
    """
    실시간 강아지 탐지 - 프론트엔드용 (다중 카메라 지원)
    이미지 한 장을 받아서 강아지 탐지 후 녹화 신호 반환
    
    입력:
    - file: 카메라 프레임 이미지
    - camera_id: 카메라 식별 번호 (예: "camera_1", "camera_2")
    
    반환값:
    - camera_id: 입력받은 카메라 번호
    - should_start_recording: 녹화 시작 신호 (true/false)
    - confidence: 탐지 신뢰도 (0.0 ~ 1.0)
    """
    try:
        # 업로드된 이미지를 bytes로 읽기
        image_bytes = await file.read()
        
        # AI 서비스로 탐지 실행
        detection_result = await ai_service.detect_dog_realtime(image_bytes)
        
        if "error" in detection_result:
            raise HTTPException(status_code=400, detail=detection_result["error"])
        
        # 프론트엔드용 단순화된 응답 형식 (카메라 ID 포함)
        return JSONResponse(content={
            "camera_id": camera_id,
            "should_start_recording": detection_result["should_record"],
            "confidence": detection_result["confidence"]
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"실시간 탐지 실패: {str(e)}")

@app.post("/api/analyze-video-url")
async def analyze_video_from_url(video_url: str = Form(...)):
    """
    클라우드 URL로부터 MP4 영상 완전 분석
    음성 분리 + 포즈 분석 + 감정 분석을 한번에 처리
    
    반환값:
    - emotion: "편안/안정", "불안/슬픔", "공포", "공격성" 중 하나
    - patella_status: "정상" 또는 "이상"
    """
    try:
        # 1. 클라우드에서 영상 다운로드
        print(f"🌐 클라우드에서 MP4 다운로드: {video_url}")
        
        # 임시 파일 생성
        with tempfile.NamedTemporaryFile(delete=False, suffix='.mp4') as temp_file:
            temp_path = temp_file.name
            
            # URL에서 영상 다운로드
            response = requests.get(video_url, stream=True, timeout=30)
            response.raise_for_status()
            
            # 청크 단위로 다운로드
            downloaded_size = 0
            for chunk in response.iter_content(chunk_size=8192):
                temp_file.write(chunk)
                downloaded_size += len(chunk)
        
        print(f"✅ MP4 다운로드 완료: {temp_path} ({downloaded_size/1024/1024:.1f}MB)")
        
        # 2. MP4 완전 분석 실행 (음성 분리 + 포즈 + 감정)
        analysis_result = await ai_service.process_mp4_complete(temp_path)
        
        # 3. 임시 파일 삭제
        try:
            os.unlink(temp_path)
        except:
            pass
        
        if "error" in analysis_result:
            raise HTTPException(status_code=400, detail=analysis_result["error"])
        
        # 4. 단순화된 응답 형식
        return JSONResponse(content={
            "emotion": analysis_result["analysis"]["emotion_analysis"]["primary_emotion"],
            "patella_status": analysis_result["analysis"]["patella_analysis"]["status"]
        })
        
    except requests.RequestException as e:
        raise HTTPException(status_code=400, detail=f"MP4 다운로드 실패: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"MP4 분석 실패: {str(e)}")

@app.post("/api/analyze-video-file")
async def analyze_video_file(file: UploadFile = File(...)):
    """
    업로드된 MP4 파일 완전 분석
    프론트엔드에서 직접 파일을 업로드하는 경우
    
    반환값:
    - emotion: "편안/안정", "불안/슬픔", "공포", "공격성" 중 하나
    - patella_status: "정상" 또는 "이상"
    """
    try:
        # 파일 확장자 검증
        if not file.filename or not file.filename.lower().endswith(('.mp4', '.mov', '.avi')):
            raise HTTPException(status_code=400, detail="지원하지 않는 파일 형식입니다. MP4, MOV, AVI만 지원합니다.")
        
        # 임시 파일로 저장
        with tempfile.NamedTemporaryFile(delete=False, suffix='.mp4') as temp_file:
            temp_path = temp_file.name
            content = await file.read()
            temp_file.write(content)
        
        print(f"📁 업로드된 파일: {file.filename} ({len(content)/1024/1024:.1f}MB)")
        
        # MP4 완전 분석 실행
        analysis_result = await ai_service.process_mp4_complete(temp_path)
        
        # 임시 파일 삭제
        try:
            os.unlink(temp_path)
        except:
            pass
        
        if "error" in analysis_result:
            raise HTTPException(status_code=400, detail=analysis_result["error"])
        
        # 단순화된 응답 형식
        return JSONResponse(content={
            "emotion": analysis_result["analysis"]["emotion_analysis"]["primary_emotion"],
            "patella_status": analysis_result["analysis"]["patella_analysis"]["status"]
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"MP4 분석 실패: {str(e)}")

@app.get("/api/analysis/{dog_id}")
async def get_analysis_result(dog_id: str):
    """분석 결과 조회"""
    try:
        result = await ai_service.get_analysis_result(dog_id)
        
        if "error" in result:
            raise HTTPException(status_code=404, detail=result["error"])
        
        return JSONResponse(content=result)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"조회 실패: {str(e)}")

@app.get("/api/health-summary/{dog_id}")
async def get_health_summary(dog_id: str):
    """건강 상태 요약 조회"""
    try:
        result = ai_service.get_health_summary(dog_id)
        
        if "error" in result:
            raise HTTPException(status_code=404, detail=result["error"])
        
        return JSONResponse(content=result)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"요약 조회 실패: {str(e)}")

@app.get("/api/status")
async def get_api_status():
    """API 서버 상태 확인"""
    return {
        "status": "healthy",
        "service": "Dog Detection AI",
        "timestamp": datetime.now().isoformat(),
        "ai_models": "loaded"
    }

if __name__ == "__main__":
    print("🚀 강아지 AI 분석 서버 시작")
    print("📡 프론트엔드 연동 가능")
    print("🌐 API 문서: http://localhost:8000/docs")
    print("=" * 50)
    
    uvicorn.run(
        "api_server:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )