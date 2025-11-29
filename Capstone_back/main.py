from fastapi import *
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from typing import Dict, List  # 리스트 형태의 응답을 위해 추가
from datetime import *
import os
from urllib.parse import urlparse

# 지금까지 만든 모든 부품들을 가져옴
import crud, models, schemas, security
from database import engine, get_db
from utils import s3
import httpx
import boto3
from botocore.exceptions import NoCredentialsError

# 제미나이 api를 위한 import
from utils import gemini  # 이거 한 줄 추가
from sqlalchemy import cast, Date # 이것도 없으면 추가

# 알림푸시기능을 위한 모듈
from utils import fcm

from schemas import DeviceStatusUpdate # import 추가

import uuid
import time

# 임시 저장소 (메모리)

# DB 테이블 생성 (앱 실행 시 한번만)
models.Base.metadata.create_all(bind=engine)

# FastAPI 앱을 생성합니다.
app = FastAPI(
    title="견심술 API",
    description="반려견 이상행동 및 감정 분석 시스템 API입니다.",
    version="0.1.0"
)

# [1] 서버 켜질 때 Firebase 연결
@app.on_event("startup")
def startup_event():
    fcm.initialize_firebase()

# (!!!) .env에서 AI 서버 URL과 API 키를 읽어옵니다.
AI_SERVER_URL = os.getenv("AI_SERVER_URL")
AI_API_KEY = os.getenv("AI_API_KEY") # 새로 추가된 키
AI_SERVER_URL = os.getenv("AI_SERVER_URL")
if AI_SERVER_URL is None:
    print("WARNING: .env를 읽지 못해 하드코딩된 주소를 사용합니다.")
    AI_SERVER_URL = "http://dog-det.ddns.net:8000/api/analyze-video-url" 

# API 키도 마찬가지로 없으면 직접 입력
AI_API_KEY = os.getenv("AI_API_KEY")
if AI_API_KEY is None:
    AI_API_KEY = "idontwantdoganymore"

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

