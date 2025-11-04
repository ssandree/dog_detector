// lib/screens/onboarding/onboarding_screen.dart
// 온보딩 화면
// - 앱 최초 실행 시 표시되는 첫 진입 화면
// - “시작하기” 버튼 클릭 시 로그인 화면으로 이동

import 'package:flutter/material.dart';
import '../../core/config/app_routes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.login);
            debugPrint('Navigated to: ${AppRoutes.login}');
          },
          child: const Text('시작하기'),
        ),
      ),
    );
  }
}
