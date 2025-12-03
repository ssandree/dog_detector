// lib/features/detection/presentation/detection_controller.dart

import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/detection_engine.dart';

enum DetectionStatus {
  idle,
  running,
  error,
}

class DetectionState {
  final DetectionStatus status;
  final String? errorMessage;
  final double? lastConfidence;
  final bool sceneActive;

  const DetectionState({
    required this.status,
    this.errorMessage,
    this.lastConfidence,
    this.sceneActive = false,
  });

  const DetectionState.idle()
      : status = DetectionStatus.idle,
        errorMessage = null,
        lastConfidence = null,
        sceneActive = false;

  DetectionState copyWith({
    DetectionStatus? status,
    String? errorMessage,
    double? lastConfidence,
    bool? sceneActive,
  }) {
    return DetectionState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      lastConfidence: lastConfidence ?? this.lastConfidence,
      sceneActive: sceneActive ?? this.sceneActive,
    );
  }
}

class DetectionController extends AsyncNotifier<DetectionState> {
  late final DetectionEngine _engine;

  @override
  DetectionState build() {
    _engine = ref.read(detectionEngineProvider);
    return const DetectionState.idle();
  }

  Future<void> detectOnce({
    required Uint8List frameBytes,
    required String cameraId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final result = await _engine.detectOnce(
        frameBytes: frameBytes,
        cameraId: cameraId,
      );

      final newState = DetectionState(
        status: DetectionStatus.running,
        lastConfidence: result.confidence,
        sceneActive: result.isSceneActive,
        errorMessage: null,
      );

      state = AsyncValue.data(newState);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(DetectionState.idle());
  }
}

final detectionControllerProvider =
    AsyncNotifierProvider<DetectionController, DetectionState>(
  DetectionController.new,
);