# [추가] 알림 수신 여부 변경 API
@app.put("/users/notification", tags=["Users"])
def update_notification_setting(
    setting: schemas.NotificationSetting,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    """
    알림 수신 여부를 변경합니다. (enabled: true/false)
    """
    current_user.notification_enabled = setting.enabled
    db.commit()
    
    status = "켜짐" if setting.enabled else "꺼짐"
    return {"message": f"알림 설정이 '{status}'으로 변경되었습니다."}


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
# 이벤트(Event) 엔드포인트 (!!!) (S3 URL을 AI 서버로 전송) (!!!)
# =======================================================================
@app.post("/events/upload", response_model=schemas.EventResponse, tags=["Events"])
async def upload_video_and_create_event(
    file: UploadFile = File(...),
    pet_id: int = Form(...),
    device_id: int = Form(...),
    start_time: datetime = Form(...),
    video_duration_sec: int = Form(...),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    print("====== [DEBUG START] 업로드 프로세스 시작 ======")
    
    # 1. 보안 검증
    db_pet = crud.get_pet_by_id(db, pet_id=pet_id)
    if not db_pet or db_pet.user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="권한 없음: 반려동물")
    db_device = crud.get_device_by_id(db, device_id=device_id)
    if not db_device or db_device.user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="권한 없음: 디바이스")

    # 2. S3 업로드
    file_url = None
    try:
        print("DEBUG: S3 업로드 시도 중...")
        file_url = await s3.upload_file_to_s3(file, user_id=current_user.user_id)
        if not file_url:
             raise Exception("S3 업로드 결과가 None입니다.")
        print(f"DEBUG: S3 업로드 성공. URL: {file_url}")
    except Exception as e:
        print(f"ERROR: S3 업로드 실패: {e}")
        raise HTTPException(status_code=500, detail=f"S3 업로드 에러: {e}")

    # 3. 파일명 추출
    s3_filename = ""
    try:
        parsed_url = urlparse(file_url)
        s3_filename = parsed_url.path.lstrip('/')
        print(f"DEBUG: S3 Filename: {s3_filename}")
    except Exception as e:
        print(f"ERROR: URL 파싱 실패: {e}")
        raise HTTPException(status_code=500, detail="URL 파싱 실패")

    # 4. AWS 클라이언트 설정
    aws_access_key = os.getenv("AWS_ACCESS_KEY_ID")
    aws_secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")
    aws_region = os.getenv("AWS_DEFAULT_REGION") 
    s3_bucket_name = os.getenv("AWS_S3_BUCKET_NAME") 
    
    # 디버깅: 변수 확인
    print(f"DEBUG: Env Check -> Region: {aws_region}, Bucket: {s3_bucket_name}")

    if not aws_region:
        aws_region = "ap-southeast-2" # 시드니
    
    # 버킷 이름 없으면 에러
    if not s3_bucket_name:
         print("CRITICAL: 버킷 이름이 없습니다.")

    try:
        s3_client = boto3.client(
            's3',
            aws_access_key_id=aws_access_key,
            aws_secret_access_key=aws_secret_key,
            region_name=aws_region 
        )
    except Exception as e:
         print(f"ERROR: boto3 client 생성 실패: {e}")
         raise HTTPException(status_code=500, detail=f"AWS 설정 오류: {e}")

    # 5. AI 서버 요청 (여기가 수정됨!)
    analysis_result = {}
    try:
        current_ai_url = os.getenv("AI_SERVER_URL")
        if not current_ai_url:
            current_ai_url = "http://dog-det.ddns.net:8000/api/analyze-video-url"

        parsed_env_url = urlparse(current_ai_url)
        base_domain = f"{parsed_env_url.scheme}://{parsed_env_url.netloc}"
        endpoint = "/api/analyze-video-url"
        full_url = f"{base_domain}{endpoint}"

        # Presigned URL 생성
        presigned_url = s3_client.generate_presigned_url(
            'get_object',
            Params={'Bucket': s3_bucket_name, 'Key': s3_filename},
            ExpiresIn=3600
        )
        print(f"DEBUG: Generated Presigned URL: {presigned_url}")

        current_api_key = os.getenv("AI_API_KEY")
        if not current_api_key:
            current_api_key = "idontwantdoganymore"

        # Payload 설정
        payload = {"video_url": presigned_url}
        
        # [수정] 헤더에서 Content-Type 완전히 제거 (httpx가 Form Data용으로 자동 설정함)
        headers = {
            "X-API-Key": current_api_key
        }

        print(f"DEBUG: Sending to AI (Form Data): {full_url}")

        async with httpx.AsyncClient(timeout=120.0) as client:
            # ★★★ [핵심] json= 대신 data= 사용! (Form Data 전송) ★★★
            response = await client.post(full_url, data=payload, headers=headers)
            
            if response.status_code != 200:
                print(f"ERROR: AI Server responded {response.status_code}: {response.text}")
            else:
                analysis_result = response.json()
                print(f"DEBUG: AI Analysis Success: {analysis_result}")

    except Exception as e:
        print(f"WARNING: AI 분석 요청 실패: {e}")
        import traceback
        traceback.print_exc()

    # 6. DB 저장
    try:
        final_emotion = None
        patella_status = None
        
        if analysis_result:
            final_emotion = analysis_result.get("emotion")
            patella_status = str(analysis_result.get("patella_status"))

        event_data = schemas.EventCreate(
            pet_id=pet_id,
            device_id=device_id,
            start_time=start_time,
            end_time=start_time + timedelta(seconds=video_duration_sec),
            video_duration_sec=video_duration_sec,
            video_url=file_url,
            thumbnail_url=file_url,
            final_emotion=final_emotion,
            patella_analysis_result=patella_status
        )
        
        new_event = crud.create_event(db=db, event=event_data)
        print("====== [DEBUG END] DB 저장 완료 ======")
        return new_event
        
    except Exception as e:
        print(f"ERROR: DB 저장 실패: {e}")
        raise HTTPException(status_code=500, detail=f"DB 저장 실패: {e}")

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

    return events

# =======================================================================
# 데일리 리포트(Daily Report) 엔드포인트 (New!)
# =======================================================================

