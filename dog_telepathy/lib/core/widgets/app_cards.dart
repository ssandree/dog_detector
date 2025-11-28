import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/app_colors.dart';
import '../app_constants.dart';

/// 앱 전체에서 사용할 기본 카드 위젯들
class AppCards {
  /// 기본 카드
  static Widget basic({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    double? borderRadius,
    BoxBorder? border,
  }) {
    return Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(AppConstants.defaultSpacing),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.defaultBorderRadius),
        border: border,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  /// 비디오 플레이어 카드
  static Widget videoPlayer({
    required Widget child,
    String? liveBadgeText,
    List<Widget>? overlayWidgets,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        child: Stack(
          children: [
            child,
            if (overlayWidgets != null) ...overlayWidgets,
          ],
        ),
      ),
    );
  }

  /// 알림 카드
  static Widget alert({
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(AppConstants.defaultSpacing),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.green1,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: iconColor ?? AppColors.green5,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(AppConstants.smallSpacing - 2.w),
              decoration: BoxDecoration(
                color: iconColor ?? AppColors.green5,
                borderRadius: BorderRadius.circular(AppConstants.smallSpacing - 2.w),
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: AppConstants.defaultSpacing,
              ),
            ),
            SizedBox(width: AppConstants.smallSpacing + 4.w),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: AppConstants.defaultFontSize,
                fontWeight: FontWeight.bold,
                color: textColor ?? AppColors.green8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
