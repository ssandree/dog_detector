import '../../../core/index_export.dart';
import '../../../models/calendar_data.dart';
import 'report_widgets/report_widgets.dart';
import 'weekly_report.dart';
import 'calendar_widgets/calendar_section.dart';
import '../../../widgets/app_error_banner.dart';

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
      data: (context, calendarData) => SingleChildScrollView(
        child: HorizontalPadding(
          child: Column(
            children: [
              const CalendarSection(),
              const SizedBox(height: AppConstants.defaultSpacing),
              // 월간 요약만 간단히 표시 (Provider 사용 확인)
              MonthlySummary(
                title: '월간 요약',
                summaryText: calendarData.monthlySummary.summaryText,
                bulletPoints: calendarData.monthlySummary.bulletPoints,
              ),
              const SizedBox(height: AppConstants.defaultSpacing),
              // 주간 리포트 추가
              const WeeklyReport(),
            ],
          ),
        ),
      ),
    );
  }
}
