import cv2
import boto3
import numpy as np
import uuid
import os
from dotenv import load_dotenv

# .env 파일 로드
load_dotenv()

# 환경 변수 가져오기
S3_BUCKET_NAME = os.getenv("S3_BUCKET_NAME") # .env에 이 이름으로 되어있는지 확인하세요!
AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
REGION = "ap-northeast-2"

def create_and_upload_thumbnail(video_url: str):
    """
    비디오 URL에서 썸네일을 추출하여 S3에 업로드하고 이미지 URL을 반환합니다.
    """
    # 썸네일 생성 실패 시 비디오 URL을 대신 반환하기 위한 기본값
    final_url = video_url 
    
    cap = None
    try:
        # 1. OpenCV로 비디오 URL 열기
        cap = cv2.VideoCapture(video_url)
        
        if not cap.isOpened():
            print(f"❌ 비디오를 열 수 없습니다: {video_url}")
            return final_url

        # 2. 첫 번째 프레임 읽기
        success, frame = cap.read()
        
        if not success:
            print("❌ 프레임을 읽을 수 없습니다.")
            return final_url

        # 3. 이미지를 메모리(Bytes)로 인코딩
        _, buffer = cv2.imencode(".jpg", frame)
        io_buf = buffer.tobytes()

        # 4. S3 업로드 준비
        file_name = f"thumbnails/{uuid.uuid4()}.jpg"
        
        s3 = boto3.client(
            's3',
            aws_access_key_id=AWS_ACCESS_KEY,
            aws_secret_access_key=AWS_SECRET_KEY,
            region_name=REGION
        )

        # 5. S3 업로드
        s3.put_object(
            Bucket=S3_BUCKET_NAME,
            Key=file_name,
            Body=io_buf,
            ContentType='image/jpeg',
            ACL='public-read'
        )

        # 6. 이미지 URL 생성
        final_url = f"https://{S3_BUCKET_NAME}.s3.{REGION}.amazonaws.com/{file_name}"
        print(f"✅ 썸네일 생성 완료: {final_url}")

    except Exception as e:
        print(f"⚠️ 썸네일 생성 중 에러 발생: {e}")
    
    finally:
        if cap:
            cap.release()
            
    return final_url