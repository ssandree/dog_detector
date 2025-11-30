// lib/features/recording/domain/recording_engine.dart

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../camera/infrastructure/native_camera_preview.dart';

final recordingEngineProvider = Provider<RecordingEngine>((ref) {
  final cameraService = ref.read(nativeCameraServiceProvider);
  return RecordingEngine(cameraService);
});

class RecordingResult {
  final String path;
  final DateTime startTime;
  final DateTime endTime;

  RecordingResult({
    required this.path,
    required this.startTime,
    required this.endTime,
  });
}

class RecordingEngine {
  final NativeCameraService _cameraService;

  RecordingEngine(this._cameraService);

  CameraController? get _controller => _cameraService.controller;

  bool _recording = false;
  String? _currentPath;
  DateTime? _startTime;

  bool get isRecording => _recording;

  Future<String> _generateFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final clipsDir = Directory('${dir.path}/clips');

    if (!clipsDir.existsSync()) {
      clipsDir.createSync(recursive: true);
    }

    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('.', '');

    return '${clipsDir.path}/clip_$ts.mp4';
  }

  Future<void> startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('카메라가 초기화되지 않았습니다.');
    }
    if (_recording) return;

    final path = await _generateFilePath();
    _currentPath = path;
    _startTime = DateTime.now();

    await _controller!.startVideoRecording();
    _recording = true;

    print('[RecordingEngine] 녹화 시작: $path');
  }
  
  Future<RecordingResult?> stopRecording() async {
    if (!_recording) return null;
    if (_controller == null) return null;

    try {
      final endTime = DateTime.now();
      final xfile = await _controller!.stopVideoRecording();
      _recording = false;

      if (_currentPath == null || _startTime == null) return null;

      final saved = File(_currentPath!);
      await saved.writeAsBytes(await xfile.readAsBytes());

      print('[RecordingEngine] 녹화 종료 → 파일 저장: $_currentPath');

      final result = RecordingResult(
        path: _currentPath!,
        startTime: _startTime!,
        endTime: endTime,
      );

      _currentPath = null;
      _startTime = null;

      return result;
    } catch (e) {
      print('[RecordingEngine] 녹화 종료 실패: $e');
      _recording = false;
      return null;
    }
  }
}
