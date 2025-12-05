// lib/features/mode_select/widgets/mode_buttons.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/storage/app_prefs_provider.dart';
import '../../devices/data/device_api_service.dart';

class ModeButtons extends ConsumerWidget {
  const ModeButtons({super.key});

  Future<void> _ensureDevice(
    WidgetRef ref,
    String type,
  ) async {
    final api = ref.read(deviceApiServiceProvider);

    final list = await api.fetchMyDevices();

    // 이름 하드코딩
    final name = type.toUpperCase() == 'CAMERA'
        ? 'My Camera Device'
        : 'My Monitor Device';

    // 동일 기기가 이미 있으면 skip
    final exists = list.any((d) =>
        d.deviceName.toLowerCase().trim() == name.toLowerCase().trim() &&
        d.deviceType.toUpperCase().trim() == type.toUpperCase().trim());

    if (!exists) {
      await api.createDevice(deviceType: type);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButton(
          text: '캠 모드',
          onPressed: () async {
            await _ensureDevice(ref, 'CAMERA');   // ⭐ 자동 등록
            await ref.read(appPrefsProvider.notifier).setMode('cam');
            if (context.mounted) context.go('/camera');
          },
        ),

        Gap(22.h),

        AppButton(
          text: '매니저 모드',
          onPressed: () async {
            await _ensureDevice(ref, 'MONITOR');  // ⭐ 자동 등록
            await ref.read(appPrefsProvider.notifier).setMode('manager');
            if (context.mounted) context.go('/manager');
          },
        ),
      ],
    );
  }
}
