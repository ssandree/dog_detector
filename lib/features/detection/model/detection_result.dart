// lib/features/detection/model/detection_result.dart

class DetectionResult {
  final String cameraId;
  final double confidence;

  const DetectionResult({
    required this.cameraId,
    required this.confidence,
  });

  bool get isSceneActive => confidence >= 0.5;

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      cameraId: json['camera_id'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}
