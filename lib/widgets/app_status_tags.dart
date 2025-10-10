import 'package:flutter/material.dart';
import '../core/index_export.dart';

/// 상태를 나타내는 태그 위젯들
class AppStatusTags {
  /// 기본 태그 (연한 회색 테두리)
  static Widget defaultTag({
    required String text,
    VoidCallback? onTap,
    EdgeInsets? padding,
  }) {
    return _buildTag(
      text: text,
      borderColor: AppColors.tagDefault,
      textColor: AppColors.black,
      onTap: onTap,
      padding: padding,
    );
  }

  /// 좋음 태그 (연한 녹색 테두리)
  static Widget good({
    required String text,
    VoidCallback? onTap,
    EdgeInsets? padding,
  }) {
    return _buildTag(
      text: text,
      borderColor: AppColors.tagGood,
      textColor: AppColors.black,
      onTap: onTap,
      padding: padding,
    );
  }

  /// 보통 태그 (연한 주황색 테두리)
  static Widget normal({
    required String text,
    VoidCallback? onTap,
    EdgeInsets? padding,
  }) {
    return _buildTag(
      text: text,
      borderColor: AppColors.tagNormal,
      textColor: AppColors.black,
      onTap: onTap,
      padding: padding,
    );
  }

  /// 나쁨 태그 (주황-빨강색 테두리)
  static Widget bad({
    required String text,
    VoidCallback? onTap,
    EdgeInsets? padding,
  }) {
    return _buildTag(
      text: text,
      borderColor: AppColors.tagBad,
      textColor: AppColors.black,
      onTap: onTap,
      padding: padding,
    );
  }

  /// 아픔 태그 (코랄색 테두리)
  static Widget pain({
    required String text,
    VoidCallback? onTap,
    EdgeInsets? padding,
  }) {
    return _buildTag(
      text: text,
      borderColor: AppColors.tagPain,
      textColor: AppColors.black,
      onTap: onTap,
      padding: padding,
    );
  }

  /// 커스텀 태그
  static Widget custom({
    required String text,
    required Color borderColor,
    Color? textColor,
    Color? backgroundColor,
    VoidCallback? onTap,
    EdgeInsets? padding,
  }) {
    return _buildTag(
      text: text,
      borderColor: borderColor,
      textColor: textColor ?? AppColors.black,
      backgroundColor: backgroundColor ?? AppColors.white,
      onTap: onTap,
      padding: padding,
    );
  }

  /// 태그 빌더 헬퍼 메서드
  static Widget _buildTag({
    required String text,
    required Color borderColor,
    required Color textColor,
    Color backgroundColor = AppColors.white,
    VoidCallback? onTap,
    EdgeInsets? padding,
  }) {
    final tagWidget = Container(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultSpacing,
        vertical: AppConstants.smallSpacing,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.circularBorderRadius),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppConstants.defaultFontSize,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: tagWidget,
      );
    }

    return tagWidget;
  }

  /// 상태별 태그를 자동으로 선택하는 헬퍼
  static Widget byStatus({
    required String status,
    required String text,
    VoidCallback? onTap,
    EdgeInsets? padding,
  }) {
    switch (status.toLowerCase()) {
      case 'good':
      case '좋음':
      case '정상':
        return good(text: text, onTap: onTap, padding: padding);
      case 'normal':
      case '보통':
      case '평균':
        return normal(text: text, onTap: onTap, padding: padding);
      case 'bad':
      case '나쁨':
      case '주의':
        return bad(text: text, onTap: onTap, padding: padding);
      case 'pain':
      case '아픔':
      case '통증':
        return pain(text: text, onTap: onTap, padding: padding);
      default:
        return defaultTag(text: text, onTap: onTap, padding: padding);
    }
  }
}
