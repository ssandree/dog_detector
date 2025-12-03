// lib/features/upload/model/upload_queue_item.dart

class UploadQueueItem {
  final String filePath;
  final String petId;
  final String deviceId;
  final DateTime startTime;
  final DateTime endTime;
  final double durationSeconds;

  UploadQueueItem({
    required this.filePath,
    required this.petId,
    required this.deviceId,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
  });
}
