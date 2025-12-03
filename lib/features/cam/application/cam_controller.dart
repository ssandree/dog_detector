// lib/features/cam/application/cam_controller.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'cam_state.dart';

class CamController extends AsyncNotifier<CamState> {
  @override
  Future<CamState> build() async {
    return const CamState.initial();
  }

  CamState _current() => state.value ?? const CamState.initial();

  void reset() {
    state = const AsyncValue.data(CamState.initial());
  }

  void setCameraInitialized(bool value) {
    final prev = _current();
    state = AsyncValue.data(
      prev.copyWith(cameraInitialized: value),
    );
  }

  void setDetecting(bool value) {
    final prev = _current();
    state = AsyncValue.data(
      prev.copyWith(detecting: value),
    );
  }

  void setSceneActive(bool value) {
    final prev = _current();
    state = AsyncValue.data(
      prev.copyWith(sceneActive: value),
    );
  }
}

final camControllerProvider =
    AsyncNotifierProvider<CamController, CamState>(CamController.new);
