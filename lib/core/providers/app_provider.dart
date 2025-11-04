// lib/core/providers/app_provider.dart
// 전역 상태 관리 Provider 정의
// - 현재 선택된 모드(camera/manager) 상태를 저장
// - Riverpod 3.x Notifier 기반으로 구현

import 'package:hooks_riverpod/hooks_riverpod.dart';

class ModeNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setMode(String mode) => state = mode;
}

final modeProvider = NotifierProvider<ModeNotifier, String?>(ModeNotifier.new);
