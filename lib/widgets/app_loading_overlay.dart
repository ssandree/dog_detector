import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../core/index_export.dart';

/// 전역 로딩 오버레이 관리
class AppLoadingOverlay {
  static bool _isShowing = false;

  /// 로딩 오버레이 표시
  /// loading_animation_widget 패키지를 사용한 아름다운 로딩 애니메이션을 표시합니다.
  /// [message]: 로딩 메시지 (선택사항)
  /// [color]: 로딩 애니메이션 색상 (기본값: AppColors.green6)
  /// [size]: 로딩 애니메이션 크기 (기본값: 50.0)
  static void show(
    BuildContext context, {
    String? message,
    Color? color,
    double? size,
  }) {
    if (_isShowing) return; // 중복 호출 방지
    
    _isShowing = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => LoadingDialog(
        message: message,
        color: color,
        size: size,
      ),
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
  /// [action]: 실행할 비동기 작업
  /// [loadingMessage]: 로딩 중 표시할 메시지 (선택사항)
  /// [onError]: 에러 발생 시 호출할 콜백 (선택사항)
  /// [color]: 로딩 애니메이션 색상 (선택사항)
  /// [size]: 로딩 애니메이션 크기 (선택사항)
  static Future<T?> executeWithLoading<T>({
    required BuildContext context,
    required Future<T> Function() action,
    String? loadingMessage,
    VoidCallback? onError,
    Color? color,
    double? size,
  }) async {
    try {
      show(context, message: loadingMessage, color: color, size: size);
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
/// loading_animation_widget 패키지를 사용하여 다양한 애니메이션 효과를 제공합니다.
class LoadingDialog extends StatelessWidget {
  /// 로딩 메시지 (선택사항)
  final String? message;

  /// 로딩 애니메이션 색상
  final Color? color;

  /// 로딩 애니메이션 크기
  final double? size;

  const LoadingDialog({
    super.key,
    this.message,
    this.color,
    this.size,
  });

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
              // loading_animation_widget 패키지의 다양한 로딩 애니메이션 사용
              // LoadingAnimationWidget.staggeredDotsWave는 파도 효과를 제공합니다.
              LoadingAnimationWidget.staggeredDotsWave(
                color: color ?? AppColors.green6,
                size: size ?? 50.0,
              ),
              if (message != null) ...[
                AppConstants.h16,
                Text(
                  message!,
                  style: const TextStyle(
                    fontSize: AppConstants.defaultFontSize,
                    color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

