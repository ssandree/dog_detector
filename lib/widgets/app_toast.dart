import 'package:fluttertoast/fluttertoast.dart';
import '../core/index_export.dart';

/// Toast 메시지 통합 관리
/// fluttertoast 패키지를 사용하여 간단하고 효율적인 토스트 메시지를 제공합니다.
class AppToast {
  /// 성공 메시지 표시
  /// 녹색 배경의 성공 토스트 메시지를 표시합니다.
  static void success(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: 2,
    );
  }

  /// 에러 메시지 표시
  /// 빨간색 배경의 에러 토스트 메시지를 표시합니다.
  static void error(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
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
      backgroundColor: AppColors.AppBarColor,
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

