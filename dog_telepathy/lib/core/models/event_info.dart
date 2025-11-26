enum AnalysisStatus {
  pending('PENDING'),
  completed('COMPLETED'),
  failed('FAILED');

  final String value;
  const AnalysisStatus(this.value);

  static AnalysisStatus fromString(String? value) {
    if (value == null) return AnalysisStatus.pending;
    return AnalysisStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AnalysisStatus.pending,
    );
  }
}

class EventInfo {
  final int eventId;
  final int petId;
  final int deviceId;
  final DateTime startTime;
  final DateTime endTime;
  final int videoDurationSec;
  final String videoUrl;
  final String? thumbnailUrl;
  final AnalysisStatus analysisStatus;
  final String? detectedFeatures;
  final String? finalEmotion;
  final String? patellaAnalysisResult;

  EventInfo({
    required this.eventId,
    required this.petId,
    required this.deviceId,
    required this.startTime,
    required this.endTime,
    required this.videoDurationSec,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.analysisStatus,
    this.detectedFeatures,
    this.finalEmotion,
    this.patellaAnalysisResult,
  });

  factory EventInfo.fromJson(Map<String, dynamic> json) {
    return EventInfo(
      eventId: json['event_id'],
      petId: json['pet_id'],
      deviceId: json['device_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      videoDurationSec: json['video_duration_sec'],
      videoUrl: json['video_url'],
      thumbnailUrl: json['thumbnail_url'],
      analysisStatus: AnalysisStatus.fromString(json['analysis_status']),
      detectedFeatures: json['detected_features'],
      finalEmotion: json['final_emotion'],
      patellaAnalysisResult: json['patella_analysis_result'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'pet_id': petId,
      'device_id': deviceId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'video_duration_sec': videoDurationSec,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'analysis_status': analysisStatus.value,
      'detected_features': detectedFeatures,
      'final_emotion': finalEmotion,
      'patella_analysis_result': patellaAnalysisResult,
    };
  }
}
