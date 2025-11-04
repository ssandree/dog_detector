// lib/providers/recording_provider.dart
// 녹화 상태 관리
// 객체 탐지 결과에 따라 녹화 시작/중지 제어

import 'package:camera/camera.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/recording_service.dart';

class RecordingState {
  final bool isRecording;
  final String? filePath;
  final String? error;

  const RecordingState({
    this.isRecording = false,
    this.filePath,
    this.error,
  });

  RecordingState copyWith({
    bool? isRecording,
    String? filePath,
    String? error,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      filePath: filePath ?? this.filePath,
      error: error ?? this.error,
    );
  }
}

class RecordingNotifier extends Notifier<AsyncValue<RecordingState>> {
  RecordingService? _recordingService;

  @override
  AsyncValue<RecordingState> build() {
    return const AsyncValue.data(RecordingState());
  }

  void init(CameraController controller) {
    // RecordingService는 CameraController를 필요로 하므로
    // Factory Provider를 사용하거나 init 시점에 생성
    // Provider로 주입받기 어려운 특수한 케이스이므로 직접 생성
    _recordingService = RecordingService(cameraController: controller);
  }

  Future<void> startRecording() async {
    if (_recordingService == null) {
      state = AsyncValue.data(const RecordingState(
        error: '녹화 서비스가 초기화되지 않았습니다.',
      ));
      return;
    }

    final currentState = state.value;
    if (currentState?.isRecording == true) return;

    state = const AsyncValue.loading();
    try {
      final filePath = await _recordingService!.startRecording();
      state = AsyncValue.data(RecordingState(
        isRecording: true,
        filePath: filePath,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> stopRecording() async {
    if (_recordingService == null) {
      return;
    }

    final currentState = state.value;
    if (currentState?.isRecording != true) return;

    state = const AsyncValue.loading();
    try {
      await _recordingService!.stopRecording();
      state = AsyncValue.data(RecordingState(
        isRecording: false,
        filePath: currentState?.filePath,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final recordingProvider = NotifierProvider<RecordingNotifier, AsyncValue<RecordingState>>(RecordingNotifier.new);
