import '../../../../core/index_export.dart';

/// 감정 관련 유틸리티 함수들
class EmotionUtils {
  /// 감정별 색상 반환
  static Color getEmotionColor(String emotion) {
    switch (emotion) {
      case '행복':
        return AppColors.green6;
      case '평온':
        return AppColors.green5;
      case '활발':
        return AppColors.green7;
      case '불안':
        return AppColors.activityStatusColor;
      case '화남':
        return AppColors.error;
      default:
        return AppColors.grey6;
    }
  }

  /// 시간 포맷팅 (N분 전, N시간 전 등)
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
    }
  }
}

