// lib/features/home/model/event_info.dart

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
    final videoUrl = json['video_url'] as String?;
    final thumbnailUrl = json['thumbnail_url'] as String?;
    
    print('========== [EventInfo.fromJson] 디버깅 정보 ==========');
    print('[EventInfo.fromJson] event_id: ${json['event_id']}');
    print('[EventInfo.fromJson] video_url: $videoUrl');
    print('[EventInfo.fromJson] thumbnail_url: $thumbnailUrl');
    
    if (videoUrl != null && thumbnailUrl != null) {
      print('[EventInfo.fromJson] video_url == thumbnail_url: ${videoUrl == thumbnailUrl}');
      print('[EventInfo.fromJson] video_url 길이: ${videoUrl.length}');
      print('[EventInfo.fromJson] thumbnail_url 길이: ${thumbnailUrl.length}');
      
      // URL 확장자 확인
      final videoExt = _getFileExtension(videoUrl);
      final thumbnailExt = _getFileExtension(thumbnailUrl);
      print('[EventInfo.fromJson] video_url 확장자: $videoExt');
      print('[EventInfo.fromJson] thumbnail_url 확장자: $thumbnailExt');
      
      // 비디오 파일인지 확인
      final isVideoFile = _isVideoFile(thumbnailUrl);
      print('[EventInfo.fromJson] thumbnail_url이 비디오 파일인가? $isVideoFile');
    }
    print('==================================================');
    
    return EventInfo(
      eventId: json['event_id'],
      petId: json['pet_id'],
      deviceId: json['device_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      videoDurationSec: json['video_duration_sec'],
      videoUrl: videoUrl ?? '',
      thumbnailUrl: thumbnailUrl,
      analysisStatus: AnalysisStatus.fromString(json['analysis_status']),
      detectedFeatures: json['detected_features'],
      finalEmotion: json['final_emotion'],
      patellaAnalysisResult: json['patella_analysis_result'],
    );
  }
  
  static String? _getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final lastDot = path.lastIndexOf('.');
      if (lastDot != -1 && lastDot < path.length - 1) {
        return path.substring(lastDot).toLowerCase();
      }
    } catch (e) {
      // URL 파싱 실패 시 무시
    }
    return null;
  }
  
  static bool _isVideoFile(String url) {
    final lowerUrl = url.toLowerCase();
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.flv', '.m4v'];
    return videoExtensions.any((ext) => lowerUrl.contains(ext));
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

class DailyPetEvents {
  final int petId;
  final DateTime date;
  final List<EventInfo> events;

  DailyPetEvents({
    required this.petId,
    required this.date,
    required this.events,
  });

  factory DailyPetEvents.fromJson(Map<String, dynamic> json) {
    final eventsJson = json['events'] as List<dynamic>? ?? [];
    return DailyPetEvents(
      petId: json['pet_id'] as int,
      date: DateTime.parse(json['date'] as String),
      events: eventsJson
          .map((eventJson) => EventInfo.fromJson(eventJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'date': date.toIso8601String(),
      'events': events.map((event) => event.toJson()).toList(),
    };
  }
}
