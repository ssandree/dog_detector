import 'core/index_export.dart';
import 'core/services/auth/mock_auth_service.dart';
import 'core/storage/local_storage_keys.dart';
import 'core/storage/local_storage_repository.dart';

// 앱 진입 시 로그인 토큰 및 이전 모드 정보를 확인해 초기 라우트를 결정합니다.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialLocation = await _determineInitialLocation();
  final router = createAppRouter(initialLocation: initialLocation);
  runApp(
    // ProviderScope: Riverpod 전역 상태 컨테이너
    ProviderScope(
      child: MyApp(appRouter: router),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appRouter});

  final GoRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '견심술',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 저장된 로그인 토큰과 모드 정보를 기반으로 초기 진입 경로를 반환합니다.
/// - 로그인 토큰이 없으면 메인 화면(`/`)으로 이동합니다.
/// - 토큰이 있고 마지막으로 선택한 모드가 있으면 해당 모드의 홈 화면으로 이동합니다.
/// - 토큰은 있지만 모드 정보가 없으면 모드 선택 화면으로 이동합니다.
Future<String> _determineInitialLocation() async {
  final storage = LocalStorageRepository();
  final authService = MockAuthService(storage);

  try {
    final authInfo = await authService.loadStoredAuthInfo();
    if (authInfo == null) {
      return AppRoutes.main;
    }

    final savedModeString = await storage.loadString(LocalStorageKeys.appMode);
    if (savedModeString == AppMode.manager.name) {
      return AppRoutes.managerHome;
    }
    if (savedModeString == AppMode.camera.name) {
      return AppRoutes.cameraHome;
    }

    return AppRoutes.modeSelect;
  } catch (_) {
    return AppRoutes.main;
  }
}
