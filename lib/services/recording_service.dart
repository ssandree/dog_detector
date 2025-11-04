// lib/services/recording_service.dart
// 카메라 녹화 제어 서비스
// CameraController로 녹화 시작/중지 수행, 파일 경로 지정 및 저장

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../core/exceptions.dart';

class RecordingService {
  final CameraController cameraController;

  RecordingService({required this.cameraController});

  Future<String> startRecording() async {
    if (cameraController.value.isRecordingVideo) {
      throw ValidationException('이미 녹화 중입니다.');
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await cameraController.startVideoRecording();
      return path;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '녹화 시작에 실패했습니다: ${e.toString()}',
        e,
      );
    }
  }

  Future<XFile?> stopRecording() async {
    if (!cameraController.value.isRecordingVideo) {
      throw ValidationException('녹화 중이 아닙니다.');
    }
    try {
      return await cameraController.stopVideoRecording();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '녹화 중지에 실패했습니다: ${e.toString()}',
        e,
      );
    }
  }

  Future<String> getRecordingPath() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.mp4';
    } on AppException {
      rethrow;
    } catch (e) {
      throw DataException(
        '녹화 경로 생성에 실패했습니다: ${e.toString()}',
        e,
      );
    }
  }
}
