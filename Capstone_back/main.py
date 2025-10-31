# main.py

from fastapi import *
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from typing import List  # 리스트 형태의 응답을 위해 추가
from datetime import *

# 지금까지 만든 모든 부품들을 가져옴
import crud, models, schemas, security
from database import engine, get_db
from utils import s3

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

# =======================================================================
# 이벤트(Event) 엔드포인트 (새로 추가/수정)
# =======================================================================

@app.post("/events/upload", response_model=schemas.EventResponse, tags=["Events"])
async def upload_video_and_create_event(
    # 파일과 폼 데이터를 함께 받기 위해 File과 Form을 사용합니다.
    file: UploadFile = File(...),
    pet_id: int = Form(...),
    device_id: int = Form(...),
    start_time: datetime = Form(...),
    video_duration_sec: int = Form(...),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    """
    영상 클립을 S3에 업로드하고, '분석 대기중(PENDING)' 상태의
    이벤트 레코드를 DB에 생성합니다.
    """
    
    # --- 보안 검증: pet_id와 device_id가 현재 사용자의 소유인지 확인 ---
    db_pet = crud.get_pet_by_id(db, pet_id=pet_id)
    if not db_pet or db_pet.user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="해당 반려동물에 대한 업로드 권한이 없습니다.")

    db_device = crud.get_device_by_id(db, device_id=device_id)
    if not db_device or db_device.user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="해당 디바이스에 대한 업로드 권한이 없습니다.")
    
    # 1. S3에 파일 업로드 (비동기 처리)
    file_url = await s3.upload_file_to_s3(file, user_id=current_user.user_id)
    if not file_url:
        raise HTTPException(status_code=500, detail="S3 파일 업로드에 실패했습니다.")
        
    # (선택 사항) 썸네일 URL 생성 로직 (지금은 임시로 video_url 사용)
    thumbnail_url = file_url 

    # 2. DB에 저장할 이벤트 데이터 준비 (스키마 사용)
    event_data = schemas.EventCreate(
        pet_id=pet_id,
        device_id=device_id,
        start_time=start_time,
        end_time=start_time + timedelta(seconds=video_duration_sec),
        video_duration_sec=video_duration_sec,
        video_url=file_url,
        thumbnail_url=thumbnail_url,
        analysis_status="PENDING" # '분석 대기' 상태로 생성
    )

    # 3. DB에 이벤트 생성 (crud 함수 호출)
    new_event = crud.create_event(db=db, event=event_data)
    
    # 4. (향후 구현) Celery 워커에게 AI 분석 작업 지시
    # celery_app.send_task('tasks.analyze_video', args=[new_event.event_id, file_url])
    
    return new_event

@app.get("/pets/{pet_id}/events", response_model=List[schemas.EventResponse], tags=["Events"])
def read_events_for_pet(
    pet_id: int,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    """
    특정 반려동물의 이벤트 기록을 시간순(최신순)으로 조회합니다.
    """
    db_pet = crud.get_pet_by_id(db, pet_id=pet_id)
    if db_pet is None or db_pet.user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="해당 반려동물의 이벤트 조회 권한이 없습니다.")

    events = crud.get_events_by_pet(db=db, pet_id=pet_id, skip=skip, limit=limit)

# --- 루트 주소 추가 ---
@app.get("/", tags=["Root"])
def read_root():
    """
    API 서버의 루트 경로입니다. 서버가 정상적으로 실행 중인지 확인합니다.
    """
    return {"message": "견심술 API 서버에 오신 것을 환영합니다!"}