@app.post("/reports/generate", response_model=schemas.DailyReportResponse, tags=["Reports"])
def generate_daily_report_api(
    pet_id: int,
    target_date: date, # 예: 2025-11-24
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    """
    특정 날짜의 이벤트를 분석하여 Gemini가 작성한 리포트를 생성 및 저장합니다.
    """
    # 1. 권한 확인
    db_pet = crud.get_pet_by_id(db, pet_id=pet_id)
    if not db_pet or db_pet.user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="권한이 없습니다.")

    # 2. 이미 리포트가 있는지 확인 (중복 생성 방지)
    existing_report = db.query(models.DailyReport).filter(
        models.DailyReport.pet_id == pet_id,
        models.DailyReport.report_date == target_date
    ).first()
    
    if existing_report:
        # 이미 있으면 그거 반환 (덮어쓰고 싶으면 delete 후 진행하는 로직 추가 가능)
        return existing_report

    # 3. 해당 날짜의 이벤트(Events) 모두 가져오기
    # DB에서 start_time의 날짜 부분이 target_date와 일치하는지 조회
    daily_events = db.query(models.Event).filter(
        models.Event.pet_id == pet_id,
        cast(models.Event.start_time, Date) == target_date
    ).all()

    if not daily_events:
        raise HTTPException(status_code=404, detail="해당 날짜에 분석된 영상 기록이 없습니다.")

    # 4. Gemini에게 요약 요청 (utils/gemini.py 호출)
    summary = gemini.generate_daily_summary(
        pet_name=db_pet.name,
        report_date=target_date,
        events=daily_events
    )

    # 5. DB에 리포트 저장
    new_report = models.DailyReport(
        pet_id=pet_id,
        report_date=target_date,
        summary_text=summary
    )
    db.add(new_report)
    db.commit()
    db.refresh(new_report)

    return new_report

@app.get("/reports/{pet_id}", response_model=List[schemas.DailyReportResponse], tags=["Reports"])
def read_pet_reports(
    pet_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    """
    특정 반려동물의 생성된 모든 리포트를 조회합니다.
    """
    # 권한 확인
    db_pet = crud.get_pet_by_id(db, pet_id=pet_id)
    if not db_pet or db_pet.user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="권한이 없습니다.")

    reports = db.query(models.DailyReport).filter(
        models.DailyReport.pet_id == pet_id
    ).order_by(models.DailyReport.report_date.desc()).all()
    
    return reports

