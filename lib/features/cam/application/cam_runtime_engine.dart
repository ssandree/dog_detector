// lib/features/cam/application/cam_runtime_engine.dart

import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../camera/infrastructure/native_camera_preview.dart';
import '../../detection/domain/detection_engine.dart';
import '../../recording/domain/recording_engine.dart';
import '../../upload/domain/upload_engine.dart';
import '../../upload/model/upload_queue_item.dart';
import '../../../core/network/dio_client.dart';

import 'cam_controller.dart';

final camRuntimeEngineProvider =
    Provider<CamRuntimeEngine>((ref) => CamRuntimeEngine(ref));

class CamRuntimeEngine {
  final Ref ref;
  CamRuntimeEngine(this.ref);

  Timer? _loopTimer;
  bool _detectLoopRunning = false;

  Future<void> start({
    required String cameraId,
    required String petId,
    required String deviceId,
  }) async {
    final cameraService = ref.read(nativeCameraServiceProvider);

    await cameraService.initialize();

    final camController = ref.read(camControllerProvider.notifier);
    camController.setCameraInitialized(true);

    _startDetectLoop(cameraId: cameraId, petId: petId, deviceId: deviceId);
  }

  Future<void> stop({
    required String petId,
    required String deviceId,
  }) async {
    _detectLoopRunning = false;
    _loopTimer?.cancel();
    _loopTimer = null;

    final recording = ref.read(recordingEngineProvider);
    final lastClip = await recording.stopRecording();
    if (lastClip != null) {
      ref.read(uploadEngineProvider).enqueue(
        UploadQueueItem(
          filePath: lastClip.path,
          petId: petId,
          deviceId: deviceId,
          startTime: lastClip.startTime,
          endTime: lastClip.endTime,
        ),
      );
    }

    try {
      final dio = ref.read(apiDioProvider);
      final parsed = int.tryParse(petId);
      if (parsed != null) {
        final now = DateTime.now();
        final date =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        await dio.post('/reports/generate', queryParameters: {
          'pet_id': parsed,
          'target_date': date,
        });
      }
    } catch (_) {}

    await ref.read(nativeCameraServiceProvider).dispose();

    ref.read(camControllerProvider.notifier).reset();
  }

  void _startDetectLoop({
    required String cameraId,
    required String petId,
    required String deviceId,
  }) {
    if (_detectLoopRunning) return;
    _detectLoopRunning = true;

    final detectEngine = ref.read(detectionEngineProvider);
    final camController = ref.read(camControllerProvider.notifier);
    final recording = ref.read(recordingEngineProvider);

    _loopTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!_detectLoopRunning) return;

      try {
        final cameraService = ref.read(nativeCameraServiceProvider);

        final frame = await cameraService.captureJpegFrame();

        final result = await detectEngine.detectOnce(
          frameBytes: frame,
          cameraId: cameraId,
        );

        camController.setDetecting(true);
        camController.setSceneActive(result.isSceneActive);

        if (result.isSceneActive && !recording.isRecording) {
          await recording.startRecording();
        } else if (!result.isSceneActive && recording.isRecording) {
          final clip = await recording.stopRecording();
          if (clip != null) {
            ref.read(uploadEngineProvider).enqueue(
              UploadQueueItem(
                filePath: clip.path,
                petId: petId,
                deviceId: deviceId,
                startTime: clip.startTime,
                endTime: clip.endTime,
              ),
            );
          }
        }
      } catch (e) {
        print('[Runtime] detectLoop 오류: $e');
      }
    });
  }
}
