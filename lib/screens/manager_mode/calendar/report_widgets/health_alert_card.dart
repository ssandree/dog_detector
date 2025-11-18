import '../../../../core/index_export.dart';

class HealthAlertCard extends StatelessWidget {
  final List<dynamic> events;
  final int healthAlertCount;
  final String countLabel;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const HealthAlertCard({
    super.key,
    required this.events,
    required this.healthAlertCount,
    this.countLabel = '오늘 감지 횟수',
    this.icon = Icons.warning_amber_rounded,
    this.backgroundColor = AppColors.green1,
    this.iconColor = AppColors.green5,
    this.textColor = AppColors.green8,
  });

  @override
  Widget build(BuildContext context) {
    // 건강 알림 데이터 표시 (계산은 Screen에서 완료됨)
    final message = '오늘은 슬개골 탈구 의심 행동이 $healthAlertCount회 감지되었습니다.';
    final detectionCount = '$healthAlertCount회';
    
    // 시간대별 분포 계산 (간단한 mock 데이터 기반)
    final timeSlots = [
      _TimeSlotData('오전', '1회', AppColors.activityStatusColor),
      _TimeSlotData('오후', '1회', AppColors.activityStatusColor),
      _TimeSlotData('저녁', '0회', AppColors.grey5),
    ];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: AppConstants.defaultFontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      countLabel,
                      style: const TextStyle(
                        fontSize: AppConstants.defaultFontSize - 2,
                        color: AppColors.grey7,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallSpacing - 4),
                    Text(
                      detectionCount,
                      style: TextStyle(
                        fontSize: AppConstants.titleFontSize - 8,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '시간대별 분포',
                      style: TextStyle(
                        fontSize: AppConstants.defaultFontSize - 2,
                        color: AppColors.grey7,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallSpacing),
                    Row(
                      children: timeSlots.map((slot) => Padding(
                        padding: const EdgeInsets.only(right: AppConstants.smallSpacing + 4),
                        child: _buildTimeSlot(slot.time, slot.count, slot.color),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeSlot(String time, String count, Color color) {
    return Column(
      children: [
        Container(
          width: AppConstants.smallSpacing,
          height: AppConstants.smallSpacing,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing - 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: AppConstants.smallFontSize,
            color: AppColors.grey7,
          ),
        ),
        Text(
          count,
          style: TextStyle(
            fontSize: AppConstants.smallFontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TimeSlotData {
  final String time;
  final String count;
  final Color color;

  _TimeSlotData(this.time, this.count, this.color);
}

