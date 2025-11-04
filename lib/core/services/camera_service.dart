// lib/core/services/camera_service.dart
// 카메라 제어 및 녹화 관리 서비스
// - 최대 3대 카메라 초기화 및 제어
// - 프리뷰 녹화 중단 해제 기능 제공
// - Singleton 패턴으로 전역 접근 가능

import 'package:camera/camera.dart';
import 'package:logger/logger.dart';

class CameraService {
  CameraService._internal();
  static final CameraService instance = CameraService._internal();

  final Logger _log = Logger();
  final List<CameraController> controllers = [];

  // 카메라 초기화(최대 3대)
  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      controllers.clear();

      for (final cam in cameras.take(3)) {
        final controller = CameraController(
          cam,
          ResolutionPreset.medium,
          enableAudio: true,
        );
        await controller.initialize();
        controllers.add(controller);
      }

      _log.i('Camera initialized: ${controllers.length}');
    } catch (e, s) {
      _log.e('Camera initialization failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  // 녹화 시작
  Future<void> startRecording(int index) async {
    if (index < 0 || index >= controllers.length) return;
    final c = controllers[index];
    if (!c.value.isInitialized || c.value.isRecordingVideo) return;

    await c.startVideoRecording();
    _log.i('Recording started on camera $index');
  }

  // 녹화 중단 후 파일 반환
  Future<XFile?> stopRecording(int index) async {
    if (index < 0 || index >= controllers.length) return null;
    final c = controllers[index];
    if (!c.value.isInitialized || !c.value.isRecordingVideo) return null;

    final file = await c.stopVideoRecording();
    _log.i('Recording stopped on camera $index → ${file.path}');
    return file;
  }

  // 전체 카메라 해제
  Future<void> dispose() async {
    for (final c in controllers) {
      await c.dispose();
    }
    controllers.clear();
    _log.i('All cameras disposed');
  }
}
