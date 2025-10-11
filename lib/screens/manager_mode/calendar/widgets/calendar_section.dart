import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../calendar_modal.dart';

class CalendarSection extends StatefulWidget {
  const CalendarSection({super.key});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  DateTime _focusedDay = DateTime(2025, 9); // 2025년 9월
  DateTime? _selectedDay; // 선택된 날짜

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            
            // Table Calendar
            Expanded(
              child: TableCalendar<dynamic>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _showDateDetailModal(context, selectedDay.day);
                  }
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
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
                    color: Colors.blue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                  markerDecoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  cellMargin: const EdgeInsets.all(4), // 2에서 4로 증가 (200% 증가)
                  cellPadding: const EdgeInsets.all(8), // 4에서 8로 증가 (200% 증가)
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: const Icon(Icons.arrow_back_ios),
                  rightChevronIcon: const Icon(Icons.arrow_forward_ios),
                  titleTextStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  titleTextFormatter: (date, locale) {
                    return '${date.year}년 ${date.month}월';
                  },
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    // 특정 날짜에 경고 아이콘이 있는지 확인 (9월 2일, 9일, 10일, 11일)
                    bool hasWarning = day.day == 2 || day.day == 9 || day.day == 10 || day.day == 11;
                    if (hasWarning) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          margin: const EdgeInsets.only(top: 2),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            size: 12,
                            color: Colors.amber,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(4), // 2에서 4로 증가
                      child: Column(
                        children: [
                          // 날짜 번호
                          Text(
                            day.day.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: day.month == _focusedDay.month ? Colors.black : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6), // 간격을 늘림 (4 -> 6)
                          
                          // 감정 바 차트
                          Expanded(
                            child: Column(
                              children: [
                                // 상단 분홍/피치색 바
                                Expanded(
                                  flex: _getNegativeRatio(day.day),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFAB91), // 피치색
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                // 하단 초록색 바
                                Expanded(
                                  flex: _getPositiveRatio(day.day),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFA5D6A7), // 연한 초록
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getNegativeRatio(int day) {
    // 각 날짜별로 다른 비율 설정 (사진과 유사하게)
    final ratios = {
      1: 3, 2: 4, 3: 2, 4: 5, 5: 3, 6: 4, 7: 2,
      8: 3, 9: 4, 10: 5, 11: 4, 12: 3, 13: 2, 14: 4,
      15: 3, 16: 5, 17: 4, 18: 3, 19: 2, 20: 4, 21: 3,
      22: 4, 23: 5, 24: 3, 25: 4, 26: 2, 27: 3, 28: 4,
      29: 3, 30: 5,
    };
    return ratios[day] ?? 3;
  }

  int _getPositiveRatio(int day) {
    // 긍정 비율은 전체에서 부정 비율을 뺀 값
    return 7 - _getNegativeRatio(day);
  }

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
