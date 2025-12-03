// lib/features/camera/infrastructure/native_camera_preview.dart

import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final nativeCameraServiceProvider = Provider<NativeCameraService>((ref) {
  return NativeCameraService();
});

class NativeCameraService {
  CameraController? _controller;

  CameraController? get controller => _controller;

  bool get isInitialized =>
      _controller != null && _controller!.value.isInitialized;

  Future<void> initialize() async {
    if (isInitialized) return;

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      throw Exception('카메라 권한이 거부되었습니다.');
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('사용 가능한 카메라가 없습니다.');
    }

    final selected = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      selected,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
    await _controller!.prepareForVideoRecording();
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }

  Future<Uint8List> captureJpegFrame() async {
    if (!isInitialized) {
      throw Exception('카메라가 초기화되지 않았습니다.');
    }

    final xFile = await _controller!.takePicture();
    return await xFile.readAsBytes();
  }
}

class NativeCameraPreview extends ConsumerWidget {
  const NativeCameraPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(nativeCameraServiceProvider);
    final controller = service.controller;

    if (!service.isInitialized || controller == null) {
      return const Center(
        child: Text('카메라 초기화 중...', style: TextStyle(color: Colors.white)),
      );
    }

    if (!controller.value.isInitialized) {
      return const Center(
        child: Text('카메라 준비 중...', style: TextStyle(color: Colors.white)),
      );
    }

    return CameraPreview(controller);
  }
}
