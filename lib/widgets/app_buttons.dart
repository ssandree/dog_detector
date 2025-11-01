import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../core/index_export.dart';

/// 앱 전체에서 사용할 기본 버튼 위젯들
class AppButtons {
  // ========== 공통 헬퍼 메서드 ==========
  
  /// 기본 버튼 구조를 생성하는 공통 메서드
  static Widget _buildButton({
    required double? width,
    required double height,
    required VoidCallback? onPressed,
    required ButtonStyle style,
    required Widget child,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );
  }

  /// 로딩 인디케이터를 생성하는 공통 메서드
  /// loading_animation_widget 패키지로 버튼 내부에서 띄우는 용도
  static Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 20,
      height: 20,
      child: LoadingAnimationWidget.threeArchedCircle(
        color: AppColors.black,
        size: 20,
      ),
    );
  }

  /// 일반 버튼용 child 콘텐츠 (Row 레이아웃)
  static Widget _buildStandardChild({
    required String text,
    IconData? icon,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    final textWidget = Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? AppConstants.defaultFontSize,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: textColor,
        shadows: [],
      ),
    );
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppConstants.defaultIconSize),
          const SizedBox(width: AppConstants.smallSpacing),
          textWidget,
        ],
      );
    }
    return textWidget;
  }


// ========== 버튼 위젯들 ==========
  /// 일반 버튼, 눌린 버튼, 비활성 버튼, 테두리만 있는 버튼 있음

  /// 일반 버튼 (연한 녹색 배경)
  static Widget normal({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = 56.0,
    Color? backgroundColor,
  }) {
    return _buildButton(
      width: width,
      height: height,
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.buttonNormal,
        foregroundColor: AppColors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      child: isLoading
        ? _buildLoadingIndicator()
        : _buildStandardChild(text: text, icon: icon),
    );
  }

  /// 눌린 버튼 (진한 녹색 배경)
  static Widget pressed({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = 56.0,
  }) {
    return _buildButton(
      width: width,
      height: height,
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPressed,
        foregroundColor: AppColors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      child: isLoading
        ? _buildLoadingIndicator()
        : _buildStandardChild(text: text, icon: icon),
    );
  }

  /// 비활성 버튼 (연한 회색 배경)
  static Widget disabled({
    required String text,
    IconData? icon,
    double? width,
    double height = 56.0,
  }) {
    return _buildButton(
      width: width,
      height: height,
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonDisabled,
        foregroundColor: AppColors.grey6,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      child: _buildStandardChild(
        text: text,
        icon: icon,
        textColor: AppColors.grey6,
      ),
    );
  }

  /// Primary 버튼 (primary 색상 배경)
  static Widget primary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = 56.0,
    Color? backgroundColor,
  }) {
    return _buildButton(
      width: width,
      height: height,
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.AppBarColor,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      child: isLoading
        ? _buildLoadingIndicator()
        : _buildStandardChild(
            text: text,
            icon: icon,
            textColor: AppColors.white,
          ),
    );
  }

  /// 테두리만 있는 버튼 (흰색 배경에 녹색 테두리)
  static Widget outline({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = 56.0,
    Color? borderColor,
    Color? textColor,
  }) {
    return _buildButton(
      width: width,
      height: height,
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: textColor ?? AppColors.black,
        side: BorderSide(
          color: borderColor ?? AppColors.buttonOutline,
          width: 2,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      child: isLoading
        ? _buildLoadingIndicator()
        : _buildStandardChild(
            text: text,
            icon: icon,
            textColor: textColor ?? AppColors.black,
          ),
    );
  }

}
