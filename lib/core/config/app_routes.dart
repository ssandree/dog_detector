// lib/core/config/app_routes.dart
// 앱 내 모든 화면의 네비게이션 경로 상수 정의
// - 문자열 기반 경로를 중앙 관리하여 오타 및 중복 방지
// - 전체 플로우 : 온보딩 → 로그인/회원가입 → 모드 선택 → 모드 진입 → 세부 기능(녹화, 리포트, 설정 등)

class AppRoutes {
  // 기본 흐름
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String modeSelect = '/modeSelect';

  // 기능별 메인 화면
  static const String cameraHome = '/cameraHome';
  static const String reportHome = '/report';
  static const String reportDetail = '/report/detail';
  static const String settings = '/settings';

  // 관리자용
  static const String managerHome = '/managerHome';

  // 알림 관련
  static const String notificationSettings = '/settings/notifications';
  static const String deepLinkReportHome = 'report_home';
  static const String deepLinkReportDetail = 'report_detail';
}
