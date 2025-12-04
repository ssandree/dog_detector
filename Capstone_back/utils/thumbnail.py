import cv2
import boto3
import numpy as np
import uuid
import os
from dotenv import load_dotenv

# .env 파일 로드
load_dotenv()

def create_and_upload_thumbnail(video_url: str):
    """
    비디오 URL에서 썸네일을 추출하여 S3에 업로드하고 이미지 URL을 반환합니다.
    """
    # 1. 환경 변수 읽기
    bucket_name = os.getenv("AWS_S3_BUCKET_NAME")
    access_key = os.getenv("AWS_ACCESS_KEY_ID")
    secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")

    # 리전은 .env에 없으면 하드코딩 (보통 ap-northeast-2 또는 ap-southeast-2 확인 필요)
    # 로그에 Region: ap-southeast-2 라고 떴으니 그걸로 맞춥니다.
    region = os.getenv("AWS_REGION", "ap-southeast-2")

    # [디버깅] 중요! 변수가 비어있는지 확인합니다.
    if not video_url:
        print("❌ [Thumb Error] 비디오 URL이 없습니다(None).")
        return None
    
    if not bucket_name or not access_key or not secret_key:
        print(f"❌ [Thumb Error] 환경 변수 누락! Bucket: {bucket_name}, AccessKey: {'O' if access_key else 'X'}, Secret: {'O' if secret_key else 'X'}")
        return video_url # 설정이 없으면 그냥 비디오 URL 반환

    final_url = video_url # 실패 시 기본값

    cap = None
    try:
        # 2. OpenCV로 비디오 열기
        cap = cv2.VideoCapture(video_url)
        
        if not cap.isOpened():
            print(f"❌ [Thumb Error] 비디오를 열 수 없습니다 (URL 확인 필요): {video_url}")
            return final_url

        # 3. 프레임 읽기
        success, frame = cap.read()
        if not success:
            print("❌ [Thumb Error] 프레임 읽기 실패 (빈 영상이거나 코덱 문제)")
            return final_url

        # 4. 인코딩
        _, buffer = cv2.imencode(".jpg", frame)
        io_buf = buffer.tobytes()

        # 5. S3 업로드
        file_name = f"thumbnails/{uuid.uuid4()}.jpg"
        
        s3 = boto3.client(
            's3',
            aws_access_key_id=access_key,
            aws_secret_access_key=secret_key,
            region_name=region
        )

        s3.put_object(
            Bucket=bucket_name,
            Key=file_name,
            Body=io_buf,
            ContentType='image/jpeg',
            # ACL='public-read' # (버킷 정책을 따라 삭제)
        )

        final_url = f"https://{bucket_name}.s3.{region}.amazonaws.com/{file_name}"
        print(f"✅ 썸네일 생성 성공: {final_url}")

    except Exception as e:
        # 에러가 나면 정확히 어디서 났는지 알려줌
        print(f"⚠️ 썸네일 생성 중 에러 발생: {e}")
        import traceback
        traceback.print_exc() # 상세 에러 로그 출력
    
    finally:
        if cap:
            cap.release()
            
    return final_url