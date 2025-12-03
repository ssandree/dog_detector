// lib/features/mode_select/widgets/mode_buttons.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/storage/app_prefs_provider.dart';

class ModeButtons extends ConsumerWidget {
  const ModeButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButton(
          text: '캠 모드',
          onPressed: () async {
            await ref.read(appPrefsProvider.notifier).setMode('cam');
            if (context.mounted) context.go('/camera');
          },
        ),

        Gap(22.h),

        AppButton(
          text: '매니저 모드',
          onPressed: () async {
            await ref.read(appPrefsProvider.notifier).setMode('manager');
            if (context.mounted) context.go('/manager');
          },
        ),
      ],
    );
  }
}
