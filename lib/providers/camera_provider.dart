// lib/providers/camera_provider.dart
// 카메라 상태 관리 Notifier
// 카메라 초기화, 촬영, 전환, 플래시 제어, 상태 관리
// 객체 감지(dogDetected) 기반 녹화 트리거 연동

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/camera_service.dart';
import '../utils/permission_util.dart';
import 'ai_provider.dart';
import 'recording_provider.dart';

enum CameraStatus { idle, initializing, ready, capturing, error }

class CameraState {
  final CameraStatus status;
  final String? error;
  final File? lastCapture;
  final CameraController? controller;
  final bool isInitialized;

  const CameraState({
    this.status = CameraStatus.idle,
    this.error,
    this.lastCapture,
    this.controller,
    this.isInitialized = false,
  });

  CameraState copyWith({
    CameraStatus? status,
    String? error,
    File? lastCapture,
    CameraController? controller,
    bool? isInitialized,
  }) {
    return CameraState(
      status: status ?? this.status,
      error: error ?? this.error,
      lastCapture: lastCapture ?? this.lastCapture,
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  bool get isReady => controller != null && isInitialized;
}

class CameraNotifier extends Notifier<AsyncValue<CameraState>> {
  late final CameraService _service;

  @override
  AsyncValue<CameraState> build() {
    _service = ref.watch(cameraServiceProvider);
    ref.onDispose(() {
      _service.dispose();
    });

    // AI 객체 탐지 결과(dogDetected) 구독 → 녹화 트리거 제어
    ref.listen(aiProvider, (prev, next) {
      final aiState = next.value;
      final prevAiState = prev?.value;
      
      if (aiState?.dogDetected == true && prevAiState?.dogDetected != true) {
        final cameraState = state.value;
        if (cameraState?.controller != null && cameraState?.isReady == true) {
          final recording = ref.read(recordingProvider.notifier);
          recording.init(cameraState!.controller!);
          recording.startRecording();
        }
      } else if (aiState?.dogDetected == false && prevAiState?.dogDetected == true) {
        final recording = ref.read(recordingProvider.notifier);
        recording.stopRecording();
      }
    });

    return const AsyncValue.data(CameraState());
  }

  Future<void> initialize() async {
    state = const AsyncValue.loading();
    try {
      final ok = await PermissionUtil.ensureAllForCapture();
      if (!ok) {
        state = AsyncValue.data(const CameraState(
          status: CameraStatus.error,
          error: '카메라 또는 저장소 권한이 필요합니다.',
        ));
        return;
      }
      await _service.initialize();
      state = AsyncValue.data(CameraState(
        status: CameraStatus.ready,
        controller: _service.controller,
        isInitialized: _service.isInitialized,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> switchCamera() async {
    try {
      await _service.switchCamera();
      final currentState = state.value ?? const CameraState();
      state = AsyncValue.data(currentState.copyWith(
        controller: _service.controller,
        isInitialized: _service.isInitialized,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleFlash() async {
    try {
      await _service.toggleFlash();
      final currentState = state.value ?? const CameraState();
      state = AsyncValue.data(currentState.copyWith());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<File?> capture() async {
    final currentState = state.value;
    if (currentState?.status != CameraStatus.ready) return null;
    
    state = AsyncValue.data(currentState!.copyWith(status: CameraStatus.capturing));
    try {
      final file = await _service.captureImage();
      state = AsyncValue.data(currentState.copyWith(
        status: CameraStatus.ready,
        lastCapture: file,
      ));
      return file;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  void disposeCamera() {
    try {
      _service.dispose();
    } catch (e) {
      // dispose 실패는 조용히 처리
    }
  }
}

// CameraService Provider
final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

final cameraProvider = NotifierProvider<CameraNotifier, AsyncValue<CameraState>>(CameraNotifier.new);
