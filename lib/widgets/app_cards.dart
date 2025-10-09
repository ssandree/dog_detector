import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';

/// 앱 전체에서 사용할 기본 카드 위젯들
class AppCards {
  /// 기본 카드
  static Widget basic({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      margin: margin ?? AppConstants.defaultPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.largeBorderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? AppConstants.defaultPadding,
        child: child,
      ),
    );
  }

  /// 분석 결과 카드
  static Widget analysisResult({
    required String title,
    required List<Widget> children,
    Color? titleColor,
  }) {
    return basic(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.titleFontSize - 4,
              fontWeight: FontWeight.bold,
              color: titleColor ?? AppColors.analysisResultTitleColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          ...children,
        ],
      ),
    );
  }

  /// 알림 카드
  static Widget alert({
    required String message,
    required IconData icon,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return basic(
      backgroundColor: backgroundColor ?? AppColors.green1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor ?? AppColors.green5,
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius - 2),
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: AppConstants.defaultIconSize - 8,
              ),
            ),
            const SizedBox(width: AppConstants.defaultSpacing - 4),
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
      ),
    );
  }

  /// 비디오 플레이어 카드
  static Widget videoPlayer({
    required Widget child,
    String? liveBadgeText,
    List<Widget>? overlayWidgets,
  }) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultSpacing),
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.grey3,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey2,
              borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
            ),
            child: child,
          ),
          if (liveBadgeText != null)
            Positioned(
              top: AppConstants.defaultSpacing,
              right: AppConstants.defaultSpacing,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultSpacing - 4,
                  vertical: AppConstants.smallSpacing,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppConstants.circularBorderRadius - 30),
                ),
                child: Text(
                  liveBadgeText,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: AppConstants.smallFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (overlayWidgets != null) ...overlayWidgets,
        ],
      ),
    );
  }
}
