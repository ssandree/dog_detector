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
import '../../features/manager/manager_home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const EntryGate(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (_, __) => const SignupScreen(),
    ),
    GoRoute(
      path: '/mode-select',
      builder: (_, __) => const ModeSelectScreen(),
    ),
    GoRoute(
      path: '/camera',
      builder: (_, __) => const CameraMainScreen(),
    ),
    GoRoute(
      path: '/manager',
      builder: (_, __) => const ManagerHomeScreen(),
    ),
  ],
);

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

    return FutureBuilder(
      future: ref.read(secureStorageServiceProvider).readToken(),
      builder: (context, tokenSnapshot) {
        if (tokenSnapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = tokenSnapshot.data;
        final hasSeen = prefs.hasSeenOnboarding;
        final auto = prefs.autoLogin;
        final mode = prefs.mode;

        String next = '/login';

        if (!hasSeen) {
          next = '/onboarding';
        } else if (auto && token != null) {
          if (mode == null) {
            next = '/mode-select';
          } else if (mode == 'cam') {
            next = '/camera';
          } else if (mode == 'manager') {
            next = '/manager';
          }
        } else {
          next = '/login';
        }

        Future.microtask(() {
          if (context.mounted) context.go(next);
        });

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
