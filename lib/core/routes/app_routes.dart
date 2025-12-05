// lib/core/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../storage/app_prefs_provider.dart';
import '../storage/secure_storage_service.dart';

import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/mode_select/mode_select_screen.dart';
import '../../features/cam/camera_main_screen.dart';
import '../../manager/manager_navigation.dart';
import '../../manager/calendar/calendar_screen.dart';
import '../../manager/event_timeline/event_timeline_screen.dart';
import '../../manager/notification/notification_screen.dart';
import '../../manager/realtime/realtime_screen.dart';
import '../../manager/today_report/today_report_screen.dart';


class AppRoutes {
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const modeSelect = '/mode-select';
  static const camera = '/camera';
  static const managerHome = '/manager';
  static const calendar = '/manager/calendar';
  static const eventTimeline = '/manager/timeline';
  static const notification = '/manager/notification';
  static const realtime = '/manager/realtime';
  static const todayReport = '/today-report';
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const EntryGate(),
    ),
    GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
    GoRoute(path: AppRoutes.signup, builder: (_, __) => const SignupScreen()),
    GoRoute(path: AppRoutes.modeSelect, builder: (_, __) => const ModeSelectScreen()),
    GoRoute(path: AppRoutes.camera, builder: (_, __) => const CameraMainScreen()),
    GoRoute(path: AppRoutes.managerHome, builder: (context, state) => MainNavigation(state: state)),
    GoRoute(path: AppRoutes.calendar, builder: (_, __) => const CalendarScreen()),
    GoRoute(path: AppRoutes.eventTimeline, builder: (context, state) => EventTimelineRoutePage(state: state)),
    GoRoute(path: AppRoutes.notification, builder: (_, __) => const NotificationScreen()),
    GoRoute(path: AppRoutes.realtime, builder: (_, __) => const RealtimeScreen()),
    GoRoute(path: AppRoutes.todayReport, builder: (_, __) => const TodayReportScreen()),
  ],
);


class EntryGate extends ConsumerWidget {
  const EntryGate({super.key});

  static bool _navigated = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(appPrefsProvider);

    if (prefsAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (prefsAsync.hasError) {
      return const Scaffold(body: Center(child: Text("Preferences Load Error")));
    }

    final prefs = prefsAsync.value!;

    return FutureBuilder(
      future: ref.read(secureStorageServiceProvider).readToken(),
      builder: (context, tokenSnapshot) {
        if (tokenSnapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final token = tokenSnapshot.data;
        final hasSeen = prefs.hasSeenOnboarding;
        final auto = prefs.autoLogin;
        final mode = prefs.mode;

        // 목적지 결정
        String next = AppRoutes.login;

        if (!hasSeen) {
          next = AppRoutes.onboarding;
        } else if (auto && token != null) {
          if (mode == null) {
            next = AppRoutes.modeSelect;
          } else if (mode == 'cam') {
            next = AppRoutes.camera;
          } else if (mode == 'manager') {
            next = AppRoutes.managerHome;
          }
        }

        // '/'에서만 단 1번 redirect
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_navigated && context.mounted) {
            _navigated = true;
            GoRouter.of(context).go(next);
          }
        });

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
