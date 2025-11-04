// lib/screens/auth/login_screen.dart
// 로그인 화면(Mock)
// - 회원가입 및 모드 선택 화면으로 이동 가능
// - 실제 인증 로직은 후속 BE 연동 시 구현 예정

import 'package:flutter/material.dart';
import '../../core/config/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.signup);
              debugPrint('Navigated to: ${AppRoutes.signup}');
            },
            child: const Text('회원가입으로'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.modeSelect);
              debugPrint('Navigated to: ${AppRoutes.modeSelect}');
            },
            child: const Text('로그인 건너뛰기 → 모드 선택'),
          ),
        ]),
      ),
    );
  }
}
