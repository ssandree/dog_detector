// lib/features/mode_select/widgets/mode_buttons.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/storage/app_prefs_provider.dart';

class ModeButtons extends ConsumerWidget {
  const ModeButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppButton.normal(
          text: '캠 모드',
          subtitle: '반려동물의 실시간 감정을 기록합니다',
          icon: Icons.videocam,
          fontSize: 20,
          height: 100,
          backgroundColor: AppColors.coral1,
          width: MediaQuery.of(context).size.width * 0.8,
          onPressed: () async {
            await ref.read(appPrefsProvider.notifier).setMode('cam');
            if (context.mounted) context.go('/camera');
          },
        ),

        Gap(22.h),

        AppButton.normal(
          text: '매니저 모드',
          subtitle: '반려동물의 데이터를 관리하고 분석합니다',
          icon: Icons.bar_chart,
          fontSize: 20,
          height: 100,
          backgroundColor: AppColors.coral2,
          width: MediaQuery.of(context).size.width * 0.8,
          onPressed: () async {
            await ref.read(appPrefsProvider.notifier).setMode('manager');
            if (context.mounted) context.go('/manager');
          },
        ),
      ],
    );
  }
}
