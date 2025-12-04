import 'package:flutter/material.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/app_status_tags.dart';
import '../../logic/model/event_info.dart';
import '../detection_clue_modal.dart';

class EventCard extends StatelessWidget {
  final EventInfo event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final start = _formatTime(event.startTime);
    final durationLabel = '${event.videoDurationSec}s';
    final emotion = event.finalEmotion ?? '분석 중';
    final statusColor = _statusColor(event.analysisStatus);
    final features = event.detectedFeatures?.trim();
    final patellaResult = event.patellaAnalysisResult?.trim();
    final hasPatellaAbnormal = patellaResult == '이상';
    final thumbnailUrl = event.thumbnailUrl;
    final videoUrl = event.videoUrl;
    
    // 디버깅: 썸네일 URL과 동영상 URL 비교
    print('========== [EventCard] 디버깅 정보 ==========');
    print('[EventCard] eventId: ${event.eventId}');
    print('[EventCard] videoUrl: $videoUrl');
    print('[EventCard] thumbnailUrl: $thumbnailUrl');
    
    if (videoUrl.isNotEmpty && thumbnailUrl != null) {
      print('[EventCard] videoUrl == thumbnailUrl: ${videoUrl == thumbnailUrl}');
      print('[EventCard] videoUrl 길이: ${videoUrl.length}');
      print('[EventCard] thumbnailUrl 길이: ${thumbnailUrl.length}');
      
      // URL 확장자 확인
      final videoExt = _getFileExtension(videoUrl);
      final thumbnailExt = _getFileExtension(thumbnailUrl);
      print('[EventCard] videoUrl 확장자: $videoExt');
      print('[EventCard] thumbnailUrl 확장자: $thumbnailExt');
      
      // 비디오 파일인지 확인
      final isVideoFile = _isVideoFile(thumbnailUrl);
      print('[EventCard] thumbnailUrl이 비디오 파일인가? $isVideoFile');
      
      if (isVideoFile) {
        print('[EventCard] ⚠️ 경고: thumbnailUrl이 비디오 파일입니다! 이미지로 로드할 수 없습니다.');
      }
    }
    print('==========================================');

    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => DetectionClueModal(event: event),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppConstants.smallBorderRadius),
              child: SizedBox(
                width: 80,
                height: 56,
                child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                  ? Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          print('[EventCard] 이미지 로드 성공: $thumbnailUrl');
                          return child;
                        }
                        print('[EventCard] 이미지 로딩 중: $thumbnailUrl');
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('[EventCard] 이미지 로드 실패: $thumbnailUrl');
                        print('[EventCard] 에러: $error');
                        print('[EventCard] 스택 트레이스: $stackTrace');
                        return _ThumbnailFallback(color: statusColor);
                      },
                    )
                  : _ThumbnailFallback(color: statusColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        start,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.grey12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        durationLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grey7,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (features != null && features.isNotEmpty) ...[
                    Text(
                      features,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppStatusTags.emotionTag(
                        emotion: emotion,
                      ),
                      if (hasPatellaAbnormal) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.error,
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            '슬개 이상',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  Color _statusColor(AnalysisStatus status) {
    switch (status) {
      case AnalysisStatus.completed:
        return AppColors.green6;
      case AnalysisStatus.pending:
        return AppColors.warning;
      case AnalysisStatus.failed:
        return AppColors.error;
    }
  }
  
  String? _getFileExtension(String url) {
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
  
  bool _isVideoFile(String url) {
    final lowerUrl = url.toLowerCase();
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.flv', '.m4v'];
    return videoExtensions.any((ext) => lowerUrl.contains(ext));
  }
}

class _ThumbnailFallback extends StatelessWidget {
  final Color color;

  const _ThumbnailFallback({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.beige2,
      child: Icon(
        Icons.videocam,
        color: AppColors.beige5,
      ),
    );
  }
}
