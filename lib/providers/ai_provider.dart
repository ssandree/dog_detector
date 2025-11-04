// lib/providers/ai_provider.dart
// 실시간 감정 분석 상태 관리 Notifier
// WebSocket 연결 상태, 감정 결과(label, prob), 객체 탐지 상태 관리

import 'dart:typed_data';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/ai_service.dart';

class AiState {
  final bool connected;
  final String? label;
  final double? prob;
  final bool dogDetected;
  final String? error;

  const AiState({
    this.connected = false,
    this.label,
    this.prob,
    this.dogDetected = false,
    this.error,
  });

  AiState copyWith({
    bool? connected,
    String? label,
    double? prob,
    bool? dogDetected,
    String? error,
  }) {
    return AiState(
      connected: connected ?? this.connected,
      label: label ?? this.label,
      prob: prob ?? this.prob,
      dogDetected: dogDetected ?? this.dogDetected,
      error: error ?? this.error,
    );
  }
}

class AiNotifier extends Notifier<AsyncValue<AiState>> {
  late final AiService _service;

  @override
  AsyncValue<AiState> build() {
    _service = ref.watch(aiServiceProvider);
    ref.onDispose(() {
      _service.disconnect();
    });
    return const AsyncValue.data(AiState());
  }

  Future<void> connect(String url) async {
    state = const AsyncValue.loading();
    try {
      await _service.connect(url: url);
      state = AsyncValue.data(const AiState(connected: true));

      _service.listenResults().listen((res) {
        final label = res['label'] as String?;
        final prob = (res['prob'] as num?)?.toDouble();
        final dogDetected = res['dogDetected'] == true;

        final currentState = state.value ?? const AiState();
        state = AsyncValue.data(
          currentState.copyWith(
            label: label,
            prob: prob,
            dogDetected: dogDetected,
          ),
        );
      });
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void disconnect() {
    try {
      _service.disconnect();
      state = const AsyncValue.data(AiState(connected: false));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void sendFrame(Uint8List bytes) {
    try {
      _service.sendFrame(bytes);
    } catch (e) {
      // 프레임 전송 실패는 조용히 처리 (에러 상태로 변경하지 않음)
    }
  }
}

// AiService Provider
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

final aiProvider = NotifierProvider<AiNotifier, AsyncValue<AiState>>(AiNotifier.new);
