// lib/core/config/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFbd9c68);

  static const textPrimary = Colors.black87;
  static const textSecondary = Color(0xFF777777);

  static const background = Colors.white;

    // 베이지
  static const Color beige1 = Color(0xFFccbe9d);
  static const Color beige2 = Color(0xFFe3caa3);
  static const Color beige3 = Color(0xFFcfb182);
  static const Color beige4 = Color(0xFFbd9c68);
  static const Color beige5 = Color(0xFFa1804d);

  // 코랄
  static const Color coral1 = Color(0xFFdea28c);
  static const Color coral2 = Color(0xFFd48368);
  static const Color coral3 = Color(0xFFCD785B);
  static const Color coral4 = Color(0xFFb56b53);
  static const Color coral5 = Color(0xFFa85d45);
  static const Color coral6 = Color(0xFF9b4f37);

  // 초록색
  static const Color green1 = Color(0xFFEAF7D8);
  static const Color green2 = Color(0xFFBAE7A1);
  static const Color green3 = Color(0xFFB1D784);
  static const Color green4 = Color(0xFF8FC760);
  static const Color green5 = Color(0xFF71AF46);
  static const Color green6 = Color(0xFF529027);
  static const Color green7 = Color(0xFF3E6E19);
  static const Color green8 = Color(0xFF2C4F11);

  // 흑백 계열
  static const Color grey1 = Color(0xFFF7F7F7);
  static const Color grey2 = Color(0xFFF0F0F0);
  static const Color grey3 = Color(0xFFE7E7E7);
  static const Color grey4 = Color(0xFFD0D0D0);
  static const Color grey5 = Color(0xFFB7B7B7);
  static const Color grey6 = Color(0xFF9D9D9D);
  static const Color grey7 = Color(0xFF848484);
  static const Color grey8 = Color(0xFF636363);
  static const Color grey9 = Color(0xFF414141);
  static const Color grey12 = Color(0xFF1D1D1D);

  // 기본 색상
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // 상태/알림 색
  static const Color good = Color(0xFF898CEC);
  static const Color success = Color(0xFFBFD138);
  static const Color medium = Color(0xFFF0C75F);
  static const Color warning = Color(0xFFD86E4A);
  static const Color error = Color(0xFFC74B21);

  // BottomNavigationBar 색상
  static const Color bottomNavSelectedColor = beige5;
  static const Color bottomNavUnselectedColor = grey6;
  
  // 에러/경고 색상 (표준 색상)
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color warningRed = Color(0xFFFF0000);

  //캘린더 비율 색상
  static final List<Color> blended = [
    Color(0xFF71AF46).withOpacity(0.5), // 0%
    Color(0xFF82B553).withOpacity(0.5), // 10%
    Color(0xFF94BB60).withOpacity(0.5), // 20%
    Color(0xFFA6C26E).withOpacity(0.5), // 30%
    Color(0xFFB7C87B).withOpacity(0.5), // 40%
    Color(0xFFC9CE88).withOpacity(0.5), // 50%
    Color(0xFFDAC496).withOpacity(0.5), // 60%
    Color(0xFFDDBF9C).withOpacity(0.5), // 65%
    Color(0xFFE0B9A0).withOpacity(0.5), // 70%
    Color(0xFFE3B3A1).withOpacity(0.5), // 75%
    Color(0xFFE5AD9D).withOpacity(0.5), // 80%
    Color(0xFFE8A894).withOpacity(0.5), // 85%
    Color(0xFFEA9F8B).withOpacity(0.5), // 90%
    Color(0xFFE39D7F).withOpacity(0.5), // 95%
    Color(0xFFD9967A).withOpacity(0.5), // 100%
  ];
}
