import aioboto3
import os
from fastapi import UploadFile
import uuid

# .env 파일에서 AWS 설정 로드
AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_S3_BUCKET_NAME = os.getenv("AWS_S3_BUCKET_NAME")
AWS_DEFAULT_REGION = os.getenv("AWS_DEFAULT_REGION")

# S3 클라이언트 세션 생성
session = aioboto3.Session(
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name=AWS_DEFAULT_REGION
)

async def upload_file_to_s3(file: UploadFile, user_id: int) -> str:
    """
    비디오 파일을 S3에 업로드하고, S3 URL을 반환합니다.
    """
    if not AWS_S3_BUCKET_NAME:
        raise ValueError("S3 버킷 이름이 설정되지 않았습니다.")

    # 파일 이름을 고유하게 만듭니다. (예: user_1/random_uuid.mp4)
    file_extension = file.filename.split('.')[-1] if '.' in file.filename else 'mp4'
    file_key = f"videos/user_{user_id}/{uuid.uuid4()}.{file_extension}"

    try:
        async with session.client("s3") as s3:
            await s3.upload_fileobj(
                file.file,       # 업로드할 파일 객체
                AWS_S3_BUCKET_NAME, # 버킷 이름
                file_key,        # S3에 저장될 파일 경로/이름
                ExtraArgs={'ContentType': file.content_type}
            )
        
        # 업로드된 파일의 S3 URL 반환
        return f"https://{AWS_S3_BUCKET_NAME}.s3.{AWS_DEFAULT_REGION}.amazonaws.com/{file_key}"

    except Exception as e:
        print(f"S3 업로드 실패: {e}")
        return None
