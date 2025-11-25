import '../../../core/index_export.dart';
import '../../../models/event_info.dart';
import '../../../widgets/app_error_banner.dart';
import 'widgets/empty_state.dart';
import 'widgets/emotion_stats_section.dart';
import 'widgets/video_list_section.dart';

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
      return const EmptyState();
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
            EmotionStatsSection(emotionCounts: emotionCounts),
            AppConstants.h24,
          ],
          // 영상 목록 섹션
          VideoListSection(
            events: events,
            onVideoTap: (event) {
              // 영상 상세 화면으로 이동 (필요시)
            },
          ),
          AppConstants.h24,
        ],
      ),
    );
  }
}

