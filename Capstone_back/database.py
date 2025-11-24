# sqlalchemy: 파이썬 코드로 DB를 다루게 해주는 '통역사' 라이브러리
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
#데이터베이스 연결 설정
import os
from dotenv import load_dotenv

## .env 파일에서 환경 변수를 로드합니다.
load_dotenv()

# 'DATABASE_URL'이라는 이름표(Key)를 가진 환경 변수의 값(Value)을 가져옵니다.
DATABASE_URL = os.getenv("DATABASE_URL")

# 만약 .env 파일을 못 읽었을 경우를 대비한 안전장치
if not DATABASE_URL:
    raise ValueError("오류: DATABASE_URL 환경 변수를 찾을 수 없습니다. .env 파일을 확인하거나 서버 실행 명령어를 확인해주세요.")
# 1. create_engine: DB와 연결하는 통로(파이프라인)를 생성
engine = create_engine(DATABASE_URL)

# 2. sessionmaker: DB와 대화할 수 있는 '대화 창구(세션)'를 만드는 공장
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 3. declarative_base: DB 테이블과 연결될 파이썬 클래스들이 상속받을 '부모' 클래스
Base = declarative_base()

# 4. get_db(): API가 호출될 때마다 독립적인 '대화 창구'를 하나씩 제공하고,
#    요청이 끝나면 창구를 자동으로 닫아주는 역할을 합니다.
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
