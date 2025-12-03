// lib/features/detection/domain/detection_engine.dart

import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/detect_service.dart';
import '../model/detection_result.dart';

final detectionEngineProvider = Provider<DetectionEngine>((ref) {
  final service = ref.read(detectServiceProvider);
  return DetectionEngine(service);
});

class DetectionEngine {
  final DetectService _service;

  DetectionEngine(this._service);

  Future<DetectionResult> detectOnce({
    required Uint8List frameBytes,
    required String cameraId,
  }) {
    return _service.detect(
      frameBytes: frameBytes,
      cameraId: cameraId,
    );
  }
}
