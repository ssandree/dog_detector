import 'package:flutter/material.dart';
import '../core/index_export.dart';

/// Toast 메시지 통합 관리
class AppToast {
  /// 성공 메시지 표시
  static void success(BuildContext context, String message) {
    _show(context, message, Colors.green, Icons.check_circle);
  }

  /// 에러 메시지 표시
  static void error(BuildContext context, String message) {
    _show(context, message, Colors.red, Icons.error);
  }

  /// 경고 메시지 표시
  static void warning(BuildContext context, String message) {
    _show(context, message, Colors.orange, Icons.warning);
  }

  /// 정보 메시지 표시
  static void info(BuildContext context, String message) {
    _show(context, message, AppColors.primaryAppBarColor, Icons.info);
  }

  /// 커스텀 SnackBar 표시
  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// "곧 출시됩니다" 메시지 (기존 AppUtils 기능 유지)
  static void comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 기능은 곧 출시됩니다!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

