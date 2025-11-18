import '../../../core/index_export.dart';
import '../realtime/widgets/video_player_section.dart';
import '../realtime/widgets/detection_info_section.dart';
import '../realtime/widgets/realtime_timeline_section.dart';

// 실시간 감정·객체 분석 결과 스트리밍 화면
// WebSocket을 통해 수신된 감정(label, prob)과 객체 탐지, 녹화·업로드 상태를 표시
class RealtimeScreen extends ConsumerWidget {
  const RealtimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: AppConstants.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 비디오 플레이어 영역
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: const VideoPlayerSection(),
          ),
          AppConstants.h20,
          // 전체보기 버튼
          AppButtons.primary(
            text: '전체보기',
            icon: Icons.fullscreen,
            onPressed: () => context.push(AppRoutes.realtimeFullscreen),
          ),
          AppConstants.h20,
          const DetectionInfoSection(),
          AppConstants.h20,
          const RealtimeTimelineSection(),
          AppConstants.h20,
          // 연결 상태 표시
          const Text(
            '실시간 연결 기능이 임시 비활성화되었습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.grey6,
              fontSize: AppConstants.smallFontSize + 2,
            ),
          ),
          AppConstants.h20,
        ],
      ),
    );
  }
}

