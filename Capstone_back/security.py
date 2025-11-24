from passlib.context import CryptContext
from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
import os
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
import crud, models, database


# --- 기존 코드 ---
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str):
    return pwd_context.hash(password)

# --- 로그인 기능을 위해 추가된 코드 ---

# 비밀번호가 일치하는지 확인하는 함수
def verify_password(plain_password: str, hashed_password: str):
    return pwd_context.verify(plain_password, hashed_password)

# JWT 생성을 위한 설정값
# 실제 운영 시에는 .env 파일로 빼는게 좋음
SECRET_KEY = os.getenv("SECRET_KEY", "a_very_secret_key_for_gyeonsimsul")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# JWT(Access Token) 생성 함수
def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# =======================================================================
# ---      인증된 API를 위해 새로 추가되는 핵심 부분      ---
# =======================================================================

# FastAPI에 "토큰은 '/token' 주소에서 발급받는 방식이야" 라고 알려줍니다.
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(database.get_db)):
    """
    API 요청 헤더의 Authorization 필드에 담긴 JWT 토큰을 해석하여,
    현재 로그인된 사용자가 누구인지 식별하고 DB에서 해당 사용자 정보를 가져옵니다.
    이 함수는 인증이 필요한 모든 API에서 '의존성 주입(Dependency Injection)' 방식으로 사용됩니다.
    """
    # 인증 실패 시 보낼 표준 예외 응답
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        # 1. 토큰을 비밀키(SECRET_KEY)로 디코딩하여 내용(payload)을 추출합니다.
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        # 2. 내용물에서 사용자 아이디(username)를 꺼냅니다. (토큰 생성 시 'sub'라는 키로 저장했음)
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        # 토큰 디코딩에 실패하면 (유효하지 않은 토큰), 인증 실패 예외를 발생시킵니다.
        raise credentials_exception
    
    # 3. 토큰에서 얻은 아이디로 DB에서 실제 사용자 정보를 조회합니다.
    user = crud.get_user_by_username(db, username=username)
    if user is None:
        # 해당 아이디의 사용자가 DB에 없으면, 인증 실패 예외를 발생시킵니다.
        raise credentials_exception
        
    # 4. 모든 검증을 통과하면, 조회된 사용자 객체를 반환합니다.
    return user