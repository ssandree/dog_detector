# 1. 베이스 이미지 선택
FROM python:3.11-slim

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 라이브러리 설치 준비 (파일 먼저 복사)
COPY requirements.txt requirements.txt

# 4. 라이브러리 설치 (수정된 부분)
#    - C 컴파일러(gcc) 및 빌드 도구들을 설치하고,
#    - pip install을 실행한 뒤,
#    - 불필요해진 컴파일러와 도구들을 다시 삭제하여 이미지 용량을 최적화합니다.
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc build-essential python3-dev && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get purge -y --auto-remove gcc build-essential python3-dev && \
    rm -rf /var/lib/apt/lists/*
# 5. 애플리케이션 코드 복사
COPY . .

# 6. 포트 노출
EXPOSE 8000

# 7. 기본 실행 명령어 (개발 중에는 docker-compose.yml의 command가 우선됨)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
