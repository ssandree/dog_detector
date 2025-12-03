// lib/features/devices/providers/device_bootstrap_provider.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/device_api_service.dart';

final deviceBootstrapProvider = FutureProvider<void>((ref) async {
  final api = ref.read(deviceApiServiceProvider);

  final devices = await api.fetchMyDevices();

  if (devices.isEmpty) {
    throw Exception("등록된 기기가 없습니다.");
  }

  bool isCameraType(String? type) =>
      type != null && type.toLowerCase() == 'camera';

  final camera = devices.firstWhere(
    (d) => isCameraType(d.deviceType),
    orElse: () => throw Exception("CAMERA 타입 기기가 없습니다."),
  );

  final viewer = devices.firstWhere(
    (d) => !isCameraType(d.deviceType),
    orElse: () => throw Exception("VIEWER 타입 기기가 없습니다."),
  );

  ref.read(currentDeviceIdProvider.notifier).set(camera.deviceId.toString());
  ref.read(currentViewerIdProvider.notifier).set(viewer.deviceId.toString());

  print(
    "[BOOTSTRAP] cameraId=${camera.deviceId}, viewerId=${viewer.deviceId}",
  );
});
