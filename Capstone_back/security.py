#비밀번호 해싱 등 보안 관련 기능
from passlib.context import CryptContext

# 비밀번호 해싱을 위한 설정 (bcrypt 알고리즘 사용)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str):
    return pwd_context.hash(password)