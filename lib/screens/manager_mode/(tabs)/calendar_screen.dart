import 'package:flutter/material.dart';
import '../calendar/calendar_modal.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentDate = DateTime(2025, 9); // 2025년 9월
  int? _selectedDay; // 선택된 날짜

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '캘린더',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              // 알림 기능
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 캘린더 그리드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
        child: Column(
                children: [
                  // 년월 표시
                  Row(
          children: [
                      Text(
                        '${_currentDate.year}년 ${_currentDate.month}월',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 요일 헤더
                  Row(
                    children: ['일', '월', '화', '수', '목', '금', '토']
                        .map((day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                    fontSize: 16,
                fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  
                  // 캘린더 그리드
                  Expanded(
                    child: _buildCalendarGrid(),
                  ),
                ],
              ),
            ),
          ),
          
          // 감정 바
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  flex: 60,
                  child: Container(
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0B29F),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 10),
                    child: const Text(
                      '부정 60%',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                ),
                Expanded(
                  flex: 40,
                  child: Container(
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFA5D6A7),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 10),
                    child: const Text(
                      '긍정 40%',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
              ),
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday % 7; // 일요일이 0이 되도록 조정
    
    // 이전 달의 마지막 날들
    final previousMonth = DateTime(_currentDate.year, _currentDate.month - 1, 0);
    final daysInPreviousMonth = previousMonth.day;
    
    List<Widget> calendarDays = [];
    
    // 이전 달의 마지막 날들 (8월 31일)
    for (int i = daysInPreviousMonth - firstDayOfWeek + 1; i <= daysInPreviousMonth; i++) {
      calendarDays.add(_buildCalendarDay(i, isCurrentMonth: false));
    }
    
    // 현재 달의 모든 날들
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      calendarDays.add(_buildCalendarDay(day, isCurrentMonth: true));
    }
    
    // 다음 달의 첫 날들 (10월 1일부터)
    int remainingDays = 42 - calendarDays.length; // 6주 * 7일 = 42
    for (int day = 1; day <= remainingDays; day++) {
      calendarDays.add(_buildCalendarDay(day, isCurrentMonth: false));
    }
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: calendarDays.length,
      itemBuilder: (context, index) => calendarDays[index],
    );
  }

  Widget _buildCalendarDay(int day, {required bool isCurrentMonth}) {
    // 특정 날짜에 경고 아이콘이 있는지 확인 (9월 2일, 9일, 10일, 11일)
    bool hasWarning = isCurrentMonth && (day == 2 || day == 9 || day == 10 || day == 11);
    bool isSelected = isCurrentMonth && _selectedDay == day;
    
    return GestureDetector(
      onTap: () {
        if (isCurrentMonth) {
          setState(() {
            _selectedDay = day;
          });
          _showDateDetailModal(context, day);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: isSelected ? BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ) : null,
        child: Column(
          children: [
            // 날짜 번호
            Text(
              day.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isCurrentMonth ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            
            // 감정 바 차트
            Expanded(
              child: Column(
                children: [
                  // 상단 분홍/피치색 바
                  Expanded(
                    flex: _getNegativeRatio(day),
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
                    flex: _getPositiveRatio(day),
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
            
            // 경고 아이콘
            if (hasWarning)
              Container(
                margin: const EdgeInsets.only(top: 2),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 12,
                  color: Colors.amber,
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
        currentDate: _currentDate,
        day: day,
      ),
    );
  }


}
