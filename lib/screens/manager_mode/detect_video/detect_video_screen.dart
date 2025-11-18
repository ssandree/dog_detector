import '../../../core/index_export.dart';
import '../../../models/event_info.dart';
import '../../../widgets/app_error_banner.dart';

/// 탐지된 감정과 영상 목록을 보여주는 화면
class DetectVideoScreen extends ConsumerWidget {
  const DetectVideoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petInfo = ref.watch(currentPetProvider);
    final petId = petInfo?.petId ?? 1; // 기본값 1

    final eventsAsync = ref.watch(
      petEventsProvider((petId: petId, skip: 0, limit: 100)),
    );

    return BaseScaffold(
      title: '탐지된 영상',
      body: eventsAsync.when(
        data: (events) => _buildContent(context, ref, events),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: AppErrorWidget(
            message: '영상 목록을 불러오는데 실패했습니다',
            onRetry: () => ref.invalidate(
              petEventsProvider((petId: petId, skip: 0, limit: 100)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<EventInfo> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 64,
              color: AppColors.grey6,
            ),
            AppConstants.h16,
            Text(
              '탐지된 영상이 없습니다',
              style: TextStyle(
                fontSize: AppConstants.defaultFontSize,
                color: AppColors.grey8,
              ),
            ),
          ],
        ),
      );
    }

    // 감정별 통계 계산
    final emotionCounts = <String, int>{};
    for (final event in events) {
      if (event.finalEmotion != null && event.isAnalysisCompleted) {
        emotionCounts[event.finalEmotion!] = 
            (emotionCounts[event.finalEmotion!] ?? 0) + 1;
      }
    }

    return SingleChildScrollView(
      padding: AppConstants.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppConstants.h16,
          // 감정 통계 섹션
          if (emotionCounts.isNotEmpty) ...[
            _buildEmotionStatsSection(emotionCounts),
            AppConstants.h24,
          ],
          // 영상 목록 섹션
          _buildVideoListSection(context, events),
          AppConstants.h24,
        ],
      ),
    );
  }

  /// 감정 통계 섹션
  Widget _buildEmotionStatsSection(Map<String, int> emotionCounts) {
    return AppCards.basic(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '탐지된 감정',
            style: TextStyle(
              fontSize: AppConstants.titleFontSize - 6,
              fontWeight: FontWeight.bold,
              color: AppColors.grey12,
            ),
          ),
          AppConstants.h12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emotionCounts.entries.map((entry) {
              final emotion = entry.key;
              final count = entry.value;
              final color = _getEmotionColor(emotion);

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$emotion ($count)',
                      style: TextStyle(
                        fontSize: AppConstants.smallFontSize + 2,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 영상 목록 섹션
  Widget _buildVideoListSection(BuildContext context, List<EventInfo> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '영상 목록',
          style: TextStyle(
            fontSize: AppConstants.titleFontSize - 6,
            fontWeight: FontWeight.bold,
            color: AppColors.grey12,
          ),
        ),
        AppConstants.h12,
        ...events.map((event) => _buildVideoItem(context, event)).toList(),
      ],
    );
  }

  /// 영상 아이템 위젯
  Widget _buildVideoItem(BuildContext context, EventInfo event) {
    final emotion = event.finalEmotion ?? '분석 중';
    final emotionColor = event.isAnalysisCompleted
        ? _getEmotionColor(event.finalEmotion ?? '')
        : AppColors.grey6;
    final timeAgo = _formatTimeAgo(event.startTime);

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
          onTap: () {
            // 영상 상세 화면으로 이동 (필요시)
          },
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

  /// 감정별 색상 반환
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

  /// 시간 포맷팅 (N분 전, N시간 전 등)
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
    }
  }
}

