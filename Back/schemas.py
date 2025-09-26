#API 데이터 형식 정의
from pydantic import BaseModel, EmailStr # pydantic은 데이터 검증 라이브러리

# 회원가입 시 받을 데이터 (Request Body)
class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    name: str
    age: int | None = None
    phone_number: str | None = None

# 회원가입 후 응답으로 보낼 데이터 (비밀번호 제외)
    #    보안을 위해 비밀번호(password)는 절대 포함하지 않음
class UserResponse(BaseModel):
    user_id: int
    username: str
    email: EmailStr
    name: str

    class Config:
        from_attributes = True # SQLAlchemy 모델을 Pydantic 모델로 변환