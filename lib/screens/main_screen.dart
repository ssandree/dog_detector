import 'package:flutter/material.dart';
import '../core/index_export.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      showAppBar: false,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.primaryGradientColors,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 아이콘/로고
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppConstants.circularBorderRadius),
              ),
              child: const Icon(
                Icons.pets,
                size: 60,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppConstants.extraLargeSpacing),
            
            // 앱 타이틀
            const Text(
              '멍멍이탐지',
              style: TextStyle(
                fontSize: AppConstants.largeTitleFontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
                
            // 서비스 설명
            Text(
              'AI 기반 강아지 통증 및 감정 탐지 서비스',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.titleFontSize - 6,
                color: AppColors.white.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              '반려견의 건강과 행복을 위한 스마트 케어',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.defaultFontSize,
                color: AppColors.white.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppConstants.extraLargeSpacing * 2),
                
            // 시작하기 버튼
            AppButtons.primary(
              text: '시작하기',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.modeSelect);
              },
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            
            // 추가 정보
            Text(
              '간편한 설정으로 바로 시작하세요',
              style: TextStyle(
                fontSize: AppConstants.smallFontSize + 2,
                color: AppColors.white.withOpacity(0.54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
