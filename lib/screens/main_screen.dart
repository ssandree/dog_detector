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
          color: AppColors.primaryAppBarColor,
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
                borderRadius: BorderRadius.circular(
                  AppConstants.circularBorderRadius,
                ),
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
              '견심술',
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
              'AI 기반 강아지 감정 탐지 서비스',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.titleFontSize - 6,
                color: AppColors.white.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppConstants.smallSpacing),

            // 시작하기 버튼
            Center(
              child: AppButtons.primary(
                text: '시작하기',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.modeSelect);
                },
              ),
            ),
            const SizedBox(height: AppConstants.smallSpacing),
          ],
        ),
      ),
    );
  }
}
