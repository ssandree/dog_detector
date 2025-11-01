import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 상수값들을 정의합니다.
class AppConstants {
  // AppBar 관련 상수
    static const double appBarHeight = 65.0;
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

    // SizedBox 상수 (간격 위젯)
    // height 간격
    static const SizedBox h4 = SizedBox(height: 4);
    static const SizedBox h6 = SizedBox(height: 6);
    static const SizedBox h8 = SizedBox(height: 8);
    static const SizedBox h12 = SizedBox(height: 12);
    static const SizedBox h16 = SizedBox(height: 16);
    static const SizedBox h20 = SizedBox(height: 20);
    static const SizedBox h24 = SizedBox(height: 24);
    static const SizedBox h32 = SizedBox(height: 32);
    
    // width 간격
    static const SizedBox w4 = SizedBox(width: 4);
    static const SizedBox w6 = SizedBox(width: 6);
    static const SizedBox w8 = SizedBox(width: 8);
    static const SizedBox w12 = SizedBox(width: 12);
    static const SizedBox w16 = SizedBox(width: 16);
    static const SizedBox w20 = SizedBox(width: 20);
    static const SizedBox w24 = SizedBox(width: 24);
}
