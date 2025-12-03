// lib/core/widgets/app_cards.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/app_colors.dart';
import '../config/app_constants.dart';

class AppCards {
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
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppConstants.defaultBorderRadius,
        ),
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

  static Widget videoPlayer({
    required Widget child,
    String? liveBadgeText,
    List<Widget>? overlayWidgets,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    final widgets = <Widget>[
      child,
      if (overlayWidgets != null) ...overlayWidgets,
    ];

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
        child: Stack(children: widgets),
      ),
    );
  }

  static Widget alert({
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    final Color effectiveIconColor = iconColor ?? AppColors.green5;

    return Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(AppConstants.defaultSpacing),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.green1,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: effectiveIconColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null)
            Container(
              padding: EdgeInsets.all(AppConstants.smallSpacing - 2.w),
              decoration: BoxDecoration(
                color: effectiveIconColor,
                borderRadius: BorderRadius.circular(
                  AppConstants.smallSpacing - 2.w,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: AppConstants.defaultSpacing,
              ),
            ),
          if (icon != null) SizedBox(width: AppConstants.smallSpacing + 4.w),
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
