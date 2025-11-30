// lib/core/widgets/app_status_tags.dart

import 'package:flutter/material.dart';

import '../config/app_constants.dart';
import '../config/app_colors.dart';

class AppStatusTags {
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

    final isAggressive = _containsAny(lower, raw, _aggressiveKeywords);
    final isPositive = _containsAny(lower, raw, _positiveKeywords);
    final isNegative = _containsAny(lower, raw, _negativeKeywords);

    final tagPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2);

    Color borderColor = AppColors.grey4;
    Color textColor = AppColors.black;
    Color backgroundColor = AppColors.white;

    if (isAggressive) {
      borderColor = AppColors.coral5;
      textColor = AppColors.white;
      backgroundColor = AppColors.coral3;
    } else if (isPositive) {
      borderColor = AppColors.green3;
      textColor = AppColors.green6;
      backgroundColor = AppColors.green1;
    } else if (isNegative) {
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
          fontSize: AppConstants.smallFontSize - 1,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

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
          fontSize: AppConstants.defaultFontSize - 3,
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

  static bool _containsAny(
    String lower,
    String raw,
    List<String> keywords,
  ) {
    for (final k in keywords) {
      if (lower.contains(k) || raw.contains(k)) return true;
    }
    return false;
  }

  static const _positiveKeywords = [
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

  static const _negativeKeywords = [
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

  static const _aggressiveKeywords = [
    'aggressive',
    '공격',
    '공격성',
  ];
}
