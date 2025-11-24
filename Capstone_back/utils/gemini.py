import google.generativeai as genai
import os

# 환경변수 설정
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
genai.configure(api_key=GEMINI_API_KEY)

# [추가] 디버깅용 출력 (서버 켜질 때 터미널 확인용)
print("=========================================")
try:
    print(f"🤖 Installed GenAI SDK Version: {genai.__version__}")
    print("📋 Available Models:")
    for m in genai.list_models():
        if 'generateContent' in m.supported_generation_methods:
            print(f" - {m.name}")
except Exception as e:
    print(f"❌ Model List Error: {e}")
print("=========================================")

# 일단 가장 안전한 'gemini-pro'로 설정해둡니다. (목록 보고 나중에 바꿀 예정)
model = genai.GenerativeModel('gemini-2.0-flash')

def generate_daily_summary(pet_name, report_date, events):
    if not model:
        return "AI 설정 오류: API 키가 없습니다."

    if not events:
        return "오늘은 기록된 활동이 없습니다."

    # DB 데이터를 글자로 변환
    event_logs = ""
    for event in events:
        # 시간 형식 안전하게 처리
        time_str = event.start_time.strftime("%H시 %M분") if hasattr(event.start_time, 'strftime') else str(event.start_time)
        emotion = event.final_emotion if event.final_emotion else "알 수 없음"
        patella = event.patella_analysis_result if event.patella_analysis_result else "정상"
        event_logs += f"- [{time_str}] 감정: {emotion}, 관절: {patella}\n"

    prompt = f"""
    반려견 이름: {pet_name}
    날짜: {report_date}
    활동 기록:
    {event_logs}

    위 기록을 바탕으로 반려견의 하루 일기를 다정하게 300자 내외로 써주세요.
    감정 변화와 관절 건강을 꼭 언급해주세요.
    """

    try:
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        return f"AI 리포트 생성 실패: {str(e)}"