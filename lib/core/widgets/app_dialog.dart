import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// 범용 확인 다이얼로그를 표시합니다.
/// 
/// [context] - BuildContext
/// [title] - 다이얼로그 제목
/// [content] - 다이얼로그 내용
/// [confirmText] - 확인 버튼 텍스트 (기본값: '확인')
/// [cancelText] - 취소 버튼 텍스트 (기본값: '취소')
/// [confirmColor] - 확인 버튼 배경색 (기본값: AppColors.errorRed)
/// [onConfirm] - 확인 버튼 클릭 시 콜백
/// [onCancel] - 취소 버튼 클릭 시 콜백 (선택적)
/// 
/// Returns `true` if user confirmed, `false` if cancelled, `null` if dismissed.
Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = '확인',
  String cancelText = '취소',
  Color? confirmColor,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.grey12,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.grey9,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    onCancel?.call();
                  },
                  child: Text(
                    cancelText,
                    style: const TextStyle(color: AppColors.grey8),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onConfirm?.call();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: confirmColor ?? AppColors.errorRed,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result;
}
