// lib/core/providers/record_provider.dart
// 녹화 상태 관리 Provider
// - 현재 녹화 중 여부 저장
// - UI에서 녹화 상태 표시 및 제어에 사용

import 'package:hooks_riverpod/hooks_riverpod.dart';

class RecordStateNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  // 녹화 시작
  void start() => state = true;

  // 녹화 중단
  void stop() => state = false;
}

// 녹화 상태 Provider
final recordStateProvider =
    NotifierProvider<RecordStateNotifier, bool>(RecordStateNotifier.new);
