# 실제 database와 상호작용하는 부분
#데이터베이스 생성, 조회, 수정, 삭제(CRUD) 로직
from sqlalchemy.orm import Session
import models, schemas, security

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