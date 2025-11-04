import '../../../core/index_export.dart';
import '../realtime/widgets/video_player_section.dart';

// 실시간 감정·객체 분석 결과 스트리밍 화면
// WebSocket을 통해 수신된 감정(label, prob)과 객체 탐지, 녹화·업로드 상태를 표시
class RealtimeScreen extends ConsumerWidget {
  const RealtimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiStateAsync = ref.watch(aiProvider);
    final recordingStateAsync = ref.watch(recordingProvider);
    final uploadStateAsync = ref.watch(uploadProvider);

    return BaseScaffold(
      title: '실시간 모니터링',
      showBackButton: false,
      showNotification: true,
      onNotificationPressed: () {
        // 알림 기능
      },
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 비디오 플레이어 영역
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: const VideoPlayerSection(),
              ),

              const SizedBox(height: 20),

              // 연결 상태 표시
              aiStateAsync.when(
                data: (aiState) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      aiState.connected ? Icons.circle : Icons.circle_outlined,
                      color: aiState.connected ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      aiState.connected ? '서버 연결됨' : '서버 연결 안 됨',
                      style: TextStyle(
                        color: aiState.connected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text(
                  '연결 상태 확인 실패: ${error.toString()}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),

              const SizedBox(height: 20),

              // 감정 결과 표시
              aiStateAsync.when(
                data: (aiState) => aiState.label != null
                    ? Column(
                        children: [
                          Text(
                            aiState.label!.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '확률: ${((aiState.prob ?? 0) * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      )
                    : const Text('결과 수신 대기 중...'),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => const Text('감정 분석 결과를 불러올 수 없습니다'),
              ),

              const SizedBox(height: 20),

              // 개 탐지 여부
              aiStateAsync.when(
                data: (aiState) => Text(
                  aiState.dogDetected ? '개 감지됨' : '개 없음',
                  style: TextStyle(
                    color: aiState.dogDetected ? Colors.green : Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),

              const SizedBox(height: 20),

              // 녹화 상태 표시
              recordingStateAsync.when(
                data: (recordingState) => recordingState.isRecording
                    ? const Text(
                        '● 녹화 중',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      )
                    : const SizedBox(),
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),

              const SizedBox(height: 10),

              // 업로드 상태 표시
              uploadStateAsync.when(
                data: (uploadState) => Text(
                  '업로드 상태: ${uploadState.status.name}',
                  style: TextStyle(
                    color: uploadState.status == UploadStatus.success
                        ? Colors.green
                        : uploadState.status == UploadStatus.error
                            ? Colors.red
                            : Colors.grey,
                    fontSize: 16,
                  ),
                ),
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),

              const SizedBox(height: 40),

              // 수동 연결 버튼
              aiStateAsync.when(
                data: (aiState) => ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(aiProvider.notifier)
                        .connect('ws://YOUR_SERVER_URL');
                  },
                  child: const Text('서버 재연결'),
                ),
                loading: () => const SizedBox(),
                error: (error, stack) => ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(aiProvider.notifier)
                        .connect('ws://YOUR_SERVER_URL');
                  },
                  child: const Text('서버 연결'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

