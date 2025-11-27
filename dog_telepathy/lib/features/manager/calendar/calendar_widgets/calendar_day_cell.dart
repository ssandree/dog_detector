import 'package:flutter/material.dart';

import '../../../../core/config/app_colors.dart';

/// 캘린더 날짜 셀 위젯
/// 각 날짜를 표시하는 커스텀 셀 위젯
class CalendarDayCell extends StatelessWidget {
  /// 비율(0~1)을 히트맵 색상으로 변환
  /// 
  /// [ratio]: 0.0 ~ 1.0 사이의 비율 값
  /// 반환값: AppColors.blended 배열의 색상
  static Color _getColorByRatio(double ratio) {
    const int ratioMultiplier = 10;
    final index = (ratio * ratioMultiplier).round().clamp(0, 10);
    return AppColors.blended[index];
  }
  /// 표시할 날짜
  final DateTime day;
  /// 감정 비율 (0.0 ~ 1.0, 또는 -1.0: 탐지 결과 없음)
  final double? ratio;
  /// 선택된 날짜인지 여부
  final bool isSelected;
  /// 하이라이트할 주간에 포함된 날짜인지 여부
  final bool isHighlighted;
  /// 오늘 이후 날짜인지 여부
  final bool isFutureDay;
  /// 주말인지 여부
  final bool isWeekend;
  /// 현재 포커스된 월과 같은 월인지 여부
  final bool isCurrentMonth;

  const CalendarDayCell({
    super.key,
    required this.day,
    this.ratio,
    this.isSelected = false,
    this.isHighlighted = false,
    this.isFutureDay = false,
    this.isWeekend = false,
    this.isCurrentMonth = true,
  });

  @override
  Widget build(BuildContext context) {
    final finalRatio = ratio ?? 0.3;
    
    // '탐지 결과 없음' 상태 확인
    final hasNoDetection = finalRatio == -1.0;
    
    // 셀 색상 결정
    Color cellColor;
    if (isFutureDay) {
      cellColor = Colors.grey[300]!;
    } else if (hasNoDetection) {
      cellColor = Colors.grey[200]!; // 연한 회색
    } else {
      cellColor = _getColorByRatio(finalRatio);
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final targetHeight = constraints.maxHeight * 0.8;

        return Container(
          margin: const EdgeInsets.all(3),
          alignment: Alignment.center,
          child: SizedBox(
            width: constraints.maxWidth * 0.8,
            height: targetHeight,
            child: Container(
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  color: isFutureDay
                      ? Colors.grey[400]
                      : isWeekend
                          ? Colors.red
                          : (isCurrentMonth ? Colors.black : Colors.grey),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

