import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 앱 전체 테마 설정
/// Flutter MaterialApp에 필요한 최소 설정만 포함했음
/// 실제 UI 요소는 AppColors, AppButtons, BaseScaffold 등에서 관리

class AppTheme {
  /// 라이트 테마 설정
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.notoSansKrTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.beige4,
        onPrimary: AppColors.white,
        secondary: AppColors.coral3,
        onSecondary: AppColors.white,
        background: AppColors.white,
        onBackground: AppColors.grey12,
        surface: AppColors.white,
        onSurface: AppColors.grey12,
        error: AppColors.errorRed,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.white,
      textTheme: baseTextTheme.copyWith(
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.grey12,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.grey12,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.grey9,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.grey8,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          color: AppColors.grey7,
        ),
      ),
      fontFamily: GoogleFonts.notoSansKr().fontFamily,
    );
  }
}