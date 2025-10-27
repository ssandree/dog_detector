import 'package:flutter/material.dart';
import '../core/index_export.dart';

/// Dialog 통합 관리
class AppDialog {
  /// 확인 다이얼로그
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: AppConstants.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              onCancel?.call();
            },
            child: Text(
              cancelText ?? '취소',
              style: TextStyle(color: AppColors.grey6),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              onConfirm?.call();
            },
            child: Text(
              confirmText ?? '확인',
              style: const TextStyle(
                color: AppColors.green6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    return result;
  }

  /// 알림 다이얼로그
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onClose,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: AppConstants.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onClose?.call();
            },
            child: Text(
              buttonText ?? '확인',
              style: const TextStyle(
                color: AppColors.green6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 커스텀 다이얼로그
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: child,
      ),
    );
  }

  /// 모달 시트 (바닥에서 올라오는 형태)
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool isScrollControlled = false,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.largeBorderRadius),
          ),
        ),
        child: child,
      ),
    );
  }
}

