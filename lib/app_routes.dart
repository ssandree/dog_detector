import 'package:flutter/material.dart';

// Mode Selection
import 'screens/mode_selection/mode_select_screen.dart';

// Camera Mode
import 'screens/camera_mode/camera_home_screen.dart' as camera_home;

// Manager Mode Tabs
import 'screens/manager_mode/(tabs)/manager_home_screen.dart' as manager_home;

class AppRoutes {
  // 라우트 이름 정의
  static const String modeSelect = '/';
  static const String cameraHome = '/camera/home';
  static const String managerHome = '/manager/home';

  // 라우트 매핑
  static Map<String, WidgetBuilder> get routes => {
        // Mode Selection
        modeSelect: (context) => const ModeSelectScreen(),

        // Camera Mode
        cameraHome: (context) => const camera_home.HomeScreen(),

        // Manager Mode
        managerHome: (context) => const manager_home.HomeScreen(),
      };
}
