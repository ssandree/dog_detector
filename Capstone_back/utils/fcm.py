import firebase_admin
from firebase_admin import credentials, messaging
import os

# 1. Firebase 초기화
def initialize_firebase():
    try:
        # 도커 내부 경로에 있는 json 파일을 읽음
        cred = credentials.Certificate("firebase_service_account.json")
        if not firebase_admin._apps:
            firebase_admin.initialize_app(cred)
            print("✅ Firebase 초기화 완료")
    except Exception as e:
        print(f"❌ Firebase 초기화 실패 (파일이 없거나 키가 틀림): {e}")

# 2. 알림 발송 함수
def send_push_notification(token: str, title: str, body: str):
    if not token:
        return
    try:
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            token=token,
        )
        response = messaging.send(message)
        print(f"🔔 푸시 전송 성공: {response}")
    except Exception as e:
        print(f"❌ 푸시 전송 실패: {e}")