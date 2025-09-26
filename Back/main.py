# main.py

from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
# 지금까지 만든 모든 부품들을 가져옴
import crud, models, schemas
from database import engine, get_db

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