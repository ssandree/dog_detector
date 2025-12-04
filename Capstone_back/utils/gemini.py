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

def generate_period_summary(pet_name: str, period_type: str, report_data: str):
    """
    주간/월간 리포트 생성 함수
    :param pet_name: 반려동물 이름
    :param period_type: '주간' 또는 '월간'
    :param report_data: 날짜별 데일리 리포트 모음 텍스트
    """
    system_instruction = f"""
    당신은 반려동물 행동 심리 및 건강 분석 전문가입니다. 
    사용자가 제공하는 {pet_name}의 '{period_type} 기록'을 바탕으로 종합 리포트를 작성해야 합니다.
    
    [필수 포함 내용]
    1. **감정 변화 추이**: {period_type} 동안 아이의 기분이 전반적으로 어땠는지, 특정 요일에 불안해하거나 행복해한 패턴이 있는지 분석하세요.
    2. **건강 및 슬개골 상태**: 기록에 언급된 슬개골 탈구 위험이나 활동량을 바탕으로 건강 상태 변화를 서술하세요.
    3. **주요 행동 패턴**: 짖음, 하울링, 활동량 등 특이했던 행동들을 요약하세요.
    4. **보호자를 위한 조언**: 다음 {period_type} 동안 보호자가 특별히 신경 써야 할 점을 구체적으로 제안하세요.

    [작성 톤]
    - 전문적이면서도 보호자에게 따뜻하게 말하는 어조를 사용하세요.
    - 너무 딱딱하지 않게, 구체적인 날짜나 사건을 언급하며 작성하세요.
    - 한국어로 작성하세요.
    """

    prompt = f"""
    다음은 {pet_name}의 {period_type} 동안의 데일리 리포트 요약본입니다:

    {report_data}

    위 데이터를 종합하여 상세한 {period_type} 분석 리포트를 작성해주세요.
    """

    try:
        model = genai.GenerativeModel(
            model_name="gemini-2.5-flash-preview-09-2025", # 또는 사용중인 모델명
            system_instruction=system_instruction
        )
        
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        print(f"Gemini 기간 분석 실패: {e}")
        return f"AI 분석 중 오류가 발생했습니다. (데이터 부족 또는 통신 오류) - {str(e)}"