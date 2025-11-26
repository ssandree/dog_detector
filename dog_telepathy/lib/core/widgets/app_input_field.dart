import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../app_constants.dart';

/// 앱 전체에서 사용할 Input 필드 컴포넌트
/// 일관된 스타일과 검증 로직 제공
class AppInputField extends StatelessWidget {
  /// 텍스트 컨트롤러
  final TextEditingController? controller;
  
  /// 라벨 텍스트
  final String? label;
  
  /// 힌트 텍스트
  final String? hint;
  
  /// 아이콘
  final IconData? icon;
  
  /// 접미사 텍스트 (예: "kg", "살")
  final String? suffixText;
  
  /// 접미사 아이콘 (예: 비밀번호 표시/숨김 버튼)
  final Widget? suffixIcon;
  
  /// 키보드 타입
  final TextInputType? keyboardType;
  
  /// 비밀번호 표시 여부
  final bool obscureText;
  
  /// 비활성화 여부
  final bool enabled;
  
  /// 최대 줄 수
  final int? maxLines;
  
  /// 검증 함수
  final String? Function(String?)? validator;
  
  /// 변경 콜백
  final ValueChanged<String>? onChanged;
  
  /// 제출 콜백
  final VoidCallback? onFieldSubmitted;
  
  /// 포커스 노드
  final FocusNode? focusNode;

  const AppInputField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.icon,
    this.suffixText,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: (_) => onFieldSubmitted?.call(),
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixText: suffixText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: AppColors.grey4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: AppColors.grey4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: AppColors.beige5, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        filled: true,
        fillColor: enabled ? AppColors.white : AppColors.grey2,
      ),
    );
  }
}

/// 사전 정의된 검증 함수들
class AppInputValidator {
  /// 필수 입력 검증
  static String? required(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return message ?? '필수 입력 항목입니다.';
    }
    return null;
  }

  /// 이메일 검증
  /// email_validator 패키지를 사용하여 이메일 형식을 검증합니다.
  /// RFC 5322 표준을 준수하는 정확한 검증을 제공합니다.
  static String? email(String? value) {
    // 값이 없으면 검증하지 않음 (required와 함께 사용)
    if (value == null || value.isEmpty) return null;
    
    // email_validator 패키지의 validate 함수 사용
    // 수동 RegExp 대신 표준 라이브러리를 사용하여 더 정확한 검증
    if (!EmailValidator.validate(value)) {
      return '올바른 이메일 주소를 입력해주세요.';
    }
    return null;
  }

  /// 숫자 범위 검증
  static String? numberRange(
    String? value,
    double min,
    double max,
    String? fieldName,
  ) {
    if (value == null || value.isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null || number < min || number > max) {
      return '${fieldName ?? '값'}은 ${min}-${max} 사이여야 합니다.';
    }
    return null;
  }

  /// 최소 길이 검증
  static String? minLength(String? value, int min, String? fieldName) {
    if (value == null || value.isEmpty) return null;
    if (value.length < min) {
      return '${fieldName ?? '값'}은 최소 $min자 이상이어야 합니다.';
    }
    return null;
  }

  /// 최대 길이 검증
  static String? maxLength(String? value, int max, String? fieldName) {
    if (value == null || value.isEmpty) return null;
    if (value.length > max) {
      return '${fieldName ?? '값'}은 최대 $max자까지 입력 가능합니다.';
    }
    return null;
  }

  /// 복합 검증
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

