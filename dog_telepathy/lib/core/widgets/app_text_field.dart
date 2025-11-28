// lib/core/widgets/app_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final AutovalidateMode? autovalidateMode;
  final bool enabled;
  final int? maxLines;
  final int? minLines;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.autovalidateMode,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        if (label.isNotEmpty) SizedBox(height: 8.h),

        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          autovalidateMode: autovalidateMode,
          keyboardType: keyboardType,
          enabled: enabled,
          minLines: obscureText ? 1 : minLines,
          maxLines: obscureText ? 1 : maxLines,
          style: TextStyle(fontSize: 16.sp),

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.grey7,
              fontSize: 14.sp,
            ),

            suffixIcon: suffixIcon,

            filled: true,
            fillColor: enabled ? AppColors.grey1 : AppColors.grey2,

            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.grey4),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.grey4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.beige4,
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.errorRed),
            ),
          ),
        ),
      ],
    );
  }
}
