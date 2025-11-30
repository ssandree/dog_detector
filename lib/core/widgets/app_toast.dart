// lib/core/widgets/app_toast.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../error/exceptions.dart';

class AppToast {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    int durationSeconds = 2,
  }) {
    _hide();

    final overlayState = Overlay.of(context);
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
    );

    overlayState.insert(_overlayEntry!);

    _timer = Timer(Duration(seconds: durationSeconds), () {
      _hide();
    });
  }

  static void _hide() {
    _timer?.cancel();
    _timer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static void success(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.green5,
      textColor: Colors.white,
    );
  }

  static void error(BuildContext context, dynamic error, [String? message]) {
    String errorMessage;
    
    if (error is AppException) {
      errorMessage = message ?? error.message;
    } else if (message != null) {
      errorMessage = message;
    } else {
      errorMessage = '오류가 발생했습니다. 다시 시도해주세요.';
    }
    
    _show(
      context: context,
      message: errorMessage,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }

  static void warning(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  static void info(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.beige4,
      textColor: Colors.white,
    );
  }

  static void custom({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    int? durationSeconds,
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: backgroundColor ?? Colors.grey.shade800,
      textColor: textColor ?? Colors.white,
      durationSeconds: durationSeconds ?? 2,
    );
  }

  static void comingSoon(BuildContext context, String feature) {
    _show(
      context: context,
      message: '$feature 기능은 곧 출시됩니다!',
      backgroundColor: Colors.grey.shade700,
      textColor: Colors.white,
    );
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;

  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final toastWidth = screenWidth * 0.8;

    return Positioned(
      bottom: 80,
      left: (screenWidth - toastWidth) / 2,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: toastWidth,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: textColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
