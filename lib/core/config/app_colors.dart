// lib/core/config/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFBD9C68);

  static const white = Colors.white;
  static const black = Colors.black;

  static const textPrimary = Colors.black87;
  static const textSecondary = Color(0xFF777777);

  static const background = Colors.white;

  static const grey1 = Color(0xFFF9FAFB);
  static const grey2 = Color(0xFFF3F4F6);
  static const grey3 = Color(0xFFE5E7EB);
  static const grey4 = Color(0xFFD1D5DB);
  static const grey5 = Color(0xFF9CA3AF);
  static const grey6 = Color(0xFF6B7280);
  static const grey7 = Color(0xFF4B5563);
  static const grey8 = Color(0xFF374151);
  static const grey9 = Color(0xFF1F2933);
  static const grey10 = Color(0xFF111827);
  static const grey11 = Color(0xFF0B1220);
  static const grey12 = Color(0xFF020617);

  static const green1 = Color(0xFFE6F9ED);
  static const green2 = Color(0xFFC4F1D5);
  static const green3 = Color(0xFF8FE4AF);
  static const green4 = Color(0xFF4AD38A);
  static const green5 = Color(0xFF16A34A);
  static const green6 = Color(0xFF166534);
  static const green7 = Color(0xFF1E9D4E);
  static const green8 = Color(0xFF0A6F34);

  static const coral1 = Color(0xFFFFF1F1);
  static const coral2 = Color(0xFFFFDCDC);
  static const coral3 = Color(0xFFFFB3B3);
  static const coral4 = Color(0xFFFF8C8C);
  static const coral5 = Color(0xFFFF5F5F);
  static const coral6 = Color(0xFFDB3C3C);
  static const coral7 = Color(0xFFB82929);
  static const coral8 = Color(0xFF8C1C1C);

  static const beige1 = Color(0xFFFFF7ED);
  static const beige2 = Color(0xFFFDE7C7);
  static const beige3 = Color(0xFFF4D7AB);
  static const beige4 = Color(0xFFE8C48D);
  static const beige5 = Color(0xFFa1804d);

  static const info = Color(0xFF0EA5E9);
  
  // 상태/알림 색
  static const Color good = Color(0xFF898CEC);
  static const Color success = Color(0xFFBFD138);
  static const Color medium = Color(0xFFF0C75F);
  static const Color warning = Color(0xFFD86E4A);
  static const Color error = Color(0xFFC74B21);

  // BottomNavigationBar 색상
  static const bottomNavSelectedColor = beige5;
  static const bottomNavUnselectedColor = grey6;
  
  // 에러/경고 색상 (표준 색상)
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color warningRed = Color(0xFFFF0000);

  //캘린더 비율 색상
  static final List<Color> blended = [
    Color(0xFF71AF46).withValues(alpha: 0.5), // 0%
    Color(0xFF82B553).withValues(alpha: 0.5), // 10%
    Color(0xFF94BB60).withValues(alpha: 0.5), // 20%
    Color(0xFFA6C26E).withValues(alpha: 0.5), // 30%
    Color(0xFFB7C87B).withValues(alpha: 0.5), // 40%
    Color(0xFFC9CE88).withValues(alpha: 0.5), // 50%
    Color(0xFFDAC496).withValues(alpha: 0.5), // 60%
    Color(0xFFDDBF9C).withValues(alpha: 0.5), // 65%
    Color(0xFFE0B9A0).withValues(alpha: 0.5), // 70%
    Color(0xFFE3B3A1).withValues(alpha: 0.5), // 75%
    Color(0xFFE5AD9D).withValues(alpha: 0.5), // 80%
    Color(0xFFE8A894).withValues(alpha: 0.5), // 85%
    Color(0xFFEA9F8B).withValues(alpha: 0.5), // 90%
    Color(0xFFE39D7F).withValues(alpha: 0.5), // 95%
    Color(0xFFD9967A).withValues(alpha: 0.5), // 100%
  ];
}
