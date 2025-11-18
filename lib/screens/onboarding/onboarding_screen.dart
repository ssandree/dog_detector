import '../../core/index_export.dart';
import 'widgets/onboarding_slide_template.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  late final List<Widget> _slides;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _slides = [
      const OnboardingSlideTemplate(
        imageAsset: 'lib/config/onboarding_1st.jpg',
        title: '견심술에서는',
        description: 'AI 기반 감정 분석으로 반려견의 기분을 더 정확하게 이해할 수 있어요. 촬영부터 저장, 분석까지 간편하게 한 번에!',
      ),
      const OnboardingSlideTemplate(
        imageAsset: 'lib/config/onboarding_2nd.jpg',
        title: '캠 모드에서는',
        description: '캠 모드에서 카메라 각도를 조정하고 녹화를 시작하면, AI가 자세와 활동을 분석해줍니다.',
      ),
      OnboardingSlideTemplate(
        imageAsset: 'lib/config/onboarding_3rd.jpg',
        title: '매니저 모드에서는',
        description: '저장된 영상과 사진에서 반려견의 감정 변화를 한눈에 볼 수 있어요. 하루·주간·월간 감정 리포트로 더 깊은 인사이트를 얻어보세요.',
        footer: AppButtons.primary(
          text: '시작하기',
          onPressed: _handleGetStarted,
        ),
      ),
    ];
  }

  void _handleGetStarted() => context.go(AppRoutes.login);

  void _handleSkip() => context.go(AppRoutes.modeSelect);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: AppConstants.defaultPadding,
          child: Column(
            children: [
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
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: AppConstants.defaultAnimationDuration,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: isActive ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.appBarColor : AppColors.grey3,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              AppConstants.h20,
            ],
          ),
        ),
      ),
    );
  }
}

