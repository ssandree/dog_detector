import 'package:flutter/material.dart';


/// 앱 전체에서 사용할 유틸리티 함수들
class AppUtils {
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

  /// "곧 출시됩니다" 메시지 표시
  static void showComingSoonMessage(BuildContext context, {required String feature}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 기능은 곧 출시됩니다!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
