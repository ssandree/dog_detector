import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 상수값들을 정의합니다.
class AppConstants {
  // AppBar 관련 상수
    static const double appBarHeight = 60.0;
    static const double appBarElevation = 0.0;
    static const bool appBarCenterTitle = true;
    static const double appBarTitleFontSize = 18.0;
    static const double appBarIconSize = 20.0;
    
    // SafeArea 및 Padding 관련 상수
    static const EdgeInsets defaultPadding = EdgeInsets.zero;
    static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(horizontal: 24.0);
    static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: 24.0);
    static const EdgeInsets smallPadding = EdgeInsets.all(16.0);
    static const EdgeInsets largePadding = EdgeInsets.all(32.0);
    static const EdgeInsets modeSelectPadding = EdgeInsets.symmetric(horizontal: 40.0);
    static const EdgeInsets cameraSettingPadding = EdgeInsets.all(20.0);
    
    // 간격 상수
    static const double defaultSpacing = 16.0;
    static const double smallSpacing = 8.0;
    static const double largeSpacing = 24.0;
    static const double extraLargeSpacing = 32.0;
    
    // 아이콘 크기
    static const double defaultIconSize = 24.0;
    static const double smallIconSize = 16.0;
    static const double largeIconSize = 32.0;
    
    // 텍스트 스타일 관련
    static const double defaultFontSize = 16.0;
    static const double titleFontSize = 24.0;
    static const double largeTitleFontSize = 36.0;
    static const double smallFontSize = 12.0;
    
    // 애니메이션 지속시간
    static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
    static const Duration fastAnimationDuration = Duration(milliseconds: 150);
    static const Duration slowAnimationDuration = Duration(milliseconds: 500);
    
    // BorderRadius
    static const double defaultBorderRadius = 12.0;
    static const double smallBorderRadius = 8.0;
    static const double largeBorderRadius = 16.0;
    static const double circularBorderRadius = 50.0;

    // 라우트 이름 상수
    static const String routeMain = '/';
    static const String routeModeSelect = '/mode-select';
    static const String routeCameraHome = '/camera-home';
    static const String routeCameraSetting = '/camera-setting';
    static const String routeManagerHome = '/manager-home';
    static const String routeRealtime = '/realtime';
    static const String routeReport = '/report';
    static const String routeCalendar = '/calendar';
    static const String routeDailyReport = '/daily-report';
    static const String routeWeeklyReport = '/weekly-report';
    static const String routeMonthlyReport = '/monthly-report';
}
