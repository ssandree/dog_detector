// lib/core/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/cam/camera_main_screen.dart';
import '../../features/manager/calendar/calendar_screen.dart';
import '../../features/manager/home/manager_home_screen.dart';
import '../../features/manager/manager_navigation.dart';
import '../../features/manager/notification/notification_screen.dart';
import '../../features/manager/realtime/realtime_screen.dart';
import '../../features/manager/setting/setting_screen.dart';
import '../../features/manager/event_timeline/event_timeline_screen.dart';
import '../../features/mode_select/mode_select_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../storage/app_prefs_provider.dart';

class AppRoutes {
  static const String main = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String modeSelect = '/mode-select';
  static const String cameraHome = '/camera';
  static const String managerHome = '/manager';
  static const String managerNotification = '/manager/notification';
  static const String managerSettings = '/manager/settings';
  static const String managerRealtime = '/manager/realtime';
  static const String managerCalendar = '/manager/calendar';
  static const String managerEventTimeline = '/manager/calendar/timeline';
}

final appRouter = createAppRouter();

GoRouter createAppRouter({String initialLocation = AppRoutes.main}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.main,
        builder: (_, __) => const EntryGate(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.modeSelect,
        builder: (_, __) => const ModeSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.cameraHome,
        builder: (_, __) => const CameraMainScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerHome,
        builder: (_, __) => const MainNavigation(),
      ),
      GoRoute(
        path: AppRoutes.managerNotification,
        builder: (_, __) => const NotificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerSettings,
        builder: (_, __) => const SettingScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerRealtime,
        builder: (_, __) => const RealtimeScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerCalendar,
        builder: (_, __) => const CalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerEventTimeline,
        name: 'eventTimeline',
        builder: (_, state) => EventTimelineRoutePage(state: state),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('페이지를 찾을 수 없습니다: ${state.uri}'),
      ),
    ),
  );
}

class EntryGate extends ConsumerWidget {
  const EntryGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(appPrefsProvider);

    if (prefsAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (prefsAsync.hasError) {
      return const Scaffold(
        body: Center(child: Text("Preferences Load Error")),
      );
    }

    final prefs = prefsAsync.value!;
    final hasSeen = prefs.hasSeenOnboarding;
    final auto = prefs.autoLogin;
    final mode = prefs.mode;

    String next = AppRoutes.login;

    if (!hasSeen) {
      next = AppRoutes.onboarding;
    } else if (auto) {
      if (mode == null) {
        next = AppRoutes.modeSelect;
      } else if (mode == 'cam') {
        next = AppRoutes.cameraHome;
      } else if (mode == 'manager') {
        next = AppRoutes.managerHome;
      }
    } else {
      next = AppRoutes.login;
    }

    Future.microtask(() {
      if (context.mounted) context.go(next);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
