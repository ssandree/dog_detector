# main.py

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from typing import List  # 리스트 형태의 응답을 위해 추가
# 지금까지 만든 모든 부품들을 가져옴
import crud, models, schemas, security
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

# --- 로그인 엔드포인트 ---
@app.post("/token", response_model=schemas.Token, tags=["Authentication"])
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = crud.get_user_by_username(db, username=form_data.username)
    
    if not user or not security.verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="아이디 또는 비밀번호가 잘못되었습니다.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token = security.create_access_token(
        data={"sub": user.username}
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me", response_model=schemas.UserResponseWithPets, tags=["Users"])
def read_users_me(current_user: models.User = Depends(security.get_current_user)):
    """현재 로그인된 사용자의 정보를 가져옵니다."""
    return current_user

@app.put("/users/me", response_model=schemas.UserResponse, tags=["Users"])
def update_user_me(
    user_update: schemas.UserUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    """현재 로그인된 사용자의 정보를 수정합니다."""
    if user_update.email and crud.get_user_by_email(db, email=user_update.email):
        raise HTTPException(status_code=400, detail="이미 등록된 이메일입니다.")
    if user_update.phone_number and crud.get_user_by_phone_number(db, phone_number=user_update.phone_number):
        raise HTTPException(status_code=400, detail="이미 등록된 전화번호입니다.")
    return crud.update_user(db=db, db_user=current_user, user_update=user_update)


# =======================================================================
# 반려동물(Pet) 엔드포인트 (새로 추가)
# =======================================================================

@app.post("/pets/", response_model=schemas.PetResponse, tags=["Pets"])
def create_pet_for_user(
    pet: schemas.PetCreate,
    db: Session = Depends(get_db),
    # 이 부분이 핵심: security.get_current_user 함수는 API를 호출한 사용자가
    # 유효한 토큰을 가지고 있는지 검사하고, 성공 시 해당 사용자 정보를 반환합니다.
    current_user: models.User = Depends(security.get_current_user)
):
    """
    현재 **로그인된 사용자**의 반려동물을 새로 등록합니다.
    
    API를 호출할 때는 반드시 HTTP 헤더에 `Authorization: Bearer {발급받은 토큰}`을 포함해야 합니다.
    """
    return crud.create_user_pet(db=db, pet=pet, user_id=current_user.user_id)

@app.get("/pets/", response_model=List[schemas.PetResponse], tags=["Pets"])
def read_user_pets(
    db: Session = Depends(get_db),
    # 이 API 또한 인증된 사용자만 호출할 수 있도록 보호합니다.
    current_user: models.User = Depends(security.get_current_user)
):
    """
    현재 **로그인된 사용자**의 모든 반려동물 목록을 조회합니다.
    
    API를 호출할 때는 반드시 HTTP 헤더에 `Authorization: Bearer {발급받은 토큰}`을 포함해야 합니다.
    """
    return crud.get_pets_by_user(db=db, user_id=current_user.user_id)

# --- 반려동물 정보 수정을 위한 API 엔드포인트 (새로 추가) ---
@app.put("/pets/{pet_id}", response_model=schemas.PetResponse, tags=["Pets"])
def update_pet_info(
    pet_id: int,
    pet_update: schemas.PetUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    """
    현재 로그인된 사용자의 특정 반려동물 정보를 수정합니다.
    """
    # 1. 수정하려는 반려동물이 DB에 존재하는지 확인합니다.
    db_pet = crud.get_pet_by_id(db, pet_id=pet_id)
    if db_pet is None:
        raise HTTPException(status_code=404, detail="반려동물 정보를 찾을 수 없습니다.")
    
    # 2. 수정하려는 반려동물의 주인이 현재 로그인한 사용자인지 확인합니다. (매우 중요!)
    if db_pet.user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="정보를 수정할 권한이 없습니다.")
        
    # 3. 모든 확인이 끝나면 정보를 수정합니다.
    updated_pet = crud.update_pet(db=db, db_pet=db_pet, pet_update=pet_update)
    return updated_pet



# =======================================================================
# 디바이스(Device) 엔드포인트 (새로 추가)
# =======================================================================
@app.post("/devices/", response_model=schemas.DeviceResponse, tags=["Devices"])
def create_device_for_user(
    device: schemas.DeviceCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    """
    현재 로그인된 사용자의 디바이스(촬영/모니터링 폰)를 등록합니다.
    - device_type: 'CAMERA' 또는 'MONITOR'
    """
    return crud.create_user_device(db=db, device=device, user_id=current_user.user_id)

@app.get("/devices/", response_model=List[schemas.DeviceResponse], tags=["Devices"])
def read_user_devices(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    """
    현재 로그인된 사용자의 모든 디바이스 목록을 조회합니다.
    """
    return crud.get_devices_by_user(db=db, user_id=current_user.user_id)



# --- 루트 주소 추가 ---
@app.get("/", tags=["Root"])
def read_root():
    """
    API 서버의 루트 경로입니다. 서버가 정상적으로 실행 중인지 확인합니다.
    """
    return {"message": "견심술 API 서버에 오신 것을 환영합니다!"}