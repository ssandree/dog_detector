import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../app_constants.dart';
import '../exceptions.dart';

/// Toast 메시지 통합 관리
/// 
/// 표준화된 Toast 메시지 표시 규칙:
/// - success: 성공 작업 (녹색)
/// - error: 에러 발생 (빨간색) - AppException을 자동으로 처리
/// - warning: 경고 메시지 (주황색)
/// - info: 정보 메시지 (기본 색상)
/// 
/// 커스텀 Overlay를 사용하여 완전히 제어 가능한 토스트 메시지를 제공합니다.
class AppToast {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  /// 토스트 메시지 표시 (내부 메서드)
  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    int durationSeconds = 2,
  }) {
    // 기존 토스트가 있으면 제거
    _hide();

    final overlayState = Overlay.of(context);
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
    );

    overlayState.insert(_overlayEntry!);

    // 지정된 시간 후 자동으로 제거
    _timer = Timer(Duration(seconds: durationSeconds), () {
      _hide();
    });
  }

  /// 토스트 메시지 숨기기
  static void _hide() {
    _timer?.cancel();
    _timer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// 성공 메시지 표시
  /// 녹색 배경의 성공 토스트 메시지를 표시합니다.
  static void success(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.green5,
      textColor: Colors.white,
    );
  }

  /// 에러 메시지 표시
  /// 
  /// [error]: 에러 객체 (AppException 또는 일반 Exception)
  /// [message]: 커스텀 메시지 (null이면 error에서 자동 추출)
  /// 
  /// AppException인 경우 메시지를 자동으로 추출하고,
  /// 일반 Exception인 경우 기본 메시지를 표시합니다.
  static void error(BuildContext context, dynamic error, [String? message]) {
    String errorMessage;
    
    if (error is AppException) {
      errorMessage = message ?? error.message;
    } else if (message != null) {
      errorMessage = message;
    } else {
      errorMessage = '오류가 발생했습니다. 다시 시도해주세요.';
    }
    
    _show(
      context: context,
      message: errorMessage,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }

  /// 경고 메시지 표시
  /// 주황색 배경의 경고 토스트 메시지를 표시합니다.
  static void warning(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  /// 정보 메시지 표시
  /// 앱의 primary 색상을 배경으로 한 정보 토스트 메시지를 표시합니다.
  static void info(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.beige4,
      textColor: Colors.white,
    );
  }

  /// 커스텀 토스트 메시지 표시
  /// 색상, 위치, 지속 시간 등을 커스터마이징할 수 있습니다.
  static void custom({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    int? durationSeconds,
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: backgroundColor ?? Colors.grey.shade800,
      textColor: textColor ?? Colors.white,
      durationSeconds: durationSeconds ?? 2,
    );
  }

  /// "곧 출시됩니다" 메시지 (기존 AppUtils 기능 유지)
  /// 특정 기능이 아직 출시되지 않았음을 알리는 토스트 메시지입니다.
  static void comingSoon(BuildContext context, String feature) {
    _show(
      context: context,
      message: '$feature 기능은 곧 출시됩니다!',
      backgroundColor: Colors.grey.shade700,
      textColor: Colors.white,
    );
  }
}

/// 토스트 위젯
class _ToastWidget extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;

  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final toastWidth = screenWidth * 0.8; // 화면 너비의 90% (150%가 아닌 90%로 설정, 필요시 조정 가능)

    return Positioned(
      bottom: 80, // 화면 하단에서 80px 위에 위치
      left: (screenWidth - toastWidth) / 2, // 중앙 정렬
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: toastWidth,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: textColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
