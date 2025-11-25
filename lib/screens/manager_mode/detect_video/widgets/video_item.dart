import '../../../../core/index_export.dart';
import '../../../../models/event_info.dart';
import 'emotion_utils.dart';

/// 영상 아이템 위젯
class VideoItem extends StatelessWidget {
  final EventInfo event;
  final VoidCallback? onTap;

  const VideoItem({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final emotion = event.finalEmotion ?? '분석 중';
    final emotionColor = event.isAnalysisCompleted
        ? EmotionUtils.getEmotionColor(event.finalEmotion ?? '')
        : AppColors.grey6;
    final timeAgo = EmotionUtils.formatTimeAgo(event.startTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 썸네일
                Container(
                  width: 100,
                  height: 75,
                  decoration: BoxDecoration(
                    color: AppColors.grey3,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      event.thumbnailUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                event.thumbnailUrl!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 75,
                                errorBuilder: (context, error, stack) => const Center(
                                  child: Icon(
                                    Icons.videocam,
                                    color: AppColors.grey6,
                                  ),
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.videocam,
                                color: AppColors.grey6,
                              ),
                            ),
                      // 재생 아이콘 오버레이
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      // 분석 상태 배지
                      if (!event.isAnalysisCompleted)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '분석 중',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 감정 태그
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: emotionColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          emotion,
                          style: TextStyle(
                            fontSize: AppConstants.smallFontSize,
                            color: emotionColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AppConstants.h6,
                      // 시간 정보
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          fontSize: AppConstants.smallFontSize,
                          color: AppColors.grey8,
                        ),
                      ),
                      AppConstants.h4,
                      // 영상 길이
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.grey6,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.formattedDuration,
                            style: const TextStyle(
                              fontSize: AppConstants.smallFontSize,
                              color: AppColors.grey6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 더보기 아이콘
                Icon(
                  Icons.chevron_right,
                  color: AppColors.grey6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

