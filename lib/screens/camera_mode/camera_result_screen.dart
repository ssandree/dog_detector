import '../../core/index_export.dart';
import '../manager_mode/realtime/widgets/analysis_item_row.dart';
import '../../providers/ai_provider.dart';
import '../../providers/camera_provider.dart';

/// 촬영 결과 요약 화면
/// 
/// 역할:
/// - 실시간 감정 분석 결과를 요약·시각화
/// - 리포트로 전환하는 중간 단계
/// - 마지막 촬영 이미지 표시
class CameraResultScreen extends HookConsumerWidget {
  const CameraResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiProvider);
    final cameraState = ref.watch(cameraProvider);

    return BaseScaffold(
      title: '촬영 결과',
      body: SingleChildScrollView(
        child: HorizontalPadding(
          child: Column(
            children: [
              const SizedBox(height: AppConstants.largeSpacing),

              // 마지막 촬영 이미지 표시
              cameraState.when(
                data: (state) {
                  if (state.lastCapture != null) {
                    return AppCards.basic(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                        child: Image.file(
                          state.lastCapture!,
                          height: 240,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                  return _buildNoImagePlaceholder();
                },
                loading: () => _buildNoImagePlaceholder(),
                error: (error, stack) => _buildNoImagePlaceholder(),
              ),

              const SizedBox(height: AppConstants.largeSpacing),

              // 감정 분석 결과 표시
              AppCards.basic(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '분석 결과',
                      style: TextStyle(
                        fontSize: AppConstants.titleFontSize - 4,
                        fontWeight: FontWeight.bold,
                        color: AppColors.analysisResultTitleColor,
                      ),
                    ),
                    const SizedBox(height: AppConstants.defaultSpacing),

                    aiState.when(
                      data: (state) {
                        if (state.label == null) {
                          return const Center(
                            child: Text('분석 결과를 불러오는 중...'),
                          );
                        }
                        return Column(
                          children: [
                            // 감정 상태
                            AnalysisItemRow(
                              icon: Icons.sentiment_satisfied,
                              title: '감정 상태',
                              value: state.label ?? '분석 중...',
                              valueColor: AppColors.emotionStatusColor,
                            ),
                            const SizedBox(height: AppConstants.defaultSpacing - 4),

                            // 감정 확률
                            Row(
                              children: [
                                const SizedBox(width: 48), // 아이콘 너비만큼 간격
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '확률',
                                        style: TextStyle(
                                          fontSize: AppConstants.smallFontSize + 2,
                                          color: AppColors.grey6,
                                        ),
                                      ),
                                      Text(
                                        '${((state.prob ?? 0) * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: AppConstants.defaultFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.emotionStatusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => AppCards.alert(
                        message: '분석 오류: ${error.toString()}',
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        iconColor: AppColors.error,
                        textColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.extraLargeSpacing),

              // 동작 버튼
              Row(
                children: [
                  Expanded(
                    child: AppButtons.outline(
                      text: '다시 촬영',
                      icon: Icons.refresh,
                      onPressed: () {
                        context.go(AppRoutes.cameraHome);
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultSpacing),
                  Expanded(
                    child: AppButtons.primary(
                      text: '리포트로 이동',
                      icon: Icons.assessment,
                      onPressed: () {
                        // TODO: 리포트 화면 라우트 추가 필요
                        AppToast.comingSoon(context, '리포트');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.largeSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return AppCards.basic(
      child: Column(
        children: [
          Icon(
            Icons.image_not_supported,
            size: AppConstants.largeIconSize * 2,
            color: AppColors.grey5,
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          Text(
            '최근 촬영 이미지가 없습니다',
            style: TextStyle(
              fontSize: AppConstants.defaultFontSize,
              color: AppColors.grey6,
            ),
          ),
        ],
      ),
    );
  }
}
