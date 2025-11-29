import 'package:flutter/material.dart';

import '../app_constants.dart';
import '../config/app_colors.dart';

/// 상태를 나타내는 태그 위젯들
class AppStatusTags {
  /// 기본 태그 (연한 회색 테두리)
  static Widget appTag({
    required String text,
    VoidCallback? onTap,
    EdgeInsets? padding,
  }) {
    return _buildTag(
      text: text,
      borderColor: AppColors.grey4,
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
      padding: padding ??
          EdgeInsets.symmetric(
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
          fontSize: AppConstants.defaultFontSize-3,
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

  /// 감정 값에 따라 색상이 다른 태그
  static Widget emotionTag({
    required String emotion,
    EdgeInsets? padding,
  }) {
    final raw = emotion.trim();
    if (raw.isEmpty) {
      return appTag(
        text: '분석 중',
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      );
    }

    final lower = raw.toLowerCase();

    // 긍정 감정 키워드
    const positiveKeywords = [
      'happy',
      'calm',
      'joy',
      'joyful',
      'excited',
      'playful',
      '행복',
      '평온',
      '활발',
      '기대',
      '즐거움',
      '편안',
      '안정',
    ];

    // 부정 감정 키워드
    const negativeKeywords = [
      'anxiety',
      'anxious',
      'aggressive',
      'anger',
      'angry',
      'fear',
      'sad',
      'lonely',
      'stressed',
      '불안',
      '슬픔',
      '우울',
      '공격',
      '공격성',
      '화남',
      '분노',
      '외로움',
      '공포',
      '스트레스',
    ];

    bool containsAny(Iterable<String> keywords) {
      for (final k in keywords) {
        if (lower.contains(k) || raw.contains(k)) return true;
      }
      return false;
    }

    final isAggressive = containsAny(['aggressive', '공격', '공격성']);
    final isPositive = containsAny(positiveKeywords);
    final isNegative = containsAny(negativeKeywords);

    final tagPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2);

    // 기본 값
    Color borderColor = AppColors.grey4;
    Color textColor = AppColors.black;
    Color backgroundColor = AppColors.white;

    if (isAggressive) {
      // 공격성 계열: 가장 강한 경고색
      borderColor = AppColors.coral5;
      textColor = AppColors.white;
      backgroundColor = AppColors.coral3;
    } else if (isPositive) {
      // 긍정 감정: 녹색 계열
      borderColor = AppColors.green3;
      textColor = AppColors.green6;
      backgroundColor = AppColors.green1;
    } else if (isNegative) {
      // 부정 감정: 코랄/주의 계열
      borderColor = AppColors.coral3;
      textColor = AppColors.coral5;
      backgroundColor = AppColors.coral1;
    }

    return Container(
      padding: tagPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.circularBorderRadius),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Text(
        raw,
        style: TextStyle(
          fontSize: AppConstants.smallFontSize - 1, // 기본보다 조금 더 작게
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
