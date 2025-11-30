// lib/features/cam/widgets/cam_preview.dart

import 'package:flutter/material.dart';
import '../../camera/infrastructure/native_camera_preview.dart';

class CamPreview extends StatelessWidget {
  const CamPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const NativeCameraPreview();
  }
}
