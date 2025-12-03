// lib/features/cam/widgets/cam_preview.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../application/cam_controller.dart';
import '../application/cam_state.dart';
import '../../camera/infrastructure/native_camera_preview.dart';

class CamPreview extends ConsumerWidget {
  const CamPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camAsync = ref.watch(camControllerProvider);
    final CamState camState = camAsync.value ?? const CamState.initial();

    if (camAsync.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (!camState.cameraInitialized) {
      return const Center(
        child: Text(
          'CAM 시작 버튼을 눌러주세요',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return const NativeCameraPreview();
  }
}
