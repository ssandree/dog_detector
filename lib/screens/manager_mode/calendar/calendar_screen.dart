import 'package:fl_chart/fl_chart.dart';
import '../../../core/index_export.dart';
import '../../../models/calendar_data.dart';
import '../../../widgets/error_widget.dart';
import '../report/widgets/emotion_ratio_bar.dart';
import '../report/widgets/report_widgets.dart';
import '../calendar/widgets/calendar_section.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  // 현재 표시 중인 연도와 월
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
    // 현재 월의 캘린더 데이터 가져오기
    final calendarDataAsync = ref.watch(
      monthlyCalendarProvider((year: _currentYear, month: _currentMonth)),
    );

    return BaseScaffold(
      title: '캘린더',
      showBackButton: false,
      showNotification: true,
      body: AsyncValueWidget<CalendarData>(
        asyncValue: calendarDataAsync,
        data: (context, calendarData) => _buildContent(calendarData),
        onRetry: () => ref.invalidate(
          monthlyCalendarProvider((year: _currentYear, month: _currentMonth)),
        ),
      ),
    );
  }

  Widget _buildContent(calendarData) {
    return SingleChildScrollView(
        child: HorizontalPadding(
          child: Column(
            children: [
              // 캘린더 섹션
              const CalendarSection(),
              
              const SizedBox(height: AppConstants.defaultSpacing + 4),

              // 월간 선택기
              DateSelector(
                title: '이번 달',
                subtitle: '$_currentYear년 $_currentMonth월',
                onPrevious: () {
                  setState(() {
                    if (_currentMonth == 1) {
                      _currentYear--;
                      _currentMonth = 12;
                    } else {
                      _currentMonth--;
                    }
                  });
                },
                onNext: () {
                  setState(() {
                    if (_currentMonth == 12) {
                      _currentYear++;
                      _currentMonth = 1;
                    } else {
                      _currentMonth++;
                    }
                  });
                },
              ),
              const SizedBox(height: AppConstants.defaultSpacing + 4),

              // 감정 통계 섹션
              EmotionStatsSection(
                title: '월간 감정 통계',
                rankChips: calendarData.rankStats,
              ),
              const SizedBox(height: AppConstants.defaultSpacing + 4),
              
              // 감정 파이 차트
              EmotionPieChart(
                sections: calendarData.pieChartSections,
                legendItems: calendarData.pieChartLegends,
              ),
              const SizedBox(height: AppConstants.defaultSpacing + 4),

              // 감정 바
              EmotionRatioBar(
                negativePercent: calendarData.emotionRatio.negativePercent,
                positivePercent: calendarData.emotionRatio.positivePercent,
                negativeLabel: '부정 ${calendarData.emotionRatio.negativePercent}%',
                positiveLabel: '긍정 ${calendarData.emotionRatio.positivePercent}%',
                negativeColor: calendarData.emotionRatio.negativeColor,
                positiveColor: calendarData.emotionRatio.positiveColor,
              ),
              const SizedBox(height: AppConstants.defaultSpacing + 4),

              // 슬개골 탈구 의심 행동 감지 알림
              HealthAlertCard(
                message: calendarData.healthAlert.message,
                detectionCount: calendarData.healthAlert.detectionCount,
                countLabel: calendarData.healthAlert.countLabel,
                timeSlots: calendarData.healthAlert.timeSlots,
                icon: Icons.warning_amber_rounded,
                backgroundColor: calendarData.healthAlert.backgroundColor,
                iconColor: calendarData.healthAlert.iconColor,
                textColor: calendarData.healthAlert.textColor,
              ),
              const SizedBox(height: AppConstants.defaultSpacing + 4),

              // AI 리포트 섹션
              AiReportSection(
                title: calendarData.aiReport.title,
                subtitle: calendarData.aiReport.subtitle,
                statusLabel: calendarData.aiReport.statusLabel,
                statusColor: calendarData.aiReport.statusColor,
                analysisTexts: calendarData.aiReport.analysisTexts,
                guideItems: calendarData.aiReport.guideItems,
              ),
              const SizedBox(height: AppConstants.extraLargeSpacing - 2),

              // 월간 트렌드 분석
              MonthlyTrendAnalysis(
                title: '월간 트렌드 분석',
                radarEntries: calendarData.monthlyTrend.radarEntries,
                radarTitles: calendarData.monthlyTrend.radarTitles,
              ),
              const SizedBox(height: AppConstants.defaultSpacing + 4),

              // 월간 요약
              MonthlySummary(
                title: '월간 요약',
                summaryText: calendarData.monthlySummary.summaryText,
                bulletPoints: calendarData.monthlySummary.bulletPoints,
              ),
              const SizedBox(height: AppConstants.extraLargeSpacing),
            ],
          ),
        ),
      ),
    );
  }
}