# [2] 푸시 알림 기능 토큰 저장 API 추가 (프론트가 호출함)
@app.put("/users/fcm-token", tags=["Users"])
def update_fcm_token(
    token: str = Body(..., embed=True),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    current_user.fcm_token = token
    db.commit()
    return {"message": "토큰 저장 완료"}

# ... (중략: upload_video_and_create_event 함수 내부) ...

# [3] 영상 업로드 함수 안에서 알림 발송 (맨 마지막 return 직전)
    try:
        # DB에서 현재 사용자 정보(토큰) 다시 조회
        user_info = crud.get_user(db, user_id=current_user.user_id)
        if user_info.fcm_token:
            fcm.send_push_notification(
                token=user_info.fcm_token,
                title="🐕 행동 분석 완료!",
                body=f"방금 업로드한 영상 분석이 끝났습니다. 결과를 확인해보세요."
            )
        else:
            print("🔕 알림이 꺼져있거나 토큰이 없어 전송하지 않았습니다.")
    except Exception as e:
        print(f"알림 에러(무시): {e}")

    return new_event

# ==========================================
# [WebRTC] 고급 시그널링 (세션 기반) - NEW!
# ==========================================

# 임시 저장소 (실제 배포시엔 Redis를 쓰지만, 지금은 딕셔너리로 충분함)
# 구조: { target_device_id: "SDP 문자열" }
# offers = {} 
# answers = {}
# candidates = {}

sessions: Dict[str, dict] = {}

# 1. TURN 서버 정보 제공 (요청서 2번)
@app.get("/webrtc/config", response_model=schemas.WebRTCConfigResponse, tags=["WebRTC"])
def get_webrtc_config():
    return {
        "iceServers": [
            {
                "urls": ["stun:54.206.79.248:3478"] # STUN
            },
            {
                "urls": [
                    "turn:54.206.79.248:3478?transport=udp",
                    "turn:54.206.79.248:3478?transport=tcp"
                ],
                "username": "webrtcuser",
                "credential": "webrtcpass"
            }
        ]
    }

# 2. Offer 전송 및 세션 생성 (Cam -> Server)
@app.post("/stream/offer", response_model=schemas.RTCOfferResponse, tags=["WebRTC"])
def send_offer(data: schemas.RTCOfferRequest):
    # 세션 ID 생성
    session_id = str(uuid.uuid4())
    
    # 세션 저장
    sessions[session_id] = {
        "sender": data.sender_device_id,
        "receiver": data.receiver_device_id,
        "offer": data.sdp_offer,
        "answer": None,
        "candidates": [], # 후보군 리스트
        "created_at": time.time()
    }
    
    return {"session_id": session_id}

# 2-1. [수정] Offer 조회 (Manager -> Server)
@app.get("/stream/offer", response_model=schemas.RTCOfferCheckResponse, tags=["WebRTC"])
def get_offer(session_id: str):
    """
    Session ID를 통해 저장된 SDP Offer를 조회합니다.
    - Offer 존재 시: {"session_id": "...", "sdp_offer": "..."}
    - Offer 대기 중: {"session_id": null, "sdp_offer": null}
    """
    # 세션이 존재하고, Offer가 있는 경우
    if session_id in sessions and sessions[session_id].get("offer"):
        return {
            "session_id": session_id,
            "sdp_offer": sessions[session_id]["offer"]
        }
    
    # 세션이 없거나 Offer가 없는 경우 (JSON null 반환)
    return {
        "session_id": None,
        "sdp_offer": None
    }

# 3. Answer 저장 (Manager -> Server)
@app.post("/stream/answer", tags=["WebRTC"])
def send_answer(data: schemas.RTCAnswerRequest):
    if data.session_id in sessions:
        sessions[data.session_id]["answer"] = data.sdp_answer
        return {"message": "Answer saved"}
    raise HTTPException(status_code=404, detail="Session not found")

# 4. Answer 조회 (Cam -> Server)
@app.get("/stream/answer", response_model=schemas.RTCAnswerResponse, tags=["WebRTC"])
def get_answer(session_id: str):
    if session_id in sessions:
        return {"sdp_answer": sessions[session_id]["answer"]}
    # 세션이 없거나 답장이 아직 없으면 null 반환
    return {"sdp_answer": None}

# 5. Candidate 등록 (양방향)
@app.post("/stream/candidate", tags=["WebRTC"])
def send_candidate(data: schemas.RTCCandidateRequest):
    if data.session_id in sessions:
        # 상대방이 읽어갈 수 있게 저장
        sessions[data.session_id]["candidates"].append({
            "from_device_id": data.sender_device_id,
            "target_device_id": data.receiver_device_id, # 누가 읽어야 하는지
            "candidate": data.candidate
        })
        return {"message": "Candidate saved"}
    raise HTTPException(status_code=404, detail="Session not found")

# 6. Candidate 조회 및 삭제 (읽으면 사라짐)
@app.get("/stream/candidates", response_model=schemas.RTCCandidateListResponse, tags=["WebRTC"])
def get_candidates(session_id: str, device_id: str):
    if session_id not in sessions:
        return {"candidates": []}
    
    all_candidates = sessions[session_id]["candidates"]
    my_candidates = []
    remaining_candidates = []
    
    # 나한테 온 메시지만 골라내기
    for cand in all_candidates:
        if cand["target_device_id"] == str(device_id):
            my_candidates.append({
                "from_device_id": cand["from_device_id"],
                "candidate": cand["candidate"]
            })
        else:
            remaining_candidates.append(cand)
            
    # 읽은 건 삭제하고 나머지만 다시 저장 (Queue 방식)
    sessions[session_id]["candidates"] = remaining_candidates
    
    return {"candidates": my_candidates}

# ---------------------------------------------------------
# [추가] 자동 연결을 위한 세션 조회 API (요청사항 반영)
# ---------------------------------------------------------

# 1. 활성 세션 목록 조회 (최신순 정렬)
@app.get("/stream/sessions", response_model=schemas.SessionListResponse, tags=["WebRTC"])
def get_active_sessions():
    """
    현재 서버 메모리에 저장된 모든 WebRTC 세션 목록을 반환합니다.
    (created_at 기준 내림차순 정렬)
    """
    active_list = []
    
    for session_id, data in sessions.items():
        active_list.append({
            "session_id": session_id,
            "sender": str(data.get("sender")),   # 혹시 int일까봐 str변환
            "receiver": str(data.get("receiver")),
            "created_at": data.get("created_at")
        })
    
    # 최신순 정렬 (created_at이 큰 게 앞으로)
    active_list.sort(key=lambda x: x["created_at"] or 0, reverse=True)
    
    return {"sessions": active_list}


# 2. 가장 최신 세션 자동 반환
@app.get("/stream/latest", response_model=schemas.SessionInfo, tags=["WebRTC"])
def get_latest_session():
    """
    가장 최근에 생성된 세션 하나를 반환합니다. (Manager 자동 연결용)
    세션이 없으면 null을 반환합니다.
    """
    if not sessions:
        return {"session_id": None}
    
    # 딕셔너리에서 created_at이 가장 큰(최신) 키 찾기
    latest_session_id = max(sessions, key=lambda k: sessions[k].get("created_at", 0))
    data = sessions[latest_session_id]
    
    return {
        "session_id": latest_session_id,
        "sender": str(data.get("sender")),
        "receiver": str(data.get("receiver")),
        "created_at": data.get("created_at")
    }

# ==========================================
# [유지] 디바이스 상태 관리
# ==========================================

@app.put("/devices/{device_id}/status", response_model=schemas.DeviceResponse, tags=["Devices"])
def update_device_status(
    device_id: int,
    status_update: schemas.DeviceStatusUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    """
    카메라(Cam)가 자신의 상태를 서버에 알릴 때 사용합니다.
    status: 'offline' | 'connecting' | 'connected'
    """
    db_device = crud.get_device_by_id(db, device_id=device_id)
    if not db_device:
        raise HTTPException(status_code=404, detail="디바이스를 찾을 수 없습니다.")
    
    # 상태 업데이트
    db_device.connection_status = status_update.connection_status
    db.commit()
    db.refresh(db_device)
    
    return db_device

# ... (기존 코드들) ...

# =======================================================================
# [추가] 날짜별/월별 이벤트 조회 API
# =======================================================================

# 1. 📅 일일 이벤트 목록 조회 (데일리 리포트용)
@app.get("/pets/{pet_id}/events/daily", response_model=List[schemas.EventResponse], tags=["Events"])
def read_daily_events(
    pet_id: int,
    target_date: date, # 쿼리 파라미터 (?target_date=2025-11-27)
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    """
    특정 날짜(YYYY-MM-DD)에 발생한 모든 이벤트 목록을 조회합니다.
    """
    # 1. 권한 확인
    db_pet = crud.get_pet_by_id(db, pet_id=pet_id)
    if not db_pet or db_pet.user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="권한이 없습니다.")

    # 2. 조회 및 반환
    return crud.get_daily_events(db, pet_id=pet_id, target_date=target_date)


# 2. 🗓️ 월간 이벤트 목록 조회 (캘린더용)
@app.get("/pets/{pet_id}/events/monthly", response_model=List[schemas.EventResponse], tags=["Events"])
def read_monthly_events(
    pet_id: int,
    year: int,  # 쿼리 파라미터 (?year=2025)
    month: int, # 쿼리 파라미터 (?month=11)
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    """
    특정 년/월(YYYY, MM)에 발생한 모든 이벤트 목록을 조회합니다.
    캘린더에 점을 찍거나 월간 통계를 낼 때 사용합니다.
    """
    # 1. 권한 확인
    db_pet = crud.get_pet_by_id(db, pet_id=pet_id)
    if not db_pet or db_pet.user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="권한이 없습니다.")

    # 2. 조회 및 반환
    return crud.get_monthly_events(db, pet_id=pet_id, year=year, month=month)

# --- 루트 주소 추가 ---
@app.get("/", tags=["Root"])
def read_root():
    """
    API 서버의 루트 경로입니다. 서버가 정상적으로 실행 중인지 확인합니다.
    """
    return {"message": "견심술 API 서버에 오신 것을 환영합니다!"}
