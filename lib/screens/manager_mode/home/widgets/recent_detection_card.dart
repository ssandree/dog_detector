import '../../../../core/index_export.dart';

/// 최근 감지 시간 표시 카드
class RecentDetectionCard extends ConsumerWidget {
  const RecentDetectionCard({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentDetectionAsync = ref.watch(recentDetectionProvider);

    return recentDetectionAsync.when(
      data: (data) {
        final lastDetectedAt = data['lastDetectedAt'] as DateTime?;
        if (lastDetectedAt == null) {
          return const SizedBox.shrink();
        }

        final timeAgo = _formatTimeAgo(lastDetectedAt);

        return AppCards.basic(
          padding: const EdgeInsets.all(20),
          backgroundColor: AppColors.green1,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.green5,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.videocam,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '$timeAgo에 강아지가 카메라에 포착되었습니다!',
                  style: const TextStyle(
                    fontSize: AppConstants.defaultFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green8,
                  ),
                ),
              ),
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

