import 'package:flutter/material.dart';
import '../core/index_export.dart';

/// 전역 로딩 오버레이 관리
class AppLoadingOverlay {
  static bool _isShowing = false;

  static void show(BuildContext context, {String? message}) {
    if (_isShowing) return; // 중복 호출 방지
    
    _isShowing = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => LoadingDialog(message: message),
    ).then((_) {
      _isShowing = false;
    }).catchError((_) {
      _isShowing = false;
    });
  }

  static void hide(BuildContext context) {
    if (!_isShowing) return; // 이미 닫혀있는 경우 무시
    
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      _isShowing = false;
    }
  }

  /// 동기식으로 특정 작업을 실행하고 로딩 표시
  static Future<T?> executeWithLoading<T>({
    required BuildContext context,
    required Future<T> Function() action,
    String? loadingMessage,
    VoidCallback? onError,
  }) async {
    try {
      show(context, message: loadingMessage);
      final result = await action();
      hide(context);
      return result;
    } catch (e) {
      hide(context);
      if (onError != null) {
        onError();
      }
      rethrow;
    }
  }
}

/// 로딩 다이얼로그
class LoadingDialog extends StatelessWidget {
  final String? message;

  const LoadingDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 뒤로가기 막기 (Flutter 3.12+ 방식)
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.green6),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: const TextStyle(
                    fontSize: AppConstants.defaultFontSize,
                    color: AppColors.black,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

