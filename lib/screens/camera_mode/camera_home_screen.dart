import 'package:flutter/material.dart';
import '../mode_selection/mode_select_screen.dart';
import 'camera_setting_screen.dart';
import '../../widgets/base_scaffold.dart';
import '../../widgets/buttons/app_buttons.dart';
import '../../widgets/cards/app_cards.dart';
import '../../utils/app_utils.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';

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
          const ModeSelectScreen(),
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.secondaryGradientColors,
          ),
        ),
        child: Column(
          children: [
            // 카메라 프리뷰 영역
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
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
                        color: AppColors.white.withOpacity(0.7),
                      ),
                      const SizedBox(height: AppConstants.defaultSpacing),
                      Text(
                        '카메라 프리뷰',
                        style: TextStyle(
                          fontSize: AppConstants.titleFontSize - 6,
                          color: AppColors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallSpacing),
                      Text(
                        '강아지를 카메라에 비춰주세요',
                        style: TextStyle(
                          fontSize: AppConstants.smallFontSize + 2,
                          color: AppColors.white.withOpacity(0.6),
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
              child: AppCards.analysisResult(
                title: '분석 결과',
                children: [
                  // 통증 상태
                  _buildAnalysisItem(
                    icon: Icons.favorite,
                    title: '통증 상태',
                    value: '정상',
                    color: AppColors.painStatusColor,
                  ),
                  const SizedBox(height: AppConstants.defaultSpacing - 4),
                  
                  // 감정 상태
                  _buildAnalysisItem(
                    icon: Icons.sentiment_satisfied,
                    title: '감정 상태',
                    value: '행복',
                    color: AppColors.emotionStatusColor,
                  ),
                  const SizedBox(height: AppConstants.defaultSpacing - 4),
                  
                  // 활동 수준
                  _buildAnalysisItem(
                    icon: Icons.directions_run,
                    title: '활동 수준',
                    value: '활발',
                    color: AppColors.activityStatusColor,
                  ),
                ],
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

  Widget _buildAnalysisItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.circularBorderRadius - 30),
          ),
          child: Icon(
            icon,
            size: AppConstants.defaultIconSize - 4,
            color: color,
          ),
        ),
        const SizedBox(width: AppConstants.defaultSpacing - 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppConstants.smallFontSize + 2,
                  color: AppColors.grey6,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppConstants.defaultFontSize,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
