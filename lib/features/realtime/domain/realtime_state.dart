// lib/features/realtime/domain/realtime_state.dart

import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../realtime_types.dart';
import 'camera_device.dart';
import 'camera_session.dart';

class RealtimeSessionState {
  final bool loading;
  final String? errorMessage;

  final List<CameraDevice> cameras;
  final int selectedIndex;

  final StreamConnectionState connectionState;
  final bool isPaused;
  final bool soundMuted;
  final bool micEnabled;

  final Duration totalUptime;
  final Map<int, Duration> cameraUsage;

  final CameraSession? currentSession;

  const RealtimeSessionState({
    required this.loading,
    required this.errorMessage,
    required this.cameras,
    required this.selectedIndex,
    required this.connectionState,
    required this.isPaused,
    required this.soundMuted,
    required this.micEnabled,
    required this.totalUptime,
    required this.cameraUsage,
    required this.currentSession,
  });

  const RealtimeSessionState.initial()
      : loading = false,
        errorMessage = null,
        cameras = const [],
        selectedIndex = 0,
        connectionState = StreamConnectionState.connecting,
        isPaused = false,
        soundMuted = true,
        micEnabled = false,
        totalUptime = Duration.zero,
        cameraUsage = const {},
        currentSession = null;

  RealtimeSessionState copyWith({
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    List<CameraDevice>? cameras,
    int? selectedIndex,
    StreamConnectionState? connectionState,
    bool? isPaused,
    bool? soundMuted,
    bool? micEnabled,
    Duration? totalUptime,
    Map<int, Duration>? cameraUsage,
    CameraSession? currentSession,
    bool clearSession = false,
  }) {
    return RealtimeSessionState(
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      cameras: cameras ?? this.cameras,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      connectionState: connectionState ?? this.connectionState,
      isPaused: isPaused ?? this.isPaused,
      soundMuted: soundMuted ?? this.soundMuted,
      micEnabled: micEnabled ?? this.micEnabled,
      totalUptime: totalUptime ?? this.totalUptime,
      cameraUsage: cameraUsage ?? this.cameraUsage,
      currentSession: clearSession ? null : (currentSession ?? this.currentSession),
    );
  }

  CameraDevice? get selectedCamera =>
      (cameras.isEmpty || selectedIndex < 0 || selectedIndex >= cameras.length)
          ? null
          : cameras[selectedIndex];

  RTCVideoRenderer? get renderer => currentSession?.renderer;
}
