# 1. 베이스 이미지 선택: Python 3.11 슬림 버전을 기반으로 시작합니다.
FROM python:3.11-slim

# 2. 작업 디렉토리 설정: 컨테이너 내부에서 작업할 기본 폴더를 지정합니다.
WORKDIR /app

# 3. 라이브러리 설치 준비: requirements.txt 파일을 먼저 복사합니다.
#    이렇게 하면 코드 변경 시 매번 라이브러리를 다시 설치하지 않아 효율적입니다.
COPY requirements.txt requirements.txt

# 4. 라이브러리 설치: pip를 이용해 requirements.txt에 명시된 모든 라이브러리를 설치합니다.
RUN pip install --no-cache-dir -r requirements.txt

# 5. 애플리케이션 코드 복사: 현재 폴더(.)의 모든 파일을 컨테이너의 /app 폴더로 복사합니다.
COPY . .

# 6. 포트 노출: FastAPI 앱이 컨테이너 내부의 8000번 포트에서 실행될 것임을 알립니다.
EXPOSE 8000

# 7. 기본 실행 명령어: 컨테이너가 시작될 때 실행할 기본 명령어를 지정합니다.
#    --host 0.0.0.0 옵션은 컨테이너 외부에서의 접속을 허용합니다.
#    (docker-compose.yml에서 이 부분을 덮어쓸 수 있습니다.)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
