import 'package:flutter/material.dart';

// Main Screen
import '../screens/main/main_screen.dart';


// Camera Mode
import '../screens/camera_mode/camera_home_screen.dart' as camera;

// Manager Mode Tabs
import '../screens/manager_mode/(tabs)/manager_home_screen.dart' as manager_home;
import '../screens/manager_mode/home/manager_home_screen.dart' as manager;


class AppRoutes {
  // 라우트 이름 정의
  static const String main = '/';
  static const String cameraHome = '/camera/home';
  static const String managerHome = '/manager/home';

  // 라우트 매핑
  static Map<String, WidgetBuilder> get routes => {
        // Main Screen (첫 화면)
        main: (context) => const MainScreen(),


        // Camera Mode
        cameraHome: (context) => const camera.HomeScreen(),

        // Manager Mode
        managerHome: (context) => const manager.HomeScreen(),
      };
}
