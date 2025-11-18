import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/app_constants.dart';
import '../theme/app_colors.dart';
import 'app_buttons.dart';

/// 공통 에러 위젯
/// 
/// AsyncValue.error를 표시하는 표준화된 위젯
class AppErrorWidget extends StatelessWidget {
  /// 에러 메시지
  final String message;
  
  /// 재시도 콜백 (null이면 재시도 버튼이 표시되지 않음)
  final VoidCallback? onRetry;
  
  /// 상세 에러 정보 (개발용, 선택사항)
  final String? details;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultSpacing),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 에러 아이콘
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppConstants.defaultSpacing),
                
                // 에러 메시지
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // 상세 정보 (개발 모드에서만 표시)
                if (details != null) ...[
                  const SizedBox(height: AppConstants.smallSpacing),
                  Text(
                    details!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                // 재시도 버튼
                if (onRetry != null) ...[
                  const SizedBox(height: AppConstants.defaultSpacing),
                  AppButtons.primary(
                    text: '다시 시도',
                    icon: Icons.refresh,
                    onPressed: onRetry,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// AsyncValue를 표시하는 헬퍼 위젯
/// 
/// data, loading, error 상태를 표준화된 방식으로 처리
class AsyncValueWidget<T> extends StatelessWidget {
  /// AsyncValue 상태
  final AsyncValue<T> asyncValue;
  
  /// 데이터가 있을 때 표시할 위젯 빌더
  final Widget Function(BuildContext, T) data;
  
  /// 로딩 중일 때 표시할 위젯 (null이면 기본 CircularProgressIndicator)
  final Widget? loading;
  
  /// 에러 메시지 (null이면 기본 메시지)
  final String? errorMessage;
  
  /// 재시도 콜백 (null이면 재시도 버튼 없음)
  final VoidCallback? onRetry;
  
  /// 에러 상세 정보 표시 여부 (개발용)
  final bool showErrorDetails;

  const AsyncValueWidget({
    super.key,
    required this.asyncValue,
    required this.data,
    this.loading,
    this.errorMessage,
    this.onRetry,
    this.showErrorDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (value) => data(context, value),
      loading: () => loading ?? const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => AppErrorWidget(
        message: errorMessage ?? _getDefaultErrorMessage(error),
        onRetry: onRetry,
        details: showErrorDetails ? error.toString() : null,
      ),
    );
  }

  String _getDefaultErrorMessage(Object error) {
    // 커스텀 Exception의 메시지 사용
    if (error.toString().contains('AppException')) {
      return error.toString().replaceAll('AppException: ', '');
    }
    return '데이터를 불러오는데 실패했습니다.';
  }
}

