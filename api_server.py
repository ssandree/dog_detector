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
async def detect_dog_realtime(file: UploadFile = File(...)):
    """
    실시간 강아지 탐지 - 프론트엔드용
    이미지 한 장을 받아서 강아지 탐지 후 녹화 신호 반환
    """
    try:
        # 업로드된 이미지를 bytes로 읽기
        image_bytes = await file.read()
        
        # AI 서비스로 탐지 실행
        detection_result = await ai_service.detect_dog_realtime(image_bytes)
        
        if "error" in detection_result:
            raise HTTPException(status_code=400, detail=detection_result["error"])
        
        # 프론트엔드용 응답 형식
        response = {
            "success": True,
            "detected": detection_result["detected"],
            "confidence": detection_result["confidence"],
            "should_start_recording": detection_result["should_record"],  # 녹화 시작 신호
            "timestamp": detection_result["timestamp"],
            "message": "강아지 감지됨 - 녹화를 시작하세요!" if detection_result["should_record"] else "강아지 미감지"
        }
        
        return JSONResponse(content=response)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"탐지 실패: {str(e)}")

@app.post("/api/analyze-video-url")
async def analyze_video_from_url(video_url: str = Form(...), dog_id: Optional[str] = Form(None)):
    """
    클라우드 URL로부터 영상 분석
    AWS S3 등 클라우드에 저장된 영상을 URL로 받아서 분석
    """
    try:
        # 1. 클라우드에서 영상 다운로드
        print(f"🌐 클라우드에서 영상 다운로드: {video_url}")
        
        # 임시 파일 생성
        with tempfile.NamedTemporaryFile(delete=False, suffix='.mp4') as temp_file:
            temp_path = temp_file.name
            
            # URL에서 영상 다운로드
            response = requests.get(video_url, stream=True)
            response.raise_for_status()
            
            # 청크 단위로 다운로드
            for chunk in response.iter_content(chunk_size=8192):
                temp_file.write(chunk)
        
        print(f"✅ 영상 다운로드 완료: {temp_path}")
        
        # 2. AI 분석 실행
        analysis_result = await ai_service.process_recorded_video(temp_path, dog_id)
        
        # 3. 임시 파일 삭제
        try:
            os.unlink(temp_path)
        except:
            pass
        
        if "error" in analysis_result:
            raise HTTPException(status_code=400, detail=analysis_result["error"])
        
        # 4. 결과 반환
        return JSONResponse(content={
            "success": True,
            "analysis": analysis_result,
            "message": "영상 분석 완료"
        })
        
    except requests.RequestException as e:
        raise HTTPException(status_code=400, detail=f"영상 다운로드 실패: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"분석 실패: {str(e)}")

@app.post("/api/analyze-video-file")
async def analyze_video_file(file: UploadFile = File(...), dog_id: Optional[str] = Form(None)):
    """
    업로드된 영상 파일 분석
    프론트엔드에서 직접 파일을 업로드하는 경우
    """
    try:
        # 임시 파일로 저장
        with tempfile.NamedTemporaryFile(delete=False, suffix='.mp4') as temp_file:
            temp_path = temp_file.name
            content = await file.read()
            temp_file.write(content)
        
        # AI 분석 실행
        analysis_result = await ai_service.process_recorded_video(temp_path, dog_id)
        
        # 임시 파일 삭제
        try:
            os.unlink(temp_path)
        except:
            pass
        
        if "error" in analysis_result:
            raise HTTPException(status_code=400, detail=analysis_result["error"])
        
        return JSONResponse(content={
            "success": True,
            "analysis": analysis_result,
            "message": "영상 분석 완료"
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"분석 실패: {str(e)}")

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