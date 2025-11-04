// lib/main.dart
// 앱 진입점
// - Hive 초기화 및 어댑터 등록
// - ProviderScope로 Riverpod 전역 상태 관리
// - MaterialApp 설정 및 라우트 등록

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/analytics_bundle.dart';
import 'models/analytics_summary.dart';
import 'models/emotion_report.dart';
import 'core/config/app_routes.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/mode_select/mode_select_screen.dart';
import 'screens/camera_mode/camera_home_screen.dart';
import 'screens/manager_mode/manager_home_screen.dart';
import 'screens/report/analytics_dashboard_screen.dart';
import 'screens/report/emotion_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive
    ..registerAdapter(AnalyticsBundleAdapter())
    ..registerAdapter(AnalyticsSummaryAdapter())
    ..registerAdapter(TrendPointAdapter())
    ..registerAdapter(CameraStatAdapter())
    ..registerAdapter(EmotionReportAdapter());

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.onboarding,
      routes: {
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signup: (_) => const SignupScreen(),
        AppRoutes.modeSelect: (_) => const ModeSelectScreen(),
        AppRoutes.cameraHome: (_) => const CameraHomeScreen(),
        AppRoutes.managerHome: (_) => const ManagerHomeScreen(),
        AppRoutes.reportHome: (_) => const AnalyticsDashboardScreen(),
        AppRoutes.reportDetail: (_) => const EmotionDetailScreen(),
      },
    );
  }
}
