// lib/features/cam/application/cam_controller.dart

import 'dart:async';
import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../camera/infrastructure/native_camera_preview.dart';
import '../../detection/domain/detection_engine.dart';
import '../../detection/model/detection_result.dart';
import '../../recording/domain/recording_engine.dart';
import '../../upload/domain/upload_engine.dart';
import '../../upload/model/upload_queue_item.dart';

class CamState {
  final bool cameraInitialized;
  final bool detecting;
  final bool isRunning;
  final double? lastConfidence;
  final bool sceneActive;
  final String? errorMessage;

  const CamState({
    required this.cameraInitialized,
    required this.detecting,
    required this.isRunning,
    this.lastConfidence,
    this.sceneActive = false,
    this.errorMessage,
  });

  const CamState.initial()
      : cameraInitialized = false,
        detecting = false,
        isRunning = false,
        lastConfidence = null,
        sceneActive = false,
        errorMessage = null;

  CamState copyWith({
    bool? cameraInitialized,
    bool? detecting,
    bool? isRunning,
    double? lastConfidence,
    bool? sceneActive,
    String? errorMessage,
  }) {
    return CamState(
      cameraInitialized: cameraInitialized ?? this.cameraInitialized,
      detecting: detecting ?? this.detecting,
      isRunning: isRunning ?? this.isRunning,
      lastConfidence: lastConfidence ?? this.lastConfidence,
      sceneActive: sceneActive ?? this.sceneActive,
      errorMessage: errorMessage,
    );
  }
}

class CamController extends AsyncNotifier<CamState> {
  late final NativeCameraService _cameraService;
  late final DetectionEngine _detectionEngine;
  late final RecordingEngine _recordingEngine;
  late final UploadEngine _uploadEngine;

  Timer? _loopTimer;
  bool _previousScene = false;
  bool _recording = false;

  @override
  CamState build() {
    _cameraService = ref.read(nativeCameraServiceProvider);
    _detectionEngine = ref.read(detectionEngineProvider);
    _recordingEngine = ref.read(recordingEngineProvider);
    _uploadEngine = ref.read(uploadEngineProvider);

    return const CamState.initial();
  }

  Future<void> startCam() async {
    final current = state.value ?? const CamState.initial();

    if (current.cameraInitialized) {
      _startAutoLoop();
      state = AsyncValue.data(
        current.copyWith(
          isRunning: true,
          errorMessage: null,
        ),
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      await _cameraService.initialize();

      final newState = const CamState.initial().copyWith(
        cameraInitialized: true,
        isRunning: true,
        errorMessage: null,
      );

      state = AsyncValue.data(newState);

      _startAutoLoop();
    } catch (e) {
      state = AsyncValue.data(
        current.copyWith(
          isRunning: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> stopCam() async {
    _loopTimer?.cancel();
    _loopTimer = null;

    try {
      await _cameraService.dispose();
    } catch (_) {}

    _recording = false;
    _previousScene = false;

    state = const AsyncValue.data(CamState.initial());
  }

  void _startAutoLoop() {
    _loopTimer?.cancel();
    _loopTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      captureAndDetect();
    });
  }

  Future<void> captureAndDetect({String cameraId = 'camera_1'}) async {
    final current = state.value ?? const CamState.initial();

    if (!current.cameraInitialized || !current.isRunning) {
      return;
    }

    if (current.detecting) {
      return;
    }

    state = AsyncValue.data(
      current.copyWith(
        detecting: true,
        errorMessage: null,
      ),
    );

    try {
      final Uint8List frameBytes =
          await _cameraService.captureJpegFrame();

      final DetectionResult result =
          await _detectionEngine.detectOnce(
        frameBytes: frameBytes,
        cameraId: cameraId,
      );

      final updated = current.copyWith(
        detecting: false,
        lastConfidence: result.confidence,
        sceneActive: result.isSceneActive,
        errorMessage: null,
      );

      state = AsyncValue.data(updated);

      await _processSceneChange(result.isSceneActive);
    } catch (e) {
      final failed = current.copyWith(
        detecting: false,
        errorMessage: e.toString(),
      );
      state = AsyncValue.data(failed);
    }
  }

  Future<void> _processSceneChange(bool newScene) async {
    if (_previousScene == newScene) {
      return;
    }

    if (newScene == true) {
      _handleSceneOn();
    } else {
      await _handleSceneOff();
    }

    _previousScene = newScene;
  }

  void _handleSceneOn() {
    if (_recording) return;

    _recording = true;
    _recordingEngine.startRecording();
  }

  Future<void> _handleSceneOff() async {
    if (!_recording) return;

    _recording = false;

    final result = await _recordingEngine.stopRecording();
    if (result == null) {
      return;
    }

    const petId = 'pet_1';
    const deviceId = 'device_1';

    final item = UploadQueueItem(
      filePath: result.path,
      petId: petId,
      deviceId: deviceId,
      startTime: result.startTime,
      endTime: result.endTime,
    );

    _uploadEngine.enqueue(item);
  }
}

final camControllerProvider =
    AsyncNotifierProvider<CamController, CamState>(
  CamController.new,
);
