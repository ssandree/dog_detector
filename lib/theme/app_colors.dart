import 'package:flutter/material.dart';

class AppColors {
  // 베이지
  static const Color beige1 = Color(0xFFFFF8ED);
  static const Color beige2 = Color(0xFFD9CBA8);
  static const Color beige3 = Color(0xFFC6B58A);
  static const Color beige4 = Color(0xFFAB9762);
  static const Color beige5 = Color(0xFF816A36);

  // 코랄
  static const Color coral1 = Color(0xFFFFEFEA);
  static const Color coral2 = Color(0xFFF3C9BA);
  static const Color coral3 = Color(0xFFF3C9BA);
  static const Color coral4 = Color(0xFFE9967A);
  static const Color coral5 = Color(0xFFDA8061);

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

  // AppBar 색상
  static const Color primaryAppBarColor = beige4;    // 매니저모드
  static const Color secondaryAppBarColor = coral4;  // 캠모드
  static const Color whiteAppBarColor = white;
  static const Color greyAppBarColor = grey2;
  
  // AppBar 텍스트 색상
  static const Color whiteAppBarTextColor = white;
  static const Color blackAppBarTextColor = black;
  
  // 배경색
  static const Color defaultBackgroundColor = grey2;
  static const Color whiteBackgroundColor = white;
  

  // UI 요소 색상
  static const Color primaryButtonColor = primaryAppBarColor;
  static const Color secondaryButtonColor = secondaryAppBarColor;
  static const Color analysisResultTitleColor = secondaryAppBarColor;
  static const Color painStatusColor = secondaryAppBarColor;
  static const Color emotionStatusColor = primaryAppBarColor;
  static const Color activityStatusColor = Color(0xFFFF9800);

  // 버튼 상태 색상
  static const Color buttonNormal = green2;      // 일반버튼 배경색
  static const Color buttonPressed = green4;      // 눌린버튼 배경색
  static const Color buttonDisabled = grey2;      // 비활성버튼 배경색
  static const Color buttonOutline = green4;      // 테두리버튼 테두리색

  // 상태 태그 색상
  static const Color tagGood = green2;            // 좋음 - 연한 녹색
  static const Color tagNormal = coral3;          // 보통 - 코랄색
  static const Color tagBad = coral4;             // 나쁨 - 진한 코랄색
  static const Color tagPain = coral5;            // 아픔 - 가장 진한 코랄색
  static const Color tagDefault = grey4;          // 기본 태그 - 회색

  //캘린더 비율 색상
  static const List<Color> blended = [
    Color(0xFF71AF46), // 0%
    Color(0xFF82B553), // 10%
    Color(0xFF94BB60), // 20%
    Color(0xFFA6C26E), // 30%
    Color(0xFFB7C87B), // 40%
    Color(0xFFC9CE88), // 50%
    Color(0xFFDAC496), // 60%
    Color(0xFFE0B9A0), // 70%
    Color(0xFFE5AD9D), // 80%
    Color(0xFFEA9F8B), // 90%
    Color(0xFFD9967A), // 100%
  ];
}
