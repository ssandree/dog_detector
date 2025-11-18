/// 이벤트 분석 상태
enum AnalysisStatus {
  pending('PENDING'),
  completed('COMPLETED'),
  failed('FAILED');

  final String value;
  const AnalysisStatus(this.value);

  static AnalysisStatus? fromString(String? value) {
    if (value == null) return null;
    return AnalysisStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AnalysisStatus.pending,
    );
  }
}

/// 강아지 감정 탐지 이벤트 정보
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
  });

  /// JSON 역직렬화 (API 응답)
  factory EventInfo.fromJson(Map<String, dynamic> json) {
    return EventInfo(
      eventId: json['event_id'] as int,
      petId: json['pet_id'] as int,
      deviceId: json['device_id'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      videoDurationSec: json['video_duration_sec'] as int,
      videoUrl: json['video_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      analysisStatus: AnalysisStatus.fromString(json['analysis_status'] as String?) ?? AnalysisStatus.pending,
      detectedFeatures: json['detected_features'] as String?,
      finalEmotion: json['final_emotion'] as String?,
    );
  }

  /// JSON 직렬화 (로컬 저장용)
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
    };
  }

  /// 영상 길이를 포맷된 문자열로 변환 (예: "01:30")
  String get formattedDuration {
    final minutes = videoDurationSec ~/ 60;
    final seconds = videoDurationSec % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 분석 완료 여부
  bool get isAnalysisCompleted => analysisStatus == AnalysisStatus.completed;

  @override
  String toString() {
    return 'EventInfo(eventId: $eventId, petId: $petId, startTime: $startTime, analysisStatus: $analysisStatus, finalEmotion: $finalEmotion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventInfo &&
        other.eventId == eventId &&
        other.petId == petId &&
        other.deviceId == deviceId &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.videoDurationSec == videoDurationSec &&
        other.videoUrl == videoUrl &&
        other.thumbnailUrl == thumbnailUrl &&
        other.analysisStatus == analysisStatus &&
        other.detectedFeatures == detectedFeatures &&
        other.finalEmotion == finalEmotion;
  }

  @override
  int get hashCode {
    return eventId.hashCode ^
        petId.hashCode ^
        deviceId.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        videoDurationSec.hashCode ^
        videoUrl.hashCode ^
        thumbnailUrl.hashCode ^
        analysisStatus.hashCode ^
        detectedFeatures.hashCode ^
        finalEmotion.hashCode;
  }
}

