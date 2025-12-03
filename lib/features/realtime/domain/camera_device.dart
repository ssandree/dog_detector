// lib/features/realtime/domain/camera_device.dart

enum DeviceType {
  camera,
  monitor,
  unknown,
}

DeviceType deviceTypeFromString(String raw) {
  switch (raw.toUpperCase()) {
    case 'CAMERA':
      return DeviceType.camera;
    case 'MONITOR':
      return DeviceType.monitor;
    default:
      return DeviceType.unknown;
  }
}

class CameraDevice {
  final int deviceId;
  final String name;
  final DeviceType type;
  final String status;
  final String connectionStatus;

  const CameraDevice({
    required this.deviceId,
    required this.name,
    required this.type,
    required this.status,
    required this.connectionStatus,
  });

  factory CameraDevice.fromJson(Map<String, dynamic> json) {
    return CameraDevice(
      deviceId: json['device_id'] as int,
      name: json['device_name'] as String? ?? 'CAM-${json['device_id']}',
      type: deviceTypeFromString(json['device_type'] as String? ?? ''),
      status: json['status'] as String? ?? '',
      connectionStatus: json['connection_status'] as String? ?? '',
    );
  }
}
