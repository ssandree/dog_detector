// lib/screens/auth/signup_screen.dart
// 회원가입 화면(Mock)
// - 가입 완료 시 모드 선택 화면으로 이동
// - 실제 회원가입 로직은 BE 연동 후 추가 예정

import 'package:flutter/material.dart';
import '../../core/config/app_routes.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.modeSelect);
            debugPrint('Navigated to: ${AppRoutes.modeSelect}');
          },
          child: const Text('가입 완료 → 모드 선택'),
        ),
      ),
    );
  }
}
