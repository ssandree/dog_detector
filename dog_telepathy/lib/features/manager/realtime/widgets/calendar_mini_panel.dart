import 'package:flutter/material.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../realtime_types.dart';

class CalendarMiniPanel extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDate;
  final Map<DateTime, EmotionState> emotionMap;
  final ValueChanged<int> onChangeMonth;
  final ValueChanged<DateTime> onSelectDate;

  const CalendarMiniPanel({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.emotionMap,
    required this.onChangeMonth,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final days = _buildDays(currentMonth);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.defaultSpacing),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onChangeMonth(-1),
              ),
              Expanded(
                child: Text(
                  '${currentMonth.year}.${currentMonth.month.toString().padLeft(2, '0')}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onChangeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: days.map((date) {
                  final emotion = emotionMap[date];
                  final isSelected = selectedDate == date;
                  return _CalendarCell(
                    date: date,
                    emotion: emotion,
                    isSelected: isSelected,
                    onTap: () => onSelectDate(date),
                  );
                }).toList(),
              ),
            ),
          ),
          if (selectedDate != null) ...[
            const SizedBox(height: 12),
            _SelectedSummary(
              date: selectedDate!,
              emotion: emotionMap[selectedDate],
            ),
          ],
        ],
      ),
    );
  }

  List<DateTime> _buildDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];
    for (var i = 0; i < firstDay.weekday % 7; i++) {
      days.add(firstDay.subtract(Duration(days: firstDay.weekday - i)));
    }
    for (var day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(month.year, month.month, day));
    }
    while (days.length % 7 != 0) {
      days.add(days.last.add(const Duration(days: 1)));
    }
    return days.map((d) => DateTime(d.year, d.month, d.day)).toList();
  }
}

class _CalendarCell extends StatelessWidget {
  final DateTime date;
  final EmotionState? emotion;
  final bool isSelected;
  final VoidCallback onTap;

  const _CalendarCell({
    required this.date,
    required this.emotion,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _emotionColor(emotion);
    final today = DateTime.now();
    final inCurrentMonth = date.month == today.month && date.year == today.year;
    final width = (MediaQuery.of(context).size.width - 48) / 7 - 4;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.green5 : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: inCurrentMonth ? AppColors.black : AppColors.grey6,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }

  Color _emotionColor(EmotionState? emotion) {
    switch (emotion) {
      case EmotionState.happy:
        return const Color(0xFF4CAF50);
      case EmotionState.anxious:
        return const Color(0xFFFFB74D);
      case EmotionState.angry:
        return const Color(0xFFF44336);
      case EmotionState.sad:
        return const Color(0xFF7986CB);
      case EmotionState.neutral:
        return const Color(0xFFBDBDBD);
      case null:
        return const Color(0xFFBDBDBD);
    }
  }
}

class _SelectedSummary extends StatelessWidget {
  final DateTime date;
  final EmotionState? emotion;

  const _SelectedSummary({required this.date, required this.emotion});

  @override
  Widget build(BuildContext context) {
    final emotionLabel = _emotionLabel(emotion);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _emotionColor(emotion),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
              '오늘 강아지의 감정은 $emotionLabel 입니다.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF424242)),
            ),
          ),
        ],
      ),
    );
  }

  String _emotionLabel(EmotionState? emotion) {
    switch (emotion) {
      case EmotionState.happy:
        return '행복';
      case EmotionState.anxious:
        return '불안';
      case EmotionState.angry:
        return '화남';
      case EmotionState.sad:
        return '슬픔';
      case EmotionState.neutral:
        return '중립';
      case null:
        return '요약 정보 없음';
    }
  }

  Color _emotionColor(EmotionState? emotion) {
    switch (emotion) {
      case EmotionState.happy:
        return const Color(0xFF4CAF50);
      case EmotionState.anxious:
        return const Color(0xFFFFB74D);
      case EmotionState.angry:
        return const Color(0xFFF44336);
      case EmotionState.sad:
        return const Color(0xFF7986CB);
      case EmotionState.neutral:
        return const Color(0xFFBDBDBD);
      case null:
        return const Color(0xFFBDBDBD);
    }
  }
}
