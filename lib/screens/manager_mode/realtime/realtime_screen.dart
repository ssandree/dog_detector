import '../../../core/index_export.dart';
import '../realtime/widgets/video_player_section.dart';
import '../realtime/widgets/detect_timelist.dart';
import '../realtime/widgets/state_summary.dart';

class RealtimeScreen extends StatelessWidget {
  const RealtimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RealtimeContent();
  }
}


class _RealtimeContent extends StatelessWidget {
  const _RealtimeContent();

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: '실시간 모니터링',
      showBackButton: false,
      showNotification: true,
      onNotificationPressed: () {
        // 알림 기능
      },
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // 비디오 플레이어 영역
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 32),
            child: const VideoPlayerSection(),
          ),
        ],
      ),
    );
  }
}

