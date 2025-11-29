#API 데이터 형식 정의
from pydantic import BaseModel, EmailStr # pydantic은 데이터 검증 라이브러리
from typing import List, Optional
from datetime import *
from uuid import UUID

# 회원가입 시 받을 데이터 (Request Body)
class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    name: str
    age: int | None = None
    phone_number: str | None = None

# 회원가입 후 응답으로 보낼 데이터 (비밀번호 제외)
# 보안을 위해 비밀번호(password)는 절대 포함하지 않음
class UserResponse(BaseModel):
    user_id: int
    username: str
    email: EmailStr
    name: str

    class Config:
        from_attributes = True # SQLAlchemy 모델을 Pydantic 모델로 변환

# --- 사용자 정보 '수정'을 위한 스키마 ---
class UserUpdate(BaseModel):
    """
    사용자 정보 수정 시 Request Body로 사용됩니다.
    모든 필드를 Optional로 선언하여, 사용자가 원하는 정보만 보낼 수 있도록 합니다.
    """
    email: Optional[EmailStr] = None
    name: Optional[str] = None
    age: Optional[int] = None
    phone_number: Optional[str] = None

# --- 로그인 기능을 위한 스키마 ---

# =======================================================================
# 인증(Authentication) 관련 스키마
# ======================================================================

# JWT 토큰 응답 모델
class Token(BaseModel):
    access_token: str
    token_type: str

# 토큰 페이로드(내용물) 모델
class TokenData(BaseModel):
    username: str | None = None

# =======================================================================
# 반려동물(Pet) 관련 스키마 (새로 추가되는 부분)
# =======================================================================

# -----------------------------------------------------------------------
# 1. PetBase: 공통 속성을 정의하는 기본 '틀'
# -----------------------------------------------------------------------
class PetBase(BaseModel):
    """
    Pet 생성과 조회 시 공통으로 사용되는 필드를 정의합니다.
    """
    name: str
        # --- DB 모델과 일치하도록 필드 추가 ---
    breed: Optional[str] = None
    birth_date: Optional[date] = None
    weight_kg: Optional[float] = None # 몸무게는 소수점이 있을 수 있으므로 float, 필수가 아니므로 Optional
    height_cm: Optional[float] = None # 신장도 마찬가지
    photo_url: Optional[str] = None

# -----------------------------------------------------------------------
# 2. PetCreate: 펫 '생성' 시 클라이언트가 보내는 데이터 양식
# -----------------------------------------------------------------------
class PetCreate(PetBase):
    """
    POST /pets/ 요청 시 Request Body로 사용됩니다.
    PetBase를 상속받아 모든 필드를 그대로 사용합니다.
    pet_id나 user_id는 서버에서 자동으로 처리하므로 여기에 포함되지 않습니다.
    """
    pass  # 지금은 PetBase와 동일하므로 추가 필드 없음

# -----------------------------------------------------------------------
# 3. PetResponse: 펫 정보 '응답' 시 서버가 보내는 데이터 양식
# -----------------------------------------------------------------------
class PetResponse(PetBase):
    """
    펫 정보 API의 응답(Response) 모델로 사용됩니다.
    DB에 저장된 후 생성되는 pet_id와 user_id가 추가로 포함됩니다.
    """
    pet_id: int
    user_id: int

    class Config:
        from_attributes = True  # SQLAlchemy 모델 객체를 Pydantic 모델로 자동 변환해주는 설정

# --- 반려동물 정보 '수정'을 위한 스키마 (새로 추가) ---
class PetUpdate(BaseModel):
    """
    반려동물 정보 수정 시 Request Body로 사용됩니다.
    모든 필드를 Optional로 선언하여, 사용자가 원하는 정보만 보낼 수 있도록 합니다.
    """
    name: Optional[str] = None
    breed: Optional[str] = None
    birth_date: Optional[date] = None
    weight_kg: Optional[float] = None
    height_cm: Optional[float] = None
    photo_url: Optional[str] = None


# =======================================================================
# 확장 스키마 (선택 사항)
# =======================================================================

# 사용자 정보 조회 시, 해당 사용자의 펫 목록까지 함께 보여주고 싶을 때 사용
class UserResponseWithPets(UserResponse):
    pets: List[PetResponse] = []


# =======================================================================
# 디바이스(Device) 관련 스키마 (새로 추가)
# =======================================================================

class DeviceBase(BaseModel):
    device_name: str
    device_type: str  # "CAMERA" 또는 "MONITOR"

