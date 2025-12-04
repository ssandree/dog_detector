// lib/manager/calendar/calendar_widgets/week_selector.dart
import 'package:flutter/material.dart';

import '../../../core/config/app_colors.dart';
import '../../../core/config/app_constants.dart';

/// 주의 시작일(월요일) 계산
DateTime _getWeekStart(DateTime date) {
  final weekday = date.weekday; // 1(월) ~ 7(일)
  return date.subtract(Duration(days: weekday - 1));
}

/// 월의 주차 수 계산 (월의 첫 번째 월요일부터 시작)
int _getWeeksInMonth(int year, int month) {
  final firstDayOfMonth = DateTime(year, month, 1);
  final lastDayOfMonth = DateTime(year, month + 1, 0);
  
  // 첫 번째 월요일 찾기
  final firstMonday = _getWeekStart(firstDayOfMonth);
  
  // 마지막 날짜의 주차 계산
  final lastWeekStart = _getWeekStart(lastDayOfMonth);
  
  // 주차 수 계산
  final daysDiff = lastWeekStart.difference(firstMonday).inDays;
  final weeks = (daysDiff ~/ 7) + 1;
  
  return weeks > 6 ? 6 : weeks; // 최대 6주차
}

class WeekSelector extends StatefulWidget {
  final int year;
  final int month;
  final int? selectedWeek;
  final ValueChanged<int> onWeekSelected;

  const WeekSelector({
    super.key,
    required this.year,
    required this.month,
    this.selectedWeek,
    required this.onWeekSelected,
  });

  @override
  State<WeekSelector> createState() => _WeekSelectorState();
}

class _WeekSelectorState extends State<WeekSelector> {
  late final FixedExtentScrollController _scrollController;
  late int _weeksInMonth;
  int? _selectedWeek;

  @override
  void initState() {
    super.initState();
    _weeksInMonth = _getWeeksInMonth(widget.year, widget.month);
    _selectedWeek = widget.selectedWeek ?? 1;
    _scrollController = FixedExtentScrollController(
      initialItem: (_selectedWeek! - 1).clamp(0, _weeksInMonth - 1),
    );
    
    // 스크롤 변경 감지
    _scrollController.addListener(_onScrollChanged);
  }

  void _onScrollChanged() {
    if (!_scrollController.hasClients) return;
    
    final currentIndex = _scrollController.selectedItem;
    final newWeek = currentIndex + 1;
    
    if (_selectedWeek != newWeek) {
      setState(() {
        _selectedWeek = newWeek;
      });
      widget.onWeekSelected(newWeek);
    }
  }

  @override
  void didUpdateWidget(WeekSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year || oldWidget.month != widget.month) {
      final newWeeksInMonth = _getWeeksInMonth(widget.year, widget.month);
      setState(() {
        _weeksInMonth = newWeeksInMonth;
        _selectedWeek = 1;
      });
      if (_scrollController.hasClients) {
        _scrollController.jumpToItem(0);
      }
    } else if (oldWidget.selectedWeek != widget.selectedWeek && widget.selectedWeek != null) {
      final targetIndex = (widget.selectedWeek! - 1).clamp(0, _weeksInMonth - 1);
      if (_scrollController.hasClients) {
        _scrollController.animateToItem(
          targetIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Stack(
        children: [
          // 선택 영역 하이라이트
          Positioned.fill(
            child: Center(
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.grey2.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // 휠 스크롤 뷰
          ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: 30,
            diameterRatio: 1.5,
            perspective: 0.003,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _weeksInMonth,
              builder: (context, index) {
                final week = index + 1;
                final isSelected = _selectedWeek == week;
                
                return Center(
                  child: Text(
                    '${widget.month}월 ${week}째주',
                    style: TextStyle(
                      fontSize: isSelected ? 16 : 12,
                      color: isSelected ? AppColors.black : AppColors.grey9,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

