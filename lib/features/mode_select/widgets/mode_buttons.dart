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

  Future<void> _handleModeSelection(
    BuildContext context,
    WidgetRef ref,
    String mode,
    String deviceType,
    String deviceName,
  ) async {
    try {
      final deviceService = ref.read(deviceApiServiceProvider);
      
      // 기존 디바이스 목록 확인
      final existingDevices = await deviceService.fetchMyDevices();
      
      // 해당 타입의 디바이스가 이미 있는지 확인
      final hasDevice = existingDevices.any(
        (device) => device.deviceType.toUpperCase() == deviceType.toUpperCase(),
      );
      
      // 디바이스가 없으면 등록
      if (!hasDevice) {
        await deviceService.createDevice(
          deviceName: deviceName,
          deviceType: deviceType,
        );
      }
      
      // 모드 설정
      await ref.read(appPrefsProvider.notifier).setMode(mode);
      
      // 화면 이동
      if (context.mounted) {
        if (mode == 'cam') {
          context.go('/camera');
        } else if (mode == 'manager') {
          context.go('/manager');
        }
      }
    } catch (e) {
      // 에러 발생 시에도 모드는 설정하고 이동 (디바이스 등록 실패해도 사용 가능하도록)
      await ref.read(appPrefsProvider.notifier).setMode(mode);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('디바이스 등록 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.orange,
          ),
        );
        
        if (mode == 'cam') {
          context.go('/camera');
        } else if (mode == 'manager') {
          context.go('/manager');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButton(
          text: '캠 모드',
          onPressed: () => _handleModeSelection(
            context,
            ref,
            'cam',
            'CAMERA',
            'My Camera Device',
          ),
        ),

        Gap(22.h),

        AppButton(
          text: '매니저 모드',
          onPressed: () => _handleModeSelection(
            context,
            ref,
            'manager',
            'MONITOR',
            'My Monitor Device',
          ),
        ),
      ],
    );
  }
}
