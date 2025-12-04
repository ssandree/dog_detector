# 1. 베이스 이미지 선택
FROM python:3.11-slim

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 라이브러리 설치 준비 (파일 먼저 복사)
COPY requirements.txt requirements.txt

# 1. OpenCV 및 동영상 처리를 위한 필수 시스템 라이브러리 설치
# (libgl1만으로는 부족합니다. ffmpeg, libsm6, libxext6가 있어야 mp4를 읽습니다)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    ffmpeg \
    gcc \
    build-essential \
    python3-dev && \
    \
    # 2. 파이썬 패키지 설치
    pip install --no-cache-dir -r requirements.txt && \
    \
    # 3. 빌드 도구만 삭제 (라이브러리는 유지)
    apt-get purge -y --auto-remove gcc build-essential python3-dev && \
    rm -rf /var/lib/apt/lists/*

# 5. 애플리케이션 코드 복사
COPY . .

# 6. 포트 노출
EXPOSE 8000

# 7. 기본 실행 명령어 (개발 중에는 docker-compose.yml의 command가 우선됨)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
