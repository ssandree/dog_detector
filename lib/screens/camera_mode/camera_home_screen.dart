import '../../core/index_export.dart';
import 'package:camera/camera.dart';
import '../manager_mode/realtime/widgets/analysis_item_row.dart';
import '../../providers/camera_provider.dart';
import '../../providers/ai_provider.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraProvider);
    final aiState = ref.watch(aiProvider);

    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = statusBarHeight + AppBar().preferredSize.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: buildCollapsingScrollView(
        headerHeight: headerHeight,
        customHeader: _buildHeader(context),
        padding: EdgeInsets.zero,
        fillRemaining: true,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.appBarColor,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.smallPadding.horizontal,
            ),
            child: Column(
              children: [
                // 카메라 프리뷰 영역
                Expanded(
                  flex: 3,
                  child: cameraState.when(
                    data: (state) {
                      if (state.controller != null && state.isInitialized) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
                            child: CameraPreview(state.controller!),
                          ),
                        );
                      }
                      return _buildPlaceholderCamera();
                    },
                    loading: () => _buildPlaceholderCamera(loading: true),
                    error: (error, stack) => _buildPlaceholderCamera(error: error.toString()),
                  ),
                ),
                const SizedBox(height: AppConstants.largeSpacing),

                // 분석 결과 영역
                Expanded(
                  flex: 2,
                  child: AppCards.basic(
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
                        // WebSocket 연결 상태
                        aiState.when(
                          data: (state) => Column(
                            children: [
                              if (!state.connected)
                                AppCards.alert(
                                  message: '서버 연결 안 됨',
                                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                                  iconColor: AppColors.error,
                                  textColor: AppColors.error,
                                ),
                              if (state.connected && state.label != null) ...[
                                AnalysisItemRow(
                                  icon: Icons.sentiment_satisfied,
                                  title: '감정 상태',
                                  value: state.label ?? '분석 중...',
                                  valueColor: AppColors.emotionStatusColor,
                                ),
                                const SizedBox(height: AppConstants.defaultSpacing - 4),
                              ],
                              if (state.dogDetected)
                                AnalysisItemRow(
                                  icon: Icons.pets,
                                  title: '강아지 감지',
                                  value: '감지됨',
                                  valueColor: AppColors.success,
                                ),
                            ],
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
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
                ),
                const SizedBox(height: AppConstants.largeSpacing),

                // 카메라 시작 버튼
                AppButtons.normal(
                  text: '카메라 시작',
                  icon: Icons.play_arrow,
                  onPressed: () {
                    ref.read(cameraProvider.notifier).initialize();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCamera({bool loading = false, String? error}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const CircularProgressIndicator(color: AppColors.white)
            else if (error != null)
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.error,
              )
            else
              Icon(
                Icons.camera_alt,
                size: 80,
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            const SizedBox(height: AppConstants.defaultSpacing),
            Text(
              loading ? '카메라 초기화 중...' : error ?? '카메라 프리뷰',
              style: TextStyle(
                fontSize: AppConstants.titleFontSize - 6,
                color: AppColors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (error == null && !loading) ...[
              const SizedBox(height: AppConstants.smallSpacing),
              Text(
                '강아지를 카메라에 비춰주세요',
                style: TextStyle(
                  fontSize: AppConstants.smallFontSize + 2,
                  color: AppColors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.appBarColor,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppConstants.smallPadding.horizontal,
          right: AppConstants.smallPadding.horizontal,
          top: statusBarHeight,
          bottom: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '캠모드',
              style: TextStyle(
                color: AppColors.whiteAppBarTextColor,
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.appBarTitleFontSize,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.whiteAppBarTextColor,
                size: AppConstants.appBarIconSize,
              ),
              onPressed: () => context.go(AppRoutes.main),
            ),
          ],
        ),
      ),
    );
  }
}
