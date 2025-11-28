import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../report_modal.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/provider/calendar_provider.dart';
import '../../../../core/service/calendar/mock_calendar_service.dart';
import 'calendar_day_cell.dart';

class CalendarSection extends ConsumerStatefulWidget {
  final double modalHorizontalMargin;

  const CalendarSection({
    super.key,
    this.modalHorizontalMargin = 24,
  });

  @override
  ConsumerState<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends ConsumerState<CalendarSection> {
  // 현재 표시 중인 월
  DateTime _focusedDay = DateTime.now();
  // 사용자가 클릭한 날짜
  DateTime? _selectedDay;
  // 오늘 날짜
  late final DateTime _today = DateTime.now();
  // 하이라이트할 주간의 날짜들
  Set<DateTime> _highlightedWeekDays = {};
  // 하이라이트 타이머
  Timer? _highlightTimer;

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }

  /// 주의 시작일(월요일) 계산
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1(월) ~ 7(일)
    return date.subtract(Duration(days: weekday - 1));
  }

  /// 선택된 주간의 날짜들을 하이라이트
  void _highlightWeek(DateTime weekStart) {
    // 이전 타이머 취소
    _highlightTimer?.cancel();
    
    // 주간의 모든 날짜 계산 (월~일, 7일)
    final weekDays = <DateTime>{};
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      weekDays.add(DateTime(date.year, date.month, date.day));
    }
    
    setState(() {
      _highlightedWeekDays = weekDays;
    });
    
    // 1초 후 하이라이트 제거
    _highlightTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _highlightedWeekDays = {};
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _highlightWeek(_getWeekStart(_focusedDay));
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);

    return calendarState.monthlyData.when(
      data: (response) => _buildCalendar(context, response),
      loading: () => const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _buildErrorState(error),
    );
  }

  Widget _buildCalendar(BuildContext context, MonthlyCalendarResponse response) {
    final heatmapRatios = response.toHeatmapRatios();
    return Container(
      height: 400, // 오버플로우 방지를 위해 높이 증가 (42픽셀 오버플로우 해결)
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: TableCalendar<dynamic>(
        firstDay: DateTime.utc(2016, 1, 1),
        lastDay: _today,
        focusedDay: _focusedDay,
        rowHeight: 50.0, // 행 높이를 약간 줄여서 공간 확보

        // ✅ 선택된 날짜 표시 로직
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

        // 📍 날짜 클릭 시: 선택 상태 갱신 + 모달 띄우기 (오늘 이후 날짜는 클릭 불가)
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay) && selectedDay.isBefore(_today.add(const Duration(days: 1)))) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _highlightWeek(_getWeekStart(selectedDay));
            _showDateDetailModal(context, selectedDay.day);
          }
        },

        // 월 넘길 때 포커스 날짜 변경
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          ref.read(calendarProvider.notifier).changeMonth(focusedDay);
        },

         // 📗 달력 스타일 커스터마이징
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            holidayTextStyle: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            // selectedDecoration은 제거 (defaultBuilder에서 직접 처리)
            todayDecoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.grey12,
                width: 2,
              ),
            ),
            markersMaxCount: 1,
            markerDecoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
            cellPadding: const EdgeInsets.all(6), // 패딩 조정
            cellMargin: const EdgeInsets.all(1.5), // 마진 조정
          ),
          
         // 주말과 공휴일 스타일 적용을 위한 추가 설정
          daysOfWeekStyle : const DaysOfWeekStyle(
            weekendStyle: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),

        // 📅 헤더 (연/월 표시부)
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: const Icon(Icons.arrow_back_ios),
          rightChevronIcon: const Icon(Icons.arrow_forward_ios),
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          titleTextFormatter: (date, locale) =>
              '${date.year}년 ${date.month}월',
        ),

        // 📦 각 날짜 셀의 커스텀 빌더
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            // 오늘 이후 날짜인지 확인
            final isFutureDay = day.isAfter(_today);
            
            // 선택된 날짜인지 확인
            final isSelected = isSameDay(_selectedDay, day);
            
            // 하이라이트할 주간에 포함된 날짜인지 확인
            final dayOnly = DateTime(day.year, day.month, day.day);
            final isHighlighted = _highlightedWeekDays.contains(dayOnly);
            
            // 주말인지 확인 (일요일=7, 토요일=6)
            final isWeekend = day.weekday == DateTime.sunday || day.weekday == DateTime.saturday;
            
            // 날짜를 "MM-dd" 문자열 형태로 변환
            final key = '${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
            final ratio = heatmapRatios[key];
            
            // 현재 포커스된 월과 같은 월인지 확인
            final isCurrentMonth = day.month == _focusedDay.month;

            return CalendarDayCell(
              day: day,
              ratio: ratio,
              isSelected: isSelected,
              isHighlighted: isHighlighted,
              isFutureDay: isFutureDay,
              isWeekend: isWeekend,
              isCurrentMonth: isCurrentMonth,
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Text(
          '달력을 불러오지 못했습니다.\n${error.toString()}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 🪟 날짜 클릭 시 상세 모달 표시
  void _showDateDetailModal(BuildContext context, int day) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.modalHorizontalMargin),
        child: CalendarModal(
          currentDate: _focusedDay,
          day: day,
        ),
      ),
    );
  }
}
