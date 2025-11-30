// lib/features/realtime/application/realtime_session_controller.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/realtime_state.dart';
import '../domain/camera_device.dart';
import '../realtime_types.dart';
import '../infrastructure/webrtc_repository.dart';

final realtimeSessionControllerProvider =
    NotifierProvider<RealtimeSessionController, RealtimeSessionState>(
  RealtimeSessionController.new,
);

class RealtimeSessionController extends Notifier<RealtimeSessionState> {
  late final WebRtcRepository _repo;

  @override
  RealtimeSessionState build() {
    _repo = ref.read(webrtcRepositoryProvider);
    return const RealtimeSessionState.initial();
  }

  Future<void> init({required String viewerDeviceId}) async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      final devices = await _repo.fetchUserDevices();
      final cams =
          devices.where((d) => d.type == DeviceType.camera).toList();

      state = state.copyWith(
        cameras: cams,
        selectedIndex: 0,
        loading: false,
      );

      if (cams.isNotEmpty) {
        await connectSelectedCamera(viewerDeviceId: viewerDeviceId);
      }
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: '디바이스 목록 불러오기 실패: $e',
        connectionState: StreamConnectionState.failed,
      );
    }
  }

  Future<void> connectSelectedCamera({
    required String viewerDeviceId,
  }) async {
    final cam = state.selectedCamera;
    if (cam == null) return;

    state = state.copyWith(
      loading: true,
      connectionState: StreamConnectionState.connecting,
      clearError: true,
    );

    try {
      final renderer = await _repo.viewerStart(
        camId: cam.deviceId.toString(),
        viewerId: viewerDeviceId,
      );

      state = state.copyWith(
        currentSession: state.currentSession?.copyWith(renderer: renderer) ??
            state.currentSession,
        connectionState: StreamConnectionState.connected,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: '연결 실패: $e',
        connectionState: StreamConnectionState.failed,
        clearSession: true,
      );
    }
  }

  Future<void> switchCamera(bool next, String viewerDeviceId) async {
    if (state.cameras.length <= 1) return;

    final newIndex = next
        ? (state.selectedIndex + 1) % state.cameras.length
        : (state.selectedIndex - 1 + state.cameras.length) %
            state.cameras.length;

    state = state.copyWith(
      selectedIndex: newIndex,
      connectionState: StreamConnectionState.reconnecting,
      clearError: true,
    );

    await _repo.viewerStop();
    await connectSelectedCamera(viewerDeviceId: viewerDeviceId);
  }

  Future<void> reconnect(String viewerDeviceId) async {
    await _repo.viewerStop();
    await connectSelectedCamera(viewerDeviceId: viewerDeviceId);
  }

  Future<void> disconnect() async {
    await _repo.viewerStop();
    state = state.copyWith(
      connectionState: StreamConnectionState.failed,
      clearSession: true,
    );
  }
}
