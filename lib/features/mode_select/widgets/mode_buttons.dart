// lib/features/mode_select/widgets/mode_buttons.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/storage/app_prefs_provider.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../devices/data/device_api_service.dart';

class ModeButtons extends ConsumerWidget {
  const ModeButtons({super.key});

  /// 실제 기기 이름을 가져옴 (실패 시 fallback 반환)
  Future<String> _getDeviceName(String fallback) async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        // 예: "Pixel 8", "SM-S918N"
        return android.model ?? fallback;
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        // 예: "홍길동의 iPhone", "iPhone 15 Pro"
        return ios.name ?? fallback;
      }
    } catch (_) {
      // 어떤 이유로든 조회 실패 시 fallback 사용
    }
    return fallback;
  }

  /// 토큰이 준비될 때까지 대기 (로그인 직후 appPrefsProvider 업데이트 대기)
  Future<void> _ensureTokenReady(WidgetRef ref) async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    
    // 최대 3초 동안 토큰이 준비될 때까지 대기
    for (int i = 0; i < 30; i++) {
      // 1. appPrefsProvider에서 토큰 확인
      final prefsValue = ref.read(appPrefsProvider).value;
      if (prefsValue?.accessToken != null && prefsValue!.accessToken!.isNotEmpty) {
        return; // 토큰이 준비됨
      }
      
      // 2. SecureStorage에서 직접 확인
      final token = await secureStorage.readToken();
      if (token != null && token.isNotEmpty) {
        // SecureStorage에 토큰이 있으면 appPrefsProvider에 동기화
        await ref.read(appPrefsProvider.notifier).setAccessToken(token);
        return; // 토큰이 준비됨
      }
      
      // 100ms 대기 후 다시 확인
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // 타임아웃: 토큰이 없어도 계속 진행 (에러는 API 호출 시 발생)
  }

  Future<void> _handleModeSelection(
    BuildContext context,
    WidgetRef ref,
    String mode,
    String deviceType,
    String deviceName,
  ) async {
    try {
      // 토큰이 준비될 때까지 대기 (로그인 직후 동기화 이슈 대응)
      await _ensureTokenReady(ref);
      
      final deviceService = ref.read(deviceApiServiceProvider);
      // deviceName은 이미 실제 기기 이름으로 전달됨

      // 현재 로그인한 기기를 항상 새로 등록
      await deviceService.createDevice(
        deviceName: deviceName,
        deviceType: deviceType,
      );
      
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
          onPressed: () async {
            // 실제 기기 이름을 가져와서 전달
            final deviceName = await _getDeviceName('My Camera Device');
            _handleModeSelection(
              context,
              ref,
              'cam',
              'CAMERA',
              deviceName,
            );
          },
        ),

        Gap(22.h),

        AppButton(
          text: '매니저 모드',
          onPressed: () async {
            // 실제 기기 이름을 가져와서 전달
            final deviceName = await _getDeviceName('My Monitor Device');
            _handleModeSelection(
              context,
              ref,
              'manager',
              'MONITOR',
              deviceName,
            );
          },
        ),
      ],
    );
  }
}
