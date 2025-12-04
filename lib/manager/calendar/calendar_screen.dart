// lib/manager/calendar/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/widgets/base_scaffold.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_cards.dart';
import 'calendar_widgets/calendar_section.dart';
import 'calendar_widgets/monthly_chart.dart';
import 'calendar_widgets/monthly_ai_report.dart';
import 'calendar_widgets/week_selector.dart';
import '../logic/provider/calendar_provider.dart';
import 'weekly_report_modal.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  int? _selectedWeek;
  int? _lastMonth; // 이전 월 추적
  final ScrollController _scrollController = ScrollController();

  /// 주의 시작일(월요일) 계산
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1(월) ~ 7(일)
    return date.subtract(Duration(days: weekday - 1));
  }

  void _handleWeekSelected(int week) {
    setState(() {
      _selectedWeek = week;
    });
  }

  void _handleReportButtonPressed() {
    if (_selectedWeek == null) return;
    
    final calendarState = ref.read(calendarProvider);
    final year = calendarState.year;
    final month = calendarState.month;
    final week = _selectedWeek!;
    
    // 선택된 주차의 첫 번째 날짜 계산 (월요일)
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstMonday = _getWeekStart(firstDayOfMonth);
    final selectedWeekMonday = firstMonday.add(Duration(days: (week - 1) * 7));
    
    // 위클리 리포트 모달 표시
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: WeeklyReportModal(
          selectedDate: selectedWeekMonday,
          year: year,
          month: month,
          week: week,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(AppConstants.defaultSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CalendarSection(
              modalHorizontalMargin: 20,
            ),
            SizedBox(height: AppConstants.defaultSpacing),
            // Week selector
            _buildWeekSelector(),
            // 주간 리포트 보기 버튼
            if (_selectedWeek != null) ...[
              SizedBox(height: AppConstants.defaultSpacing),
              _buildReportButton(),
            ],
            SizedBox(height: AppConstants.defaultSpacing),
            // 월간 차트와 AI 리포트를 하나의 카드에 배치
            Container(
              padding: EdgeInsets.all(AppConstants.defaultSpacing),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const MonthlyEventsChart(),
                  const Divider(height: 32, thickness: 1, color: AppColors.grey3),
                  const MonthlyAiReport(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    final calendarState = ref.watch(calendarProvider);
    final year = calendarState.year;
    final month = calendarState.month;

    // 월이 변경되면 선택된 주차 초기화
    if (_lastMonth != null && _lastMonth != month) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedWeek = null;
          });
        }
      });
    }
    _lastMonth = month;

    return WeekSelector(
      key: ValueKey('$year-$month'), // 월이 변경되면 위젯 재생성
      year: year,
      month: month,
      selectedWeek: _selectedWeek,
      onWeekSelected: _handleWeekSelected,
    );
  }

  Widget _buildReportButton() {
    return AppButton.primary(
      text: '주간 리포트 보기',
      onPressed: _handleReportButtonPressed,
      height: 40,
    );
  }
}
