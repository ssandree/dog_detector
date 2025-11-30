// lib/features/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/storage/app_prefs_provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/config/app_colors.dart';
import '../../core/widgets/portrait_lock.dart';
import 'onboarding_slide_data.dart';
import 'widgets/onboarding_slide.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = usePageController();
    final currentPage = useState(0);

    const slides = OnboardingSlideData.slides;

    Future<void> finish() async {
      await ref.read(appPrefsProvider.notifier).setHasSeenOnboarding(true);
      if (context.mounted) context.go('/login');
    }

    return PortraitLock(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h, right: 16.w),
                  child: TextButton(
                    onPressed: finish,
                    child: Text(
                      '건너뛰기',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: slides.length,
                  onPageChanged: (i) => currentPage.value = i,
                  itemBuilder: (_, i) => OnboardingSlide(data: slides[i]),
                ),
              ),

              SizedBox(height: 30.h),

              SmoothPageIndicator(
                controller: controller,
                count: slides.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 10.h,
                  dotWidth: 10.w,
                  activeDotColor: AppColors.primary,
                  dotColor: Colors.grey.shade300,
                  expansionFactor: 4,
                ),
              ),

              SizedBox(height: 20.h),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: currentPage.value == slides.length - 1
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        child: AppButton(
                          text: '시작하기',
                          onPressed: finish,
                        ),
                      )
                    : SizedBox(height: 50.h),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
