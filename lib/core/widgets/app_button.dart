// lib/core/widgets/app_button.dart

import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Color? _outlineBorder;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.height = 52,
    this.backgroundColor = AppColors.beige4,
    this.textColor = Colors.white,
    Color? outlineBorder,
  }) : _outlineBorder = outlineBorder;

  factory AppButton.primary({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    double height = 52,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      enabled: true,
      isLoading: false,
      height: height,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
    );
  }

  factory AppButton.outline({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    double height = 52,
    Color borderColor = AppColors.beige5,
    Color textColor = AppColors.black,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      enabled: true,
      isLoading: isLoading,
      height: height,
      backgroundColor: Colors.transparent,
      textColor: textColor,
      outlineBorder: borderColor,
    );
  }

  factory AppButton.disabled({
    Key? key,
    required String text,
    double height = 52,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: null,
      enabled: false,
      isLoading: false,
      height: height,
      backgroundColor: AppColors.grey4,
      textColor: AppColors.grey7,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = enabled && !isLoading ? onPressed : null;

    final isOutline = _outlineBorder != null;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: _outlineBorder != null
              ? BorderSide(color: _outlineBorder as Color, width: 1.6)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          elevation: isOutline ? 0 : null,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
