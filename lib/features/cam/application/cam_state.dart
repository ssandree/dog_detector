//lib/features/cam/application/cam_state.dart

class CamState {
  final bool cameraInitialized;
  final bool detecting;
  final bool sceneActive;

  const CamState({
    required this.cameraInitialized,
    required this.detecting,
    required this.sceneActive,
  });

  const CamState.initial()
      : cameraInitialized = false,
        detecting = false,
        sceneActive = false;

  CamState copyWith({
    bool? cameraInitialized,
    bool? detecting,
    bool? sceneActive,
  }) {
    return CamState(
      cameraInitialized: cameraInitialized ?? this.cameraInitialized,
      detecting: detecting ?? this.detecting,
      sceneActive: sceneActive ?? this.sceneActive,
    );
  }
}
