// lib/core/providers/camera_provider.dart
// 카메라 상태 관리 Provider 정의
// - CameraService 초기화 및 연결 상태 관리
// - 카메라 준비 상태를 Notifier 기반으로 관리
// - 카메라 컨트롤러 리스트 전역 공유

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';

// 카메라 준비 상태 Notifier
class CameraReadyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setReady(bool value) => state = value;
}

// 카메라 준비 상태 Provider
final cameraReadyProvider =
    NotifierProvider<CameraReadyNotifier, bool>(CameraReadyNotifier.new);

// 카메라 초기화(비동기)
final cameraInitProvider = FutureProvider<void>((ref) async {
  // 이미 초기화된 컨트롤러가 있다면 재실행 방지
  if (CameraService.instance.controllers.isNotEmpty) return;
  await CameraService.instance.initialize();
  ref.read(cameraReadyProvider.notifier).setReady(true);
});

// 카메라 컨트롤러 리스트 공유 Provider
final cameraControllersProvider = Provider<List<CameraController>>((ref) {
  return CameraService.instance.controllers;
});