class DeviceCreate(DeviceBase):
    pass

class DeviceResponse(DeviceBase):
    device_id: int
    user_id: int
    status: str

    # [추가] 이제 조회할 때 이 필드가 같이 나갑니다.
    connection_status: str 

    class Config:
        from_attributes = True

# =======================================================================
# 이벤트(Event) 관련 스키마
# =======================================================================

class EventBase(BaseModel):
    """
    이벤트 생성 시점에 아는 정보들의 기본 틀
    """
    pet_id: int
    device_id: int
    start_time: datetime
    end_time: Optional[datetime] = None
    video_duration_sec: Optional[int] = None
    video_url: str  # S3 업로드 후 생성된 URL
    thumbnail_url: Optional[str] = None
    # (!!!) AI 분석 결과를 생성 시점에 함께 받음
    detected_features: Optional[str] = None 
    final_emotion: Optional[str] = None
    patella_analysis_result: Optional[str] = None
    
    # (!!!) analysis_status 필드 삭제
#    analysis_status: str = "PENDING"

class EventCreate(EventBase):
    """
    이벤트 생성 시 DB에 저장하기 위한 데이터 형식
    EventBase를 상속받아 모든 필드를 그대로 사용합니다.
    """
    pass

class EventResponse(EventBase):
    """
    이벤트 조회 시 응답 모델 (AI 분석 결과 포함)
    DB 저장 후 생성되는 event_id와
    나중에 AI 분석이 완료되면 채워질 필드들을 포함합니다.
    """
    event_id: int
    
    # AI 분석이 완료된 후 채워질 필드들
#    detected_features: Optional[str] = None
#    final_emotion: Optional[str] = None

    class Config:
        from_attributes = True

# =======================================================================
# 제미나이 api 관련 스키마
# =======================================================================
class DailyReportResponse(BaseModel):
    report_id: int
    pet_id: int
    report_date: date
    summary_text: str
    created_at: datetime

    class Config:
        orm_mode = True

# 1. 상태 업데이트용 스키마 (새로 추가)
class DeviceStatusUpdate(BaseModel):
    connection_status: str  # 'offline', 'connecting', 'connected' 중 하나

# ==========================================
# [WebRTC] 고급 시그널링 (New! 요청서 반영)
# ==========================================

# 1. TURN 서버 정보 응답용
class IceServer(BaseModel):
    urls: List[str]
    username: Optional[str] = None
    credential: Optional[str] = None

class WebRTCConfigResponse(BaseModel):
    iceServers: List[IceServer]

# 2. Offer (Cam -> Server)
class RTCOfferRequest(BaseModel):
    sender_device_id: str
    receiver_device_id: str
    sdp_offer: str

class RTCOfferResponse(BaseModel):
    session_id: str

# 3. Answer (Manager <-> Server)
class RTCAnswerRequest(BaseModel):
    session_id: str
    sdp_answer: str

class RTCAnswerResponse(BaseModel):
    sdp_answer: Optional[str]

# 4. Candidate (양방향)
class RTCCandidateRequest(BaseModel):
    session_id: str
    sender_device_id: str
    receiver_device_id: str
    candidate: str

class RTCCandidateResponse(BaseModel):
    from_device_id: str
    candidate: str

class RTCCandidateListResponse(BaseModel):
    candidates: List[RTCCandidateResponse]

# [추가] GET /stream/offer 응답용 모델 (DTO)
class RTCOfferCheckResponse(BaseModel):
    session_id: Optional[str] = None
    sdp_offer: Optional[str] = None

# [추가] 알림 설정 변경용 스키마
class NotificationSetting(BaseModel):
    enabled: bool

# [추가] 세션 정보 요약 (조회용)
class SessionInfo(BaseModel):
    session_id: Optional[str] = None
    sender: Optional[str] = None
    receiver: Optional[str] = None
    created_at: Optional[float] = None

# [추가] 1. 전체 세션 목록 응답
class SessionListResponse(BaseModel):
    sessions: List[SessionInfo]

# [추가] 2. 최신 세션 단건 응답 (없을 수도 있으므로 Optional)
# SessionInfo를 그대로 써도 되지만, 명확성을 위해 별칭 사용 가능
# 여기서는 SessionInfo를 그대로 리턴 타입으로 씁니다.

# [추가] 특정 디바이스의 최신 세션 조회 응답 (DTO)
class RTCLatestSessionResponse(BaseModel):
    session_id: Optional[str] = None
    created_at: Optional[float] = None