import '../../core/index_export.dart';
import 'widgets/onboarding_slide_template.dart';
import 'widgets/page_indicator.dart';

/// 온보딩 화면
/// 앱 사용법을 소개하는 슬라이드 화면입니다.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// 페이지 전환을 제어하는 컨트롤러
  late final PageController _pageController;
  
  /// 온보딩 슬라이드 목록 (총 3개)
  late final List<Widget> _slides;
  
  /// 현재 표시 중인 페이지 인덱스 (0부터 시작)
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // 페이지 컨트롤러 초기화
    _pageController = PageController();
    
    // 온보딩 슬라이드 3개 생성
    _slides = [
      // 첫 번째 슬라이드: 앱 소개
      const OnboardingSlideTemplate(
        imageAsset: 'lib/config/onboarding_1st.jpg',
        title: '견심술에서는',
        description: 'AI 기반 감정 분석으로 반려견의 기분을 더 정확하게 이해할 수 있어요. 촬영부터 저장, 분석까지 간편하게 한 번에!',
      ),
      // 두 번째 슬라이드: 캠 모드 소개
      const OnboardingSlideTemplate(
        imageAsset: 'lib/config/onboarding_2nd.jpg',
        title: '캠 모드에서는',
        description: '캠 모드에서 카메라 각도를 조정하고 녹화를 시작하면, AI가 자세와 활동을 분석해줍니다.',
      ),
      // 세 번째 슬라이드: 매니저 모드 소개
      const OnboardingSlideTemplate(
        imageAsset: 'lib/config/onboarding_3rd.jpg',
        title: '매니저 모드에서는',
        description: '저장된 영상과 사진에서 반려견의 감정 변화를 한눈에 볼 수 있어요. 하루·주간·월간 감정 리포트로 더 깊은 인사이트를 얻어보세요.',
      ),
    ];
  }

  /// '시작하기' 버튼 클릭 시 로그인 화면으로 이동
  void _handleGetStarted() => context.go(AppRoutes.login);

  /// '건너뛰기' 버튼 클릭 시 모드 선택 화면으로 이동
  void _handleSkip() => context.go(AppRoutes.modeSelect);

  @override
  void dispose() {
    // 페이지 컨트롤러 메모리 해제
    _pageController.dispose();
    super.dispose();
  }

  // 진짜 온보딩 화면
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: AppConstants.defaultPadding,
          child: Column(
            children: [
              // 상단 우측: 건너뛰기 버튼
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleSkip,
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(
                      fontSize: AppConstants.defaultFontSize - 2,
                      color: AppColors.grey8,
                    ),
                  ),
                ),
              ),
              
              // 중앙: 슬라이드 페이지뷰 (좌우 스와이프 가능)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  // 페이지 변경 시 현재 페이지 인덱스 업데이트
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  // 각 슬라이드 위젯 생성
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _slides[index],
                      ],
                    );
                  },
                ),
              ),
              
              AppConstants.h16,
              
              // 하단: 페이지 인디케이터 (현재 페이지 표시)
              PageIndicator(
                totalPages: _slides.length,
                currentPage: _currentPage,
              ),
              
              // 마지막 페이지일 때만 '시작하기' 버튼 표시
              if (_currentPage == _slides.length - 1) ...[
                AppConstants.h20,
                AppButtons.primary(
                  text: '시작하기',
                  onPressed: _handleGetStarted,
                ),
              ] else
                AppConstants.h20,
            ],
          ),
        ),
      ),
    );
  }
}

