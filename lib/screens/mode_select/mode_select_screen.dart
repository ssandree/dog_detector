// lib/screens/mode_select/mode_select_screen.dart
// 모드 선택 화면
// - 캠 모드(camera) 또는 매니저 모드(manager) 중 하나를 선택
// - 선택한 모드를 modeProvider에 저장 후 해당 화면으로 이동

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/config/app_routes.dart';
import '../../core/providers/app_provider.dart';

class ModeSelectScreen extends ConsumerWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mode Select')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ElevatedButton(
            onPressed: () {
              ref.read(modeProvider.notifier).setMode('camera');
              Navigator.pushNamed(context, AppRoutes.cameraHome);
              debugPrint('Navigated to: ${AppRoutes.cameraHome}');
            },
            child: const Text('캠 모드(촬영)로 이동'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ref.read(modeProvider.notifier).setMode('manager');
              Navigator.pushNamed(context, AppRoutes.managerHome);
              debugPrint('Navigated to: ${AppRoutes.managerHome}');
            },
            child: const Text('매니저 모드(시청/리포트)로 이동'),
          ),
        ]),
      ),
    );
  }
}
