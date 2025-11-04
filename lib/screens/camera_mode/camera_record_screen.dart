import '../../core/index_export.dart';
import '../../providers/recording_provider.dart';

/// 녹화 제어 화면
/// 
/// 역할:
/// - 녹화 시작/중단 버튼 UI
/// - 녹화 상태 실시간 표시
/// - RecordService 및 RecordStateProvider 연동
class CameraRecordScreen extends HookConsumerWidget {
  const CameraRecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingProvider);

    return BaseScaffold(
      title: '녹화 제어',
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 녹화 상태 표시
            recordingState.when(
              data: (state) => AppCards.basic(
                child: Column(
                  children: [
                    Icon(
                      state.isRecording ? Icons.fiber_manual_record : Icons.radio_button_unchecked,
                      size: AppConstants.largeIconSize * 2,
                      color: state.isRecording ? AppColors.error : AppColors.grey6,
                    ),
                    const SizedBox(height: AppConstants.defaultSpacing),
                    Text(
                      state.isRecording ? '녹화 중...' : '대기 중',
                      style: TextStyle(
                        fontSize: AppConstants.titleFontSize - 4,
                        fontWeight: FontWeight.bold,
                        color: state.isRecording ? AppColors.error : AppColors.grey6,
                      ),
                    ),
                    if (state.error != null) ...[
                      const SizedBox(height: AppConstants.smallSpacing),
                      AppCards.alert(
                        message: state.error!,
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        iconColor: AppColors.error,
                        textColor: AppColors.error,
                      ),
                    ],
                  ],
                ),
              ),
              loading: () => AppCards.basic(
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => AppCards.basic(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: AppConstants.largeIconSize * 2,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppConstants.defaultSpacing),
                    Text(
                      '오류 발생',
                      style: TextStyle(
                        fontSize: AppConstants.titleFontSize - 4,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallSpacing),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: AppConstants.smallFontSize,
                        color: AppColors.grey6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),

            // 녹화 시작/중지 버튼
            recordingState.when(
              data: (state) => AppButtons.primary(
                text: state.isRecording ? '녹화 중지' : '녹화 시작',
                icon: state.isRecording ? Icons.stop : Icons.play_arrow,
                onPressed: () {
                  if (state.isRecording) {
                    ref.read(recordingProvider.notifier).stopRecording();
                  } else {
                    ref.read(recordingProvider.notifier).startRecording();
                  }
                },
              ),
              loading: () => AppButtons.disabled(
                text: '처리 중...',
                icon: Icons.hourglass_empty,
              ),
              error: (error, stack) => AppButtons.outline(
                text: '다시 시도',
                icon: Icons.refresh,
                onPressed: () {
                  ref.invalidate(recordingProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
