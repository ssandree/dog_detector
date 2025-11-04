// lib/screens/manager_mode/manager_home_screen.dart
// 매니저 모드 홈 화면
// - 촬영 영상 조회, 분석 리포트, 설정 관리로 진입하는 시작점
// - modeProvider의 현재 상태를 표시하여 모드 확인 가능

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/providers/app_provider.dart';

class ManagerHomeScreen extends ConsumerWidget {
  const ManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(modeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manager Home')),
      body: Center(
        child: Text(
          '현재 모드: ${mode ?? 'null'}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
