import 'package:flutter/material.dart';
import 'camera_setting_screen.dart';
import '../../core/index_export.dart';
import '../manager_mode/realtime/widgets/analysis_item_row.dart';
import '../main/main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: '캠모드',
      appBarTheme: AppBarThemeType.secondary,
      onBackPressed: () {
        AppUtils.navigateTo(
          context,
          const MainScreen(),
          replace: true,
        );
      },
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.white),
          onPressed: () {
            AppUtils.navigateTo(context, const CameraSettingScreen());
          },
        ),
      ],
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.secondaryAppBarColor,
        ),
        child: Column(
          children: [
            // 카메라 프리뷰 영역
            Expanded(
              flex: 3,
              child: Container(
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
                      Icon(
                        Icons.camera_alt,
                        size: 80,
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: AppConstants.defaultSpacing),
                      Text(
                        '카메라 프리뷰',
                        style: TextStyle(
                          fontSize: AppConstants.titleFontSize - 6,
                          color: AppColors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallSpacing),
                      Text(
                        '강아지를 카메라에 비춰주세요',
                        style: TextStyle(
                          fontSize: AppConstants.smallFontSize + 2,
                          color: AppColors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  // 통증 상태
                  AnalysisItemRow(
                    icon: Icons.favorite,
                    title: '통증 상태',
                    value: '정상',
                    valueColor: AppColors.painStatusColor,
                  ),
                  const SizedBox(height: AppConstants.defaultSpacing - 4),
                  
                  // 감정 상태
                  AnalysisItemRow(
                    icon: Icons.sentiment_satisfied,
                    title: '감정 상태',
                    value: '행복',
                    valueColor: AppColors.emotionStatusColor,
                  ),
                  const SizedBox(height: AppConstants.defaultSpacing - 4),
                  
                  // 활동 수준
                  AnalysisItemRow(
                    icon: Icons.directions_run,
                    title: '활동 수준',
                    value: '활발',
                    valueColor: AppColors.activityStatusColor,
                  ),
                ],
              ),
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
                
            // 카메라 시작 버튼
            AppButtons.secondary(
              text: '카메라 시작',
              icon: Icons.play_arrow,
              onPressed: () {
                AppUtils.showComingSoonMessage(context, feature: '카메라');
              },
            ),
          ],
        ),
      ),
    );
  }

}
