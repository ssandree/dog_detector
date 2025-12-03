// lib/features/mode_select/widgets/simple_description.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../core/config/app_colors.dart';

class SimpleDescription extends StatelessWidget {
  const SimpleDescription({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.pets,
          size: 84.sp,
          color: AppColors.primary,
        ),

        Gap(26.h),

        Text(
          '포노트',
          style: textTheme.headlineMedium!.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 30.sp,
          ),
        ),

        Gap(14.h),

        Text(
          'AI 기반 강아지 감정 탐지 서비스\n원하는 모드를 선택해주세요.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge!.copyWith(
            color: AppColors.textSecondary,
            fontSize: 15.sp,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
