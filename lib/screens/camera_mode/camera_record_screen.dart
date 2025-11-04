// lib/screens/camera_mode/camera_record_screen.dart
// 녹화 제어 화면
// - 녹화 시작/중단 버튼 UI
// - RecordService 및 RecordStateProvider 연동
// - 녹화 상태 실시간 표시

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/providers/record_provider.dart';
import '../../core/services/record_service.dart';

class CameraRecordScreen extends HookConsumerWidget {
  const CameraRecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecording = ref.watch(recordStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Camera Record')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isRecording ? '녹화 중...' : '대기 중',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isRecording
                  ? () async {
                      await RecordService.instance.stopRecording(0);
                      ref.read(recordStateProvider.notifier).stop();
                    }
                  : () async {
                      await RecordService.instance.startRecording(0);
                      ref.read(recordStateProvider.notifier).start();
                    },
              child: Text(isRecording ? '녹화 중지' : '녹화 시작'),
            ),
          ],
        ),
      ),
    );
  }
}
