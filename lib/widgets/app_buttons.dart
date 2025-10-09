import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';

/// 앱 전체에서 사용할 기본 버튼 위젯들
class AppButtons {
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
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
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
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
              ),
            )
          : icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: AppConstants.defaultIconSize),
                  const SizedBox(width: AppConstants.smallSpacing),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: AppConstants.defaultFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: AppConstants.defaultFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
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
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
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
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
              ),
            )
          : icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: AppConstants.defaultIconSize),
                  const SizedBox(width: AppConstants.smallSpacing),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: AppConstants.defaultFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: AppConstants.defaultFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  /// 비활성 버튼 (연한 회색 배경)
  static Widget disabled({
    required String text,
    IconData? icon,
    double? width,
    double height = 56.0,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonDisabled,
          foregroundColor: AppColors.grey6,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        ),
        child: icon != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: AppConstants.defaultIconSize),
                const SizedBox(width: AppConstants.smallSpacing),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: AppConstants.defaultFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: AppConstants.defaultFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
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
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
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
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
              ),
            )
          : icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: AppConstants.defaultIconSize),
                  const SizedBox(width: AppConstants.smallSpacing),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: AppConstants.defaultFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: AppConstants.defaultFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  /// Primary 버튼 (기존 스타일 유지)
  static Widget primary({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = 56.0,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primaryButtonColor,
          elevation: 8,
          shadowColor: AppColors.black.withOpacity(0.26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.circularBorderRadius - 22),
          ),
        ),
        child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryButtonColor),
              ),
            )
          : icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: AppConstants.defaultIconSize),
                  const SizedBox(width: AppConstants.smallSpacing),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: AppConstants.titleFontSize - 6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: AppConstants.titleFontSize - 4,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  /// Secondary 버튼 (캠모드용)
  static Widget secondary({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = 56.0,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.secondaryButtonColor,
          elevation: 8,
          shadowColor: AppColors.black.withOpacity(0.26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.circularBorderRadius - 22),
          ),
        ),
        child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryButtonColor),
              ),
            )
          : icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: AppConstants.defaultIconSize),
                  const SizedBox(width: AppConstants.smallSpacing),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: AppConstants.titleFontSize - 6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: AppConstants.titleFontSize - 4,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}