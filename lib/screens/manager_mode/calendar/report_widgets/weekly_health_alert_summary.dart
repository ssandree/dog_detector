import '../../../../core/index_export.dart';

/// 주간 건강 알림 요약 위젯 (슬개골 탐지 횟수만 표시)
class WeeklyHealthAlertSummary extends StatelessWidget {
  final int weeklyHealthAlertCount;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const WeeklyHealthAlertSummary({
    super.key,
    required this.weeklyHealthAlertCount,
    this.icon = Icons.warning_amber_rounded,
    this.backgroundColor = AppColors.green1,
    this.iconColor = AppColors.green5,
    this.textColor = AppColors.green8,
  });

  @override
  Widget build(BuildContext context) {
    final message = weeklyHealthAlertCount > 1
        ? '이번 주 슬개골 탈구 의심 행동이 $weeklyHealthAlertCount회 감지되었습니다.'
        : weeklyHealthAlertCount == 1
            ? '이번 주 슬개골 탈구 의심 행동이 1회 감지되었습니다.'
            : '이번 주 슬개골 탈구 의심 행동이 감지되지 않았습니다.';
    
    final detectionCount = '$weeklyHealthAlertCount회';

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultSpacing),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: iconColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.smallSpacing - 2),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(AppConstants.smallSpacing - 2),
            ),
            child: Icon(
              icon,
              color: AppColors.white,
              size: AppConstants.defaultSpacing,
            ),
          ),
          const SizedBox(width: AppConstants.smallSpacing + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: AppConstants.defaultFontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: AppConstants.smallSpacing),
                Row(
                  children: [
                    Text(
                      '주간 감지 횟수',
                      style: const TextStyle(
                        fontSize: AppConstants.defaultFontSize - 2,
                        color: AppColors.grey7,
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallSpacing),
                    Text(
                      detectionCount,
                      style: TextStyle(
                        fontSize: AppConstants.defaultFontSize,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

