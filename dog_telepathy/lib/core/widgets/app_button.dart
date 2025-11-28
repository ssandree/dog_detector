// lib/core/widgets/app_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../app_constants.dart';
import '../config/app_colors.dart';

enum AppButtonVariant { basic, normal, pressed, disabled, primary, outline }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final String? subtitle;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final AppButtonVariant _variant;

  const AppButton({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) : this._(
          key: key,
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          width: double.infinity,
          variant: AppButtonVariant.basic,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
        );

  const AppButton.normal({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = 56.0,
    Color? backgroundColor,
    double? fontSize,
    String? subtitle,
  }) : this._(
          key: key,
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          width: width,
          height: height,
          backgroundColor: backgroundColor ?? AppColors.beige2,
          textColor: AppColors.black,
          fontSize: fontSize,
          subtitle: subtitle,
          variant: AppButtonVariant.normal,
        );

  const AppButton.pressed({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = 56.0,
    double? fontSize,
  }) : this._(
          key: key,
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          width: width,
          height: height,
          backgroundColor: AppColors.beige4,
          textColor: AppColors.black,
          fontSize: fontSize,
          variant: AppButtonVariant.pressed,
        );

  const AppButton.disabled({
    Key? key,
    required String text,
    IconData? icon,
    double? width,
    double height = 56.0,
    double? fontSize,
  }) : this._(
          key: key,
          text: text,
          onPressed: null,
          icon: icon,
          width: width,
          height: height,
          backgroundColor: AppColors.grey2,
          textColor: AppColors.grey6,
          fontSize: fontSize,
          variant: AppButtonVariant.disabled,
        );

  const AppButton.primary({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = 56.0,
    Color? backgroundColor,
    double? fontSize,
  }) : this._(
          key: key,
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          width: width,
          height: height,
          backgroundColor: backgroundColor ?? AppColors.beige4,
          textColor: AppColors.white,
          fontSize: fontSize,
          variant: AppButtonVariant.primary,
        );

  const AppButton.outline({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = 56.0,
    Color? borderColor,
    Color? textColor,
    double? fontSize,
  }) : this._(
          key: key,
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          width: width,
          height: height,
          backgroundColor: AppColors.white,
          textColor: textColor ?? AppColors.black,
          borderColor: borderColor ?? AppColors.beige5,
          fontSize: fontSize,
          variant: AppButtonVariant.outline,
        );

  const AppButton._({
    super.key,
    required this.text,
    required this.onPressed,
    required AppButtonVariant variant,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.subtitle,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.fontSize,
    this.fontWeight,
  }) : _variant = variant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: _resolveHeight(),
      child: ElevatedButton(
        onPressed: isLoading || onPressed == null ? null : onPressed,
        style: _buildStyle(),
        child: isLoading ? _buildLoadingIndicator() : _buildChild(context),
      ),
    );
  }

  double _resolveHeight() {
    if (height != null) return height!;
    return _variant == AppButtonVariant.basic ? 50.h : 56.0;
  }

  ButtonStyle _buildStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _resolveBackgroundColor(),
      foregroundColor: _resolveTextColor(),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      side: _variant == AppButtonVariant.outline
          ? BorderSide(
              color: borderColor ?? AppColors.beige5,
              width: 2.0,
            )
          : null,
    );
  }

  Color _resolveBackgroundColor() {
    if (_variant == AppButtonVariant.outline) {
      return backgroundColor ?? AppColors.white;
    }
    return backgroundColor ?? AppColors.beige2;
  }

  Color _resolveTextColor() {
    return textColor ?? AppColors.black;
  }

  Widget _buildLoadingIndicator() {
    return LoadingAnimationWidget.threeArchedCircle(
      color: _resolveTextColor(),
      size: 20.0,
    );
  }

  Widget _buildChild(BuildContext context) {
    if (_variant == AppButtonVariant.basic) {
      return Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _resolveTextColor(),
              fontWeight: FontWeight.bold,
            ),
      );
    }

    final textWidget = Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? AppConstants.buttonFontSize,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: _resolveTextColor(),
      ),
    );

    Widget content = textWidget;
    if (icon != null) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppConstants.defaultIconSize),
          SizedBox(width: AppConstants.smallSpacing),
          textWidget,
        ],
      );
    }

    if (subtitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          AppConstants.h4,
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: (fontSize ?? AppConstants.buttonFontSize) * 0.75,
              fontWeight: FontWeight.w400,
              color: _resolveTextColor().withOpacity(0.7),
            ),
          ),
        ],
      );
    }

    return content;
  }
}
