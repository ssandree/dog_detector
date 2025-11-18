import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../calendar_modal.dart';
import '../../../../core/index_export.dart';
import '../../../../core/utils/emotion_ratio_calculator.dart';
import '../../../../data/report_mock.dart';

class CalendarSection extends ConsumerStatefulWidget {
  const CalendarSection({super.key});

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

  @override
  Widget build(BuildContext context) {
    // 날짜별 감정 비율 계산 (mockDailyReports 기반)
    final weeklyRatios = <String, double>{};
    
    // 현재 월의 모든 날짜에 대해 비율 계산
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final endDate = today.isBefore(lastDayOfMonth) ? today : lastDayOfMonth;
    
    // 각 날짜에 대해 mockDailyReports에서 데이터 가져와서 비율 계산
    for (var date = firstDayOfMonth; 
        date.isBefore(endDate.add(const Duration(days: 1))); 
        date = date.add(const Duration(days: 1))) {
      final dateKey = '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final fullDateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // mockDailyReports에서 해당 날짜의 데이터 찾기
      if (mockDailyReports.containsKey(fullDateKey)) {
        final reportData = mockDailyReports[fullDateKey]!;
        final events = reportData['events'] as List<dynamic>? ?? [];
        final ratio = EmotionRatioCalculator.calculateNegativeRatio(events);
        weeklyRatios[dateKey] = ratio;
      } else {
        // 데이터가 없으면 기본 비율 (0.3)
        weeklyRatios[dateKey] = 0.3;
      }
    }
    
    return Container(
      height: 410, // 오버플로우 방지를 위해 높이 증가 (380 + 30)
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: TableCalendar<dynamic>(
        firstDay: DateTime.utc(2016, 1, 1),
        lastDay: _today,
        focusedDay: _focusedDay,
        rowHeight: 52.0, // 행 높이를 약간 줄여서 공간 확보

        // ✅ 선택된 날짜 표시 로직
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

        // 📍 날짜 클릭 시: 선택 상태 갱신 + 모달 띄우기 (오늘 이후 날짜는 클릭 불가)
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay) && selectedDay.isBefore(_today.add(const Duration(days: 1)))) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _showDateDetailModal(context, selectedDay.day);
          }
        },

        // 월 넘길 때 포커스 날짜 변경
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
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
            selectedDecoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.3),
              shape: BoxShape.circle,
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
            
            // 주말인지 확인 (일요일=7, 토요일=6)
            final isWeekend = day.weekday == DateTime.sunday || day.weekday == DateTime.saturday;
            
            // 날짜를 "MM-dd" 문자열 형태로 변환
            final key = '${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
            final ratio = weeklyRatios[key] ?? 0.3;
            final cellColor = isFutureDay ? Colors.grey[300] : EmotionRatioCalculator.getColorByRatio(ratio);

            return Container(
              margin: const EdgeInsets.all(3), // 외부 컨테이너에 마진 추가
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Container(
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(8), // 더 둥글게
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: isFutureDay 
                          ? Colors.grey[400]
                          : isWeekend 
                              ? Colors.red  // 주말은 빨간색
                              : (day.month == _focusedDay.month ? Colors.black : Colors.grey),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  

  /// 🪟 날짜 클릭 시 상세 모달 표시
  void _showDateDetailModal(BuildContext context, int day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalendarModal(
        currentDate: _focusedDay,
        day: day,
      ),
    );
  }
}
