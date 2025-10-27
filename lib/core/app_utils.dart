import 'package:flutter/material.dart';


/// 앱 전체에서 사용할 유틸리티 함수들
class AppUtils {
  /// 표준 SnackBar 표시
  static Future<void> showSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
    await Future.delayed(duration); // 스낵바 표시 시간만큼 대기
  }

  /// 준비 중 메시지 표시
  static void showComingSoonMessage(BuildContext context, {String? feature}) {
    showSnackBar(
      context,
      message: feature != null ? '$feature 기능은 준비 중입니다' : '기능은 준비 중입니다',
    );
  }

  /// 페이지 이동 (push)
  static Future<T?> navigateTo<T extends Object?>(
    BuildContext context,
    Widget page, {
    bool replace = false,
  }) {
    if (replace) {
      return Navigator.pushReplacement<T, dynamic>(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } else {
      return Navigator.push<T>(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  /// 모달 페이지 이동 (투명 배경)
  static Future<T?> navigateToModal<T extends Object?>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  /// 로딩 다이얼로그 표시
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }

  /// 로딩 다이얼로그 숨기기
  static Future<void> hideLoadingDialog(BuildContext context) async {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  /// 확인 다이얼로그 표시
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
