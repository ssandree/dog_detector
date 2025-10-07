# main.py

from fastapi import FastAPI, Depends, HTTPException, UploadFile, File
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
import asyncio
import os
from pathlib import Path

# 지금까지 만든 모든 부품들을 가져옴
import crud, models, schemas
from database import engine, get_db

# AI 서비스 import
from ai_service import get_ai_service, AIService

# DB 테이블 생성 (앱 실행 시 한번만)
models.Base.metadata.create_all(bind=engine)

# FastAPI 앱을 생성합니다.
app = FastAPI(
    title="견심술 API",
    description="반려견 이상행동 및 감정 분석 시스템 API입니다.",
    version="0.1.0",
)

# --- API 엔드포인트 정의 ---

@app.post("/users/", response_model=schemas.UserResponse, tags=["Users"])
def register_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    # 이메일 중복 확인
    db_user_email = crud.get_user_by_email(db, email=user.email)
    if db_user_email:
        raise HTTPException(status_code=400, detail="이미 등록된 이메일입니다.")
    
    # 아이디 중복 확인
    db_user_username = crud.get_user_by_username(db, username=user.username)
    if db_user_username:
        raise HTTPException(status_code=400, detail="이미 사용중인 아이디입니다.")
    
    # 사용자 생성
    created_user = crud.create_user(db=db, user=user)
    return created_user

# --- 루트 주소 추가 ---
@app.get("/", tags=["Root"])
def read_root():
    """
    API 서버의 루트 경로입니다. 서버가 정상적으로 실행 중인지 확인합니다.
    """
    return {"message": "견심술 API 서버에 오신 것을 환영합니다!"}

# --- AI 관련 엔드포인트 ---
@app.post("/ai/detect", tags=["AI"])
async def detect_dog_in_image(file: UploadFile = File(...)):
    """
    업로드된 이미지에서 강아지를 탐지합니다.
    """
    try:
        # 파일 읽기
        contents = await file.read()
        
        # AI 서비스로 탐지
        ai_service = get_ai_service()
        result = await ai_service.detect_dog_realtime(contents)
        
        return JSONResponse(content=result)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"탐지 처리 실패: {str(e)}")

@app.post("/ai/process-video", tags=["AI"])
async def process_video(
    video_path: str,
    dog_id: str = None
):
    """
    녹화된 영상을 처리하여 관절 데이터를 추출하고 AI 분석을 수행합니다.
    """
    try:
        ai_service = get_ai_service()
        result = await ai_service.process_recorded_video(video_path, dog_id)
        
        return JSONResponse(content=result)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"영상 처리 실패: {str(e)}")

@app.get("/ai/analysis/{dog_id}", tags=["AI"])
async def get_analysis_result(dog_id: str):
    """
    특정 강아지의 분석 결과를 조회합니다.
    """
    try:
        ai_service = get_ai_service()
        result = await ai_service.get_analysis_result(dog_id)
        
        if "error" in result:
            raise HTTPException(status_code=404, detail=result["error"])
        
        return JSONResponse(content=result)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"결과 조회 실패: {str(e)}")

@app.get("/ai/health-summary/{dog_id}", tags=["AI"])
def get_health_summary(dog_id: str):
    """
    강아지의 건강 상태 요약을 조회합니다.
    """
    try:
        ai_service = get_ai_service()
        result = ai_service.get_health_summary(dog_id)
        
        if "error" in result:
            raise HTTPException(status_code=404, detail=result["error"])
        
        return JSONResponse(content=result)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"요약 조회 실패: {str(e)}")

@app.get("/ai/status", tags=["AI"])
def get_ai_status():
    """
    AI 서비스 상태를 확인합니다.
    """
    try:
        ai_service = get_ai_service()
        return {
            "status": "active",
            "message": "AI 서비스가 정상적으로 실행 중입니다.",
            "services": {
                "dog_detection": "available",
                "video_processing": "available", 
                "emotion_analysis": "available",
                "patella_analysis": "available"
            }
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"AI 서비스 오류: {str(e)}"
        }