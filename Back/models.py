#SQLAlchemy ORM 모델 (DB 테이블과 매핑되는 파이썬 클래스)
from sqlalchemy import Column, Integer, String, TIMESTAMP, text
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