# 실제 database와 상호작용하는 부분
#데이터베이스 생성, 조회, 수정, 삭제(CRUD) 로직
from sqlalchemy.orm import Session
import models, schemas, security

# 회원가입 part
# =======================================================================
# 이메일로 사용자 정보 조회 (중복 체크용)
def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

# 아이디로 사용자 정보 조회 (중복 체크용)
def get_user_by_username(db: Session, username: str):
    return db.query(models.User).filter(models.User.username == username).first()

# 사용자 생성 (회원가입)
def create_user(db: Session, user: schemas.UserCreate):
    # 비밀번호를 해싱 처리
    hashed_password = security.get_password_hash(user.password)
    
    # DB 모델 객체 생성
    db_user = models.User(
        username=user.username,
        email=user.email,
        hashed_password=hashed_password, # 해싱된 비밀번호 저장
        name=user.name,
        age=user.age,
        phone_number=user.phone_number
    )
    
    # DB에 추가 및 저장
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# 사용자 정보 수정
def update_user(db: Session, db_user: models.User, user_update: schemas.UserUpdate):
    update_data = user_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_user, key, value)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# 반려동물(Pet) 관련 CRUD 함수
# =======================================================================

def create_user_pet(db: Session, pet: schemas.PetCreate, user_id: int):
    """
    특정 사용자의 반려동물 정보를 DB에 생성합니다.
    """
    # schemas.PetCreate 객체(pet)와 user_id를 합쳐 models.Pet 객체를 만듭니다.
    db_pet = models.Pet(**pet.dict(), user_id=user_id)
    db.add(db_pet)
    db.commit()
    db.refresh(db_pet)
    return db_pet

def get_pets_by_user(db: Session, user_id: int, skip: int = 0, limit: int = 100):
    """
    특정 사용자의 반려동물 목록을 DB에서 조회합니다.
    """
    return db.query(models.Pet).filter(models.Pet.user_id == user_id).offset(skip).limit(limit).all()

# 반려동물 정보 수정
def update_pet(db: Session, db_pet: models.Pet, pet_update: schemas.PetUpdate):
    """
    DB에 저장된 반려동물 정보를 수정합니다.
    """
    update_data = pet_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_pet, key, value)
    db.add(db_pet)
    db.commit()
    db.refresh(db_pet)
    return db_pet

# =======================================================================
# 디바이스(Device) 관련 CRUD 함수 (새로 추가)
# =======================================================================

def create_user_device(db: Session, device: schemas.DeviceCreate, user_id: int):
    """ 특정 사용자의 디바이스 정보를 DB에 생성합니다. """
    db_device = models.Device(**device.dict(), user_id=user_id)
    db.add(db_device)
    db.commit()
    db.refresh(db_device)
    return db_device

def get_devices_by_user(db: Session, user_id: int):
    """ 특정 사용자의 모든 디바이스 목록을 조회합니다. """
    return db.query(models.Device).filter(models.Device.user_id == user_id).all()