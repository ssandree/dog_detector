import '../core/index_export.dart';
import '../screens/main_screen.dart';
import '../screens/mode_selection/mode_select_screen.dart';
import '../screens/camera_mode/camera_home_screen.dart' as camera;
import '../screens/camera_mode/camera_record_screen.dart';
// 삭제된 화면 의존성 제거 (팀 코드 변경 대기)
import '../screens/manager_mode/home/manager_home_screen.dart' as manager;
import '../screens/manager_mode/notification/notification_screen.dart';
import '../screens/manager_mode/settings/setting_screen.dart';
import '../screens/manager_mode/dog_info/pet_regi_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';

/// 앱 라우트 경로 상수
class AppRoutes {
  static const String main = '/';
  static const String modeSelect = '/mode-select';
  static const String cameraHome = '/camera/home';
  static const String managerHome = '/manager/home';
  static const String notification = '/notification';
  static const String settings = '/settings';
  static const String petRegistration = '/pet/registration';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String cameraRecord = '/camera/record';

}

/// GoRouter 설정
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.main,
  routes: [
    GoRoute(
      path: AppRoutes.main,
      name: 'main',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: AppRoutes.modeSelect,
      name: 'modeSelect',
      builder: (context, state) => const ModeSelectScreen(),
    ),
    GoRoute(
      path: AppRoutes.cameraHome,
      name: 'cameraHome',
      builder: (context, state) => const camera.HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.cameraRecord,
      name: 'cameraRecord',
      builder: (context, state) => const CameraRecordScreen(),
    ),
    // 삭제된 화면 라우트 제거
    GoRoute(
      path: AppRoutes.managerHome,
      name: 'managerHome',
      builder: (context, state) => const manager.HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.notification,
      name: 'notification',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const SettingScreen(),
    ),
    GoRoute(
      path: AppRoutes.petRegistration,
      name: 'petRegistration',
      builder: (context, state) => const PetRegiScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('페이지를 찾을 수 없습니다: ${state.uri}'),
    ),
  ),
);

