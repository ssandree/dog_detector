#SQLAlchemy ORM 모델 (DB 테이블과 매핑되는 파이썬 클래스)
from sqlalchemy import Column, Integer, String, TIMESTAMP, text, ForeignKey, DECIMAL, Date
from sqlalchemy import *
from sqlalchemy.orm import relationship
from database import Base # database.py에서 만든 부모 클래스를 가져옴

# 'users' 테이블과 연결될 User 클래스
class User(Base):
    # 이 클래스는 DB의 'users'라는 테이블과 연결
    __tablename__ = "users"
    # 'users' 테이블의 각 컬럼(열)을 정의
    # user_id는 정수(Integer)이고, 기본 키(primary_key)임
    user_id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False)
    # password 컬럼 대신 hashed_password를 사용 (보안)
    hashed_password = Column(String(255), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    name = Column(String(50), nullable=False)
    age = Column(Integer, nullable=True)
    phone_number = Column(String(20), unique=True, nullable=True)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))


    # --- 이 관계 설정이 추가됩니다 ---
    # User 객체에서 user.pets를 통해 이 유저의 모든 반려동물 목록에 접근할 수 있습니다.
    pets = relationship("Pet", back_populates="owner")
    devices = relationship("Device", back_populates="owner")


# --- 새로운 Pet 모델 클래스를 추가합니다 ---
class Pet(Base):
    __tablename__ = "pets"
    
    pet_id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    name = Column(String(50), nullable=False)
    breed = Column(String(50), nullable=True)
    birth_date = Column(Date, nullable=True)
    weight_kg = Column(DECIMAL(5, 2), nullable=True)
    height_cm = Column(DECIMAL(5, 2), nullable=True)
    photo_url = Column(String(255), nullable=True)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    
    # Pet 객체에서 pet.owner를 통해 이 반려동물의 주인 정보에 접근할 수 있습니다.
    owner = relationship("User", back_populates="pets")
    # 펫에 연결된 이벤트 목록 (새로 추가)
    events = relationship("Event", back_populates="pet")

# --- 새로운 Device 모델 클래스를 추가합니다 ---
class Device(Base):
    __tablename__ = "devices"
    
    device_id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    device_name = Column(String(100), nullable=False)
    device_type = Column(String(20), nullable=False) # 'CAMERA' 또는 'MONITOR'
    status = Column(String(20), default='offline', nullable=False)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))

    # --- 관계 설정 ---
    owner = relationship("User", back_populates="devices")
    # 디바이스에 연결된 이벤트 목록 (새로 추가)
    events = relationship("Event", back_populates="device")


# =======================================================================
# 이벤트(Event) 모델 클래스 (새로 추가)
# =======================================================================
class Event(Base):
    __tablename__ = "events"

    event_id = Column(BIGINT, primary_key=True, autoincrement=True)
    pet_id = Column(Integer, ForeignKey("pets.pet_id"), nullable=False)
    device_id = Column(Integer, ForeignKey("devices.device_id"), nullable=False)
    # (!!!) DataGrip 컬럼 순서 및 이름과 일치시킵니다.
    event_type = Column(String(50), nullable=True)      # (있다면 유지, 없으면 삭제)
    event_subtype = Column(String(50), nullable=True)   # (있다면 유지, 없으면 삭제)

    # AI 분석 결과를 담을 컬럼들 (v3 - '진단서' 모델)
    detected_features = Column(TEXT, nullable=True)
    final_emotion = Column(String(50), nullable=True)
    # (!!!) 슬개골 분석 결과 컬럼 (새로 추가) [cite: `API_DOCS.md`]
    patella_analysis_result = Column(String(50), nullable=True)   
 
    # 시간 및 영상 정보
    start_time = Column(DATETIME, nullable=False)
    end_time = Column(DATETIME, nullable=True)
    video_duration_sec = Column(Integer, nullable=True)
    
#    # AI 분석 상태 (v4에서 추가됨)
#    analysis_status = Column(String(20), nullable=False, default='PENDING')
    
    # S3 파일 위치
    video_url = Column(String(255), nullable=True)
    thumbnail_url = Column(String(255), nullable=True)
    created_at = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))

    # --- 관계 설정 ---
    pet = relationship("Pet", back_populates="events")
    device = relationship("Device", back_populates="events")
