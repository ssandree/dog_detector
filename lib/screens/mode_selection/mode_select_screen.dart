import 'package:flutter/material.dart';
import '../camera_mode/camera_home_screen.dart' as camera_home;
import '../manager_mode/(tabs)/manager_home_screen.dart' as manager_home;
import '../../widgets/base_scaffold.dart';
import '../../utils/app_utils.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      showAppBar: false,
      backgroundColor: AppColors.defaultBackgroundColor,
      safeAreaPadding: AppConstants.modeSelectPadding,
      body: Column(
        children: [
          const SizedBox(height: 80),
          
          // 강아지 로고
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(AppConstants.circularBorderRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.circularBorderRadius),
              child: Image.asset(
                'lib/config/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // 환영 메시지
          const Text(
            '민호님, 환영합니다!',
            style: TextStyle(
              fontSize: AppConstants.titleFontSize - 6,
              color: AppColors.grey9,
            ),
          ),
          const SizedBox(height: 10),
          
          // 안내 문구
          const Text(
            '시작할 모드를 선택해주세요',
            style: TextStyle(
              fontSize: AppConstants.defaultFontSize,
              color: AppColors.grey7,
            ),
          ),
          const SizedBox(height: 50),
          
          // 캠모드 버튼
          _buildModeButton(
            context: context,
            title: '캠 모드',
            icon: Icons.videocam,
            backgroundColor: AppColors.green3,
            iconColor: AppColors.green7,
            textColor: AppColors.green8,
            onTap: () {
              AppUtils.navigateTo(
                context,
                const camera_home.HomeScreen(),
                replace: true,
              );
            },
          ),
          const SizedBox(height: 50),
          
          // 매니저모드 버튼
          _buildModeButton(
            context: context,
            title: '매니저 모드',
            icon: Icons.bar_chart,
            backgroundColor: AppColors.beige3,
            iconColor: AppColors.coral5,
            textColor: AppColors.grey9,
            onTap: () {
              AppUtils.navigateTo(
                context,
                const manager_home.HomeScreen(),
                replace: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘
            Icon(
              icon,
              size: AppConstants.largeIconSize + 8,
              color: iconColor,
            ),
            const SizedBox(height: AppConstants.smallSpacing + 2),
            
            // 텍스트
            Text(
              title,
              style: TextStyle(
                fontSize: AppConstants.titleFontSize - 6,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppConstants.smallSpacing - 3),
            
            // 설명 텍스트
            Text(
              title == '캠 모드' ? '강아지를 촬영하는 모드' : '견심술 탐지 결과를 보고 관리하는 모드',
              style: TextStyle(
                fontSize: AppConstants.smallFontSize,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}