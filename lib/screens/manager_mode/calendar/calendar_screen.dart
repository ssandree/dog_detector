import '../../../core/index_export.dart';
import '../../../models/calendar_data.dart';
import '../report/widgets/report_widgets.dart';
import '../calendar/widgets/calendar_section.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late int _currentYear;
  late int _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;
  }

  @override
  Widget build(BuildContext context) {
    final calendarDataAsync = ref.watch(
      monthlyCalendarProvider((year: _currentYear, month: _currentMonth)),
    );

    return AsyncValueWidget<CalendarData>(
      asyncValue: calendarDataAsync,
      onRetry: () => ref.invalidate(
        monthlyCalendarProvider((year: _currentYear, month: _currentMonth)),
      ),
      data: (context, calendarData) => Column(
        children: [
          const CalendarSection(),
          const SizedBox(height: AppConstants.defaultSpacing + 4),
          // 월간 요약만 간단히 표시 (Provider 사용 확인)
          MonthlySummary(
            title: '월간 요약',
            summaryText: calendarData.monthlySummary.summaryText,
            bulletPoints: calendarData.monthlySummary.bulletPoints,
          ),
        ],
      ),
    );
  }
}
