import google.generativeai as genai
import os
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

# [수정됨] 첫 번째 인자 이름을 'events_summary' -> 'events'로 변경했습니다!
# (main.py가 'events'라는 이름으로 보내고 있기 때문입니다)
def generate_daily_summary(events: str, pet_name: str = "반려견", report_date: str = None):
    try:
        model = genai.GenerativeModel("gemini-2.0-flash")
        
        if not report_date:
            report_date = datetime.now().strftime("%Y-%m-%d")

        prompt = f"""
        당신은 반려견 행동 분석 전문가입니다. 다음 데이터를 바탕으로 리포트를 작성해 주세요.

        [분석 대상 정보]
        - 반려견 이름: {pet_name}
        - 날짜: {report_date}
        - 활동 기록:
        {events}

        [요청 사항]
        위 기록을 바탕으로 '{pet_name}'의 **정서적 건강(감정)**과 **신체적 건강(슬개골)**에 대한 분석 및 주의사항을 300자 내외로 작성해 주세요.
        보호자에게 말하듯이 따뜻한 어조를 사용하고, 문장 중간에 '{pet_name}'의 이름을 자연스럽게 언급해 주세요.

        [데이터 분석 규칙]
        1. 이상치 무시: 간헐적인 '비정상/불안' 데이터는 노이즈로 간주하고 무시하세요.
        2. 지배적 경향 우선: 가장 많이 관측된 상태를 실제 상태로 판단하세요.
        
        결과는 Markdown 기호 없이 줄글 텍스트로만 주세요.
        """

        response = model.generate_content(prompt)
        return response.text

    except Exception as e:
        print(f"⚠️ Gemini 리포트 생성 실패: {e}")
        return f"죄송합니다. 오늘은 {pet_name}의 리포트를 생성할 수 없습니다."