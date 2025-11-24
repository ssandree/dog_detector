import aioboto3
import os
from fastapi import UploadFile
import uuid

# .env 파일에서 AWS 설정 로드
AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_S3_BUCKET_NAME = os.getenv("AWS_S3_BUCKET_NAME")
AWS_DEFAULT_REGION = os.getenv("AWS_DEFAULT_REGION", "ap-northeast-2")

# S3 클라이언트 세션 생성
session = aioboto3.Session(
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name=AWS_DEFAULT_REGION
)

async def upload_file_to_s3(file: UploadFile, user_id: int) -> str:
    """
    비디오 파일을 S3에 업로드하고,
    외부(AI 서버)에서 다운로드 가능한 '임시 서명된 URL(Presigned URL)'을 반환합니다.
    """
    if not AWS_S3_BUCKET_NAME:
        raise ValueError("S3 버킷 이름(.env)이 설정되지 않았습니다.")

    file_extension = file.filename.split('.')[-1] if '.' in file.filename else 'mp4'
    file_key = f"videos/user_{user_id}/{uuid.uuid4()}.{file_extension}"

    try:
        async with session.client("s3") as s3:
            # 1. 파일 업로드
            await s3.upload_fileobj(
                file.file,
                AWS_S3_BUCKET_NAME,
                file_key,
                ExtraArgs={'ContentType': file.content_type}
            )
            
            # 2. (중요!) Presigned URL 생성 (유효기간 1시간)
            # 외부(AI 서버)가 이 URL로 접속하면 권한 없이도 다운로드 가능합니다.
            presigned_url = await s3.generate_presigned_url(
                'get_object',
                Params={'Bucket': AWS_S3_BUCKET_NAME, 'Key': file_key},
                ExpiresIn=3600  # 1시간 동안 유효
            )
            
            return presigned_url

    except Exception as e:
        print(f"S3 업로드 및 URL 생성 실패: {e}")
        return None
