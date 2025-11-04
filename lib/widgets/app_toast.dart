import 'package:fluttertoast/fluttertoast.dart';
import '../core/index_export.dart';
import '../core/exceptions.dart';

/// Toast 메시지 통합 관리
/// 
/// 표준화된 Toast 메시지 표시 규칙:
/// - success: 성공 작업 (녹색)
/// - error: 에러 발생 (빨간색) - AppException을 자동으로 처리
/// - warning: 경고 메시지 (주황색)
/// - info: 정보 메시지 (기본 색상)
/// 
/// fluttertoast 패키지를 사용하여 간단하고 효율적인 토스트 메시지를 제공합니다.
class AppToast {
  /// 성공 메시지 표시
  /// 녹색 배경의 성공 토스트 메시지를 표시합니다.
  static void success(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.green5,
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: 2,
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
    
    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: 2,
    );
  }

  /// 경고 메시지 표시
  /// 주황색 배경의 경고 토스트 메시지를 표시합니다.
  static void warning(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: 2,
    );
  }

  /// 정보 메시지 표시
  /// 앱의 primary 색상을 배경으로 한 정보 토스트 메시지를 표시합니다.
  static void info(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.appBarColor,
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: 2,
    );
  }

  /// 커스텀 토스트 메시지 표시
  /// 색상, 위치, 지속 시간 등을 커스터마이징할 수 있습니다.
  static void custom({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    ToastGravity? gravity,
    Toast? length,
    int? timeInSecForIosWeb,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length ?? Toast.LENGTH_SHORT,
      gravity: gravity ?? ToastGravity.BOTTOM,
      backgroundColor: backgroundColor ?? Colors.grey[800],
      textColor: textColor ?? Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: timeInSecForIosWeb ?? 2,
    );
  }

  /// "곧 출시됩니다" 메시지 (기존 AppUtils 기능 유지)
  /// 특정 기능이 아직 출시되지 않았음을 알리는 토스트 메시지입니다.
  static void comingSoon(BuildContext context, String feature) {
    Fluttertoast.showToast(
      msg: '$feature 기능은 곧 출시됩니다!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: 2,
    );
  }
}

