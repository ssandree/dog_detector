// lib/features/devices/model/device_info.dart

class DeviceInfo {
  final int deviceId;
  final int userId;
  final String deviceName;
  final String deviceType;
  final String status;
  final String connectionStatus;

  DeviceInfo({
    required this.deviceId,
    required this.userId,
    required this.deviceName,
    required this.deviceType,
    required this.status,
    required this.connectionStatus,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['device_id'] as int,
      userId: json['user_id'] as int,
      deviceName: json['device_name'] as String,
      deviceType: json['device_type'] as String,
      status: json['status'] as String? ?? '',
      connectionStatus: json['connection_status'] as String? ?? '',
    );
  }
}
