import 'package:flutter/material.dart';
import '../../../../core/index_export.dart';

class HealthAlertCard extends StatelessWidget {
  final String message;
  final String detectionCount;
  final String countLabel;
  final List<TimeSlotData> timeSlots;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const HealthAlertCard({
    super.key,
    required this.message,
    required this.detectionCount,
    required this.countLabel,
    required this.timeSlots,
    this.icon = Icons.warning_amber_rounded,
    this.backgroundColor = AppColors.green1,
    this.iconColor = AppColors.green5,
    this.textColor = AppColors.green8,
  });

  @override
  Widget build(BuildContext context) {
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

class TimeSlotData {
  final String time;
  final String count;
  final Color color;

  TimeSlotData({
    required this.time,
    required this.count,
    required this.color,
  });
}
