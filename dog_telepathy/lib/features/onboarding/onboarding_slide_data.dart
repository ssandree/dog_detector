// lib/features/onboarding/onboarding_slide_data.dart

class OnboardingSlideData {
  final String image;
  final String title;
  final String description;

  const OnboardingSlideData({
    required this.image,
    required this.title,
    required this.description,
  });

  static const slides = [
    OnboardingSlideData(
      image: 'assets/onboarding/onboarding_1.jpg',
      title: '감정 분석 시작',
      description: '강아지의 감정 상태를\nAI로 분석해보세요.',
    ),
    OnboardingSlideData(
      image: 'assets/onboarding/onboarding_2.jpg',
      title: '실시간 분석',
      description: '카메라로 실시간 감정 탐지.',
    ),
    OnboardingSlideData(
      image: 'assets/onboarding/onboarding_3.jpg',
      title: '보고서 제공',
      description: '하루 감정 리포트를 자동 생성합니다.',
    ),
  ];
}
