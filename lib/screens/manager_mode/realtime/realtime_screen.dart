import '../../../core/index_export.dart';
import '../realtime/widgets/video_player_section.dart';

// 실시간 감정·객체 분석 결과 스트리밍 화면
// WebSocket을 통해 수신된 감정(label, prob)과 객체 탐지, 녹화·업로드 상태를 표시
class RealtimeScreen extends ConsumerWidget {
  const RealtimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 비디오 플레이어 영역
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: const VideoPlayerSection(),
        ),
        AppConstants.h20,
        // 연결 상태 표시
        const Text('실시간 연결 기능이 임시 비활성화되었습니다.'),
      ],
    );
  }
}

