// lib/core/services/record_service.dart
// 조건부 녹화 제어 로직
// - CameraService 재사용
// - 녹화 시작/중단 및 파일 반환

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'camera_service.dart';
import 'upload_service.dart';

class RecordService {
  RecordService._internal();
  static final RecordService instance = RecordService._internal();

  final Logger _log = Logger();

  // 녹화 시작
  Future<void> startRecording(int index) async {
    try {
      await CameraService.instance.startRecording(index);
      _log.i('Recording started on camera $index');
    } catch (e, s) {
      _log.e('Recording start failed', error: e, stackTrace: s);
    }
  }

  // 녹화 중단 및 파일 처리
  Future<void> stopRecording(int index) async {
    try {
      final XFile? file = await CameraService.instance.stopRecording(index);
      if (file == null) {
        _log.w('No video file returned from camera $index');
        return;
      }

      final dir = await getTemporaryDirectory();
      final renamed = File(
        '${dir.path}/cam_${index}_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      await File(file.path).copy(renamed.path);
      _log.i('Recording stopped on camera $index: ${renamed.path}');

      await UploadService.instance.handleUpload(renamed);
    } catch (e, s) {
      _log.e('Recording stop failed', error: e, stackTrace: s);
    }
  }
}
