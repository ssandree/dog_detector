import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../core/index_export.dart';

/// Dialog 통합 관리
/// awesome_dialog 패키지를 사용하여 더 풍부하고 아름다운 다이얼로그를 제공합니다.
class AppDialog {
  /// 확인 다이얼로그
  /// 확인/취소 버튼이 있는 질문 다이얼로그입니다.
  /// awesome_dialog의 DialogType.question을 사용합니다.
  /// [context]: BuildContext
  /// [title]: 다이얼로그 제목
  /// [message]: 다이얼로그 메시지
  /// [confirmText]: 확인 버튼 텍스트 (기본값: '확인')
  /// [cancelText]: 취소 버튼 텍스트 (기본값: '취소')
  /// [onConfirm]: 확인 버튼 클릭 시 호출되는 콜백
  /// [onCancel]: 취소 버튼 클릭 시 호출되는 콜백
  /// 반환값: true(확인), false(취소), null(다이얼로그가 닫힘)
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    // Completer를 사용하여 콜백 기반의 awesome_dialog를 Future로 변환
    final Completer<bool?> completer = Completer<bool?>();
    
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: confirmText ?? '확인',
      btnCancelText: cancelText ?? '취소',
      btnOkColor: AppColors.green6,
      btnCancelColor: AppColors.grey6,
      btnOkOnPress: () {
        // 확인 버튼 클릭 시
        if (!completer.isCompleted) {
          completer.complete(true);
        }
        onConfirm?.call();
      },
      btnCancelOnPress: () {
        // 취소 버튼 클릭 시
        if (!completer.isCompleted) {
          completer.complete(false);
        }
        onCancel?.call();
      },
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();

    // Future가 완료될 때까지 대기하고 결과 반환
    return completer.future;
  }

  /// 알림 다이얼로그
  /// 정보를 알리는 단순 알림 다이얼로그입니다.
  /// awesome_dialog의 DialogType.info를 사용합니다.
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onClose,
  }) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: buttonText ?? '확인',
      btnOkColor: AppColors.green6,
      btnOkOnPress: () {
        onClose?.call();
      },
      dismissOnTouchOutside: true,
      dismissOnBackKeyPress: true,
    ).show();
  }

  /// 성공 다이얼로그
  /// 작업이 성공적으로 완료되었음을 알리는 다이얼로그입니다.
  /// awesome_dialog의 DialogType.success를 사용합니다.
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onClose,
  }) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: buttonText ?? '확인',
      btnOkColor: AppColors.green6,
      btnOkOnPress: () {
        onClose?.call();
      },
      dismissOnTouchOutside: true,
      dismissOnBackKeyPress: true,
    ).show();
  }

  /// 에러 다이얼로그
  /// 오류가 발생했음을 알리는 다이얼로그입니다.
  /// awesome_dialog의 DialogType.error를 사용합니다.
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onClose,
  }) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: buttonText ?? '확인',
      btnOkColor: AppColors.errorRed,
      btnOkOnPress: () {
        onClose?.call();
      },
      dismissOnTouchOutside: true,
      dismissOnBackKeyPress: true,
    ).show();
  }

  /// 경고 다이얼로그
  /// 주의가 필요한 상황을 알리는 다이얼로그입니다.
  /// awesome_dialog의 DialogType.warning를 사용합니다.
  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onClose,
  }) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: buttonText ?? '확인',
      btnOkColor: Colors.orange,
      btnOkOnPress: () {
        onClose?.call();
      },
      dismissOnTouchOutside: true,
      dismissOnBackKeyPress: true,
    ).show();
  }

  /// 커스텀 다이얼로그
  /// 완전히 커스텀 가능한 다이얼로그를 표시합니다.
  /// awesome_dialog의 body 속성을 사용하여 커스텀 위젯을 표시할 수 있습니다.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    String? title,
  }) async {
    T? result;
    
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      body: child,
      dismissOnTouchOutside: barrierDismissible,
      dismissOnBackKeyPress: barrierDismissible,
    ).show();

    return result;
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

