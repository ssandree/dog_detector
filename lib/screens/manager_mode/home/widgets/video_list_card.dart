import '../../../../core/index_export.dart';

/// 강아지 찍힌 영상 목록 카드
class VideoListCard extends ConsumerWidget {
  const VideoListCard({super.key});

  String _formatTimeAgo(DateTime detectedAt) {
    final now = DateTime.now();
    final difference = now.difference(detectedAt);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case '행복':
        return AppColors.green6;
      case '평온':
        return AppColors.green5;
      case '활발':
        return AppColors.green7;
      case '불안':
        return AppColors.activityStatusColor;
      case '화남':
        return AppColors.error;
      default:
        return AppColors.grey6;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(recentVideosProvider);

    return videosAsync.when(
      data: (videos) {
        if (videos.isEmpty) {
          return const SizedBox.shrink();
        }

        return AppCards.basic(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '강아지 찍힌 영상들',
                    style: TextStyle(
                      fontSize: AppConstants.titleFontSize - 6,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey12,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // 더보기 화면으로 이동 (필요시)
                    },
                    child: const Text(
                      '더보기',
                      style: TextStyle(
                        fontSize: AppConstants.smallFontSize + 2,
                        color: AppColors.green6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              AppConstants.h12,
              ...videos.map((video) {
                final thumbnailUrl = video['thumbnailUrl'] as String?;
                final duration = video['duration'] as String? ?? '00:00';
                final detectedAt = video['detectedAt'] as DateTime?;
                final emotion = video['emotion'] as String? ?? '';
                final emotionColor = _getEmotionColor(emotion);
                final timeAgo = detectedAt != null ? _formatTimeAgo(detectedAt) : '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // 썸네일
                      Container(
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.grey3,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  thumbnailUrl,
                                  fit: BoxFit.cover,
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
                      ),
                      const SizedBox(width: 12),
                      // 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
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
                                const SizedBox(width: 8),
                                Text(
                                  duration,
                                  style: const TextStyle(
                                    fontSize: AppConstants.smallFontSize,
                                    color: AppColors.grey8,
                                  ),
                                ),
                              ],
                            ),
                            if (timeAgo.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                timeAgo,
                                style: const TextStyle(
                                  fontSize: AppConstants.smallFontSize,
                                  color: AppColors.grey6,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // 재생 버튼
                      IconButton(
                        icon: const Icon(
                          Icons.play_circle_outline,
                          color: AppColors.green6,
                          size: 32,
                        ),
                        onPressed: () {
                          // 영상 재생 (필요시)
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
      loading: () => AppCards.basic(
        padding: const EdgeInsets.all(20),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

