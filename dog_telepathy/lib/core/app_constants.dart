import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 앱 전체에서 사용하는 상수값들을 정의합니다.
class AppConstants {

    // SafeArea 및 Padding 관련 상수
    static EdgeInsets get defaultPadding => EdgeInsets.all(24.w);
    static EdgeInsets get horizontalPadding => EdgeInsets.symmetric(horizontal: 24.w);
    static EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: 24.h);
    static EdgeInsets get smallPadding => EdgeInsets.all(16.w);
    static EdgeInsets get largePadding => EdgeInsets.all(32.w);
    static EdgeInsets get modeSelectPadding => EdgeInsets.symmetric(horizontal: 40.w);
    static EdgeInsets get cameraSettingPadding => EdgeInsets.all(20.w);
    
    // 간격 상수
    static double get smallSpacing => 8.h;
    static double get defaultSpacing => 16.h;
    static double get largeSpacing => 24.h;
    static double get extraLargeSpacing => 32.h;

    // SizedBox 상수 (간격 위젯)
    // height 간격
    static SizedBox get h4 => SizedBox(height: 4.h);
    static SizedBox get h6 => SizedBox(height: 6.h);
    static SizedBox get h8 => SizedBox(height: 8.h);
    static SizedBox get h12 => SizedBox(height: 12.h);
    static SizedBox get h16 => SizedBox(height: 16.h);
    static SizedBox get h20 => SizedBox(height: 20.h);
    static SizedBox get h24 => SizedBox(height: 24.h);
    static SizedBox get h32 => SizedBox(height: 32.h);
    
    // width 간격
    static SizedBox get w4 => SizedBox(width: 4.w);
    static SizedBox get w6 => SizedBox(width: 6.w);
    static SizedBox get w8 => SizedBox(width: 8.w);
    static SizedBox get w12 => SizedBox(width: 12.w);
    static SizedBox get w16 => SizedBox(width: 16.w);
    static SizedBox get w20 => SizedBox(width: 20.w);
    static SizedBox get w24 => SizedBox(width: 24.w);

    // 아이콘 크기
    static const double defaultIconSize = 24.0;
  
    
    // 텍스트 스타일 관련
    static const double smallFontSize = 12.0;
    static const double defaultFontSize = 16.0;
    static const double buttonFontSize = 16.0;
    static const double titleFontSize = 24.0;
    static const double largeTitleFontSize = 36.0;
    
    // 애니메이션 지속시간
    static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
    static const Duration fastAnimationDuration = Duration(milliseconds: 150);
    static const Duration slowAnimationDuration = Duration(milliseconds: 500);
    
    // BorderRadius
    static const double defaultBorderRadius = 12.0;
    static const double smallBorderRadius = 8.0;
    static const double largeBorderRadius = 16.0;
    static const double circularBorderRadius = 50.0;
}
