// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/routes/app_routes.dart';
import 'core/config/app_theme.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/storage/app_prefs_provider.dart';
import 'core/storage/prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefsService().init();

  final container = ProviderContainer();

  await container.read(secureStorageServiceProvider).deleteToken();
  await container.read(appPrefsProvider.notifier).setAccessToken(null);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DogTelepathyApp(),
    ),
  );
}

class DogTelepathyApp extends StatelessWidget {
  const DogTelepathyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: AppTheme.light,
        );
      },
    );
  }
}
