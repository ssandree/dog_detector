import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 앱 전체 테마 설정
/// Flutter MaterialApp에 필요한 최소 설정만 포함했음
/// 실제 UI 요소는 AppColors, AppButtons, BaseScaffold 등에서 관리

class AppTheme {
  /// 라이트 테마 설정
  static ThemeData get lightTheme {
    return ThemeData(
      // Material 3 디자인 시스템 사용
      useMaterial3: true,
      
      // 기본 배경색 (BaseScaffold에서도 사용 가능)
      scaffoldBackgroundColor: AppColors.white,
      
      // 폰트 설정 - Google Fonts Noto Sans KR 사용
      textTheme: GoogleFonts.notoSansKrTextTheme(),
      fontFamily: GoogleFonts.notoSansKr().fontFamily,
    );
  }
}