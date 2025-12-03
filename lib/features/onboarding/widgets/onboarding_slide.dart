// lib/features/onboarding/widgets/onboarding_slide.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/config/app_colors.dart';
import '../onboarding_slide_data.dart';

class OnboardingSlide extends StatelessWidget {
  final OnboardingSlideData data;

  const OnboardingSlide({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Image.asset(
            data.image,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 26.sp,
                      ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .moveY(begin: 20, end: 0),

                SizedBox(height: 16.h),

                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 15.sp,
                      ),
                ).animate().fadeIn(duration: 500.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
