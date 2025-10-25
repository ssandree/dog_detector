import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../calendar_modal.dart';
import 'package:dog_detect/data/report_mock.dart';
import 'package:dog_detect/utils/emotion_ratio_calculator.dart';

class CalendarSection extends StatefulWidget {
  const CalendarSection({super.key});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  // 현재 표시 중인 월
  DateTime _focusedDay = DateTime.now();
  // 사용자가 클릭한 날짜
  DateTime? _selectedDay;
  // 오늘 날짜
  late final DateTime _today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // 주간 감정 비율 계산
    final weeklyRatios = calculateWeeklyRatios(mockWeeklyReport);
    
    return Container(
      height: 380, // 높이를 더 늘려서 오버플로우 방지
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: TableCalendar<dynamic>(
        firstDay: DateTime.utc(2016, 1, 1),
        lastDay: _today,
        focusedDay: _focusedDay,
        rowHeight: 55.0, // 행 높이를 줄여서 공간 확보

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
            cellPadding: const EdgeInsets.all(8), // 패딩 증가
            cellMargin: const EdgeInsets.all(2), // 마진 추가로 셀 간격 확보
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
            final cellColor = isFutureDay ? Colors.grey[300] : getColorByRatio(ratio);

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
