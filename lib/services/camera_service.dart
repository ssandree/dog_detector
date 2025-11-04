// lib/services/camera_service.dart
// 카메라 제어 서비스
// 카메라 초기화, 전·후면 전환, 플래시 제어, 사진 촬영, 리소스 해제 관리

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../core/exceptions.dart';

class CameraService {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  int _currentIndex = 0;
  FlashMode _flashMode = FlashMode.off;

  CameraController? get controller => _controller;
  FlashMode get flashMode => _flashMode;
  bool get isInitialized => _controller?.value.isInitialized == true;
  bool get isRearCamera =>
      _cameras.isNotEmpty && _cameras[_currentIndex].lensDirection == CameraLensDirection.back;

  // 카메라 초기화
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw DataException('사용 가능한 카메라가 없습니다.');
      }
      _currentIndex = _findRearCamera(_cameras);
      await _createController(_cameras[_currentIndex]);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '카메라 초기화에 실패했습니다: ${e.toString()}',
        e,
      );
    }
  }

  // 후면 카메라 우선 선택
  int _findRearCamera(List<CameraDescription> cameras) {
    final rearIndex =
        cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
    return rearIndex >= 0 ? rearIndex : 0;
  }

  // 카메라 컨트롤러 생성
  Future<void> _createController(CameraDescription description) async {
    try {
      await _controller?.dispose();
      _controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();
      _flashMode = FlashMode.off;
      await _controller!.setFlashMode(_flashMode);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '카메라 컨트롤러 생성에 실패했습니다: ${e.toString()}',
        e,
      );
    }
  }

  // 전·후면 전환
  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;
    try {
      _currentIndex = (_currentIndex + 1) % _cameras.length;
      await _createController(_cameras[_currentIndex]);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '카메라 전환에 실패했습니다: ${e.toString()}',
        e,
      );
    }
  }

  // 플래시 토글
  Future<void> toggleFlash() async {
    if (!isInitialized) {
      throw DataException('카메라가 초기화되지 않았습니다.');
    }
    try {
      if (!isRearCamera) {
        _flashMode = FlashMode.off;
        await _controller!.setFlashMode(_flashMode);
        return;
      }
      _flashMode =
          _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
      await _controller!.setFlashMode(_flashMode);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '플래시 제어에 실패했습니다: ${e.toString()}',
        e,
      );
    }
  }

  // 사진 촬영 후 임시 파일 반환
  Future<File> captureImage() async {
    if (!isInitialized) {
      throw DataException('카메라가 초기화되지 않았습니다.');
    }
    try {
      final file = await _controller!.takePicture();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = p.join(tempDir.path, 'capture_$timestamp.jpg');
      return File(file.path).copy(newPath);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '사진 촬영에 실패했습니다: ${e.toString()}',
        e,
      );
    }
  }

  // 리소스 해제
  Future<void> dispose() async {
    try {
      await _controller?.dispose();
      _controller = null;
    } catch (e) {
      // dispose 실패는 로그만 남기고 예외 던지지 않음
    }
  }
}
