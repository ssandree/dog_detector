import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../report/widgets/emotion_ratio_bar.dart';
import '../report/widgets/report_widgets.dart';
import '../../../core/index_export.dart';
import '../calendar/widgets/calendar_section.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopNav.withNotification(
        title: '캘린더',
        showBackButton: false,
        onNotificationPressed: () {
          // 알림 기능
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            // 캘린더 섹션
            const CalendarSection(),
            
            const SizedBox(height: AppConstants.defaultSpacing + 4),

            // 월간 선택기
            DateSelector(
              title: '이번 달',
              subtitle: '2025년 9월',
              onPrevious: () {
                // 이전 달
              },
              onNext: () {
                // 다음 달
              },
            ),
            const SizedBox(height: AppConstants.defaultSpacing + 4),

            // 감정 통계 섹션
            EmotionStatsSection(
              title: '월간 감정 통계',
              rankChips: [
                RankChipData(
                  rankLabel: 'Top 1',
                  text: '행복함 342회',
                  backgroundColor: AppColors.green1,
                  borderColor: AppColors.green3,
                ),
                RankChipData(
                  rankLabel: 'Top 2',
                  text: '불안함 267회',
                  backgroundColor: AppColors.coral1,
                  borderColor: AppColors.coral3,
                ),
                RankChipData(
                  rankLabel: 'Top 3',
                  text: '편안함 198회',
                  backgroundColor: AppColors.green1,
                  borderColor: AppColors.green3,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultSpacing + 4),
            
            // 감정 파이 차트
            EmotionPieChart(
              sections: [
                PieChartSectionData(
                  color: AppColors.green5,
                  value: 18,
                  title: '18%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: AppColors.coral4,
                  value: 25,
                  title: '25%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: AppColors.green3,
                  value: 22,
                  title: '22%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: AppColors.coral3,
                  value: 20,
                  title: '20%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: AppColors.grey4,
                  value: 15,
                  title: '15%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
              legendItems: [
                LegendItemData(color: AppColors.green5, label: '행복함'),
                LegendItemData(color: AppColors.coral4, label: '불안함'),
                LegendItemData(color: AppColors.green3, label: '편안함'),
                LegendItemData(color: AppColors.coral3, label: '불쾌함'),
                LegendItemData(color: AppColors.grey4, label: '기타'),
              ],
            ),
            const SizedBox(height: AppConstants.defaultSpacing + 4),

            // 감정 바
            EmotionRatioBar(
              negativePercent: 52,
              positivePercent: 48,
              negativeLabel: '부정 52%',
              positiveLabel: '긍정 48%',
              negativeColor: AppColors.coral2,
              positiveColor: AppColors.green2,
            ),
            const SizedBox(height: AppConstants.defaultSpacing + 4),

            // 슬개골 탈구 의심 행동 감지 알림
            HealthAlertCard(
              message: '이번 달 슬개골 탈구 의심 행동이 32회 감지되었습니다.',
              detectionCount: '32회',
              countLabel: '총 감지 횟수',
              timeSlots: [
                TimeSlotData(time: '오전', count: '8회', color: AppColors.green5),
                TimeSlotData(time: '오후', count: '15회', color: AppColors.coral4),
                TimeSlotData(time: '저녁', count: '9회', color: AppColors.green3),
              ],
              icon: Icons.warning_amber_rounded,
              backgroundColor: AppColors.green1,
              iconColor: AppColors.green5,
              textColor: AppColors.green8,
            ),
            const SizedBox(height: AppConstants.defaultSpacing + 4),

            // AI 리포트 섹션
            AiReportSection(
              title: 'AI 리포트',
              subtitle: '이번 달 도도의 종합 분석을 AI가 완료했어요!',
              statusLabel: '위험',
              statusColor: AppColors.error,
              analysisTexts: [
                '월간 감정 분석 결과 불안·불쾌한 감정이 52%로 긍정적인 감정 48%보다 높았습니다.',
                '이번 달 슬개골 탈구 의심 행동이 총 32회 감지되었습니다. 3주차에 집중적으로 나타났으며, 현재 단계는 \'위험\'에 해당합니다. 즉시 전문의 상담이 필요합니다.',
              ],
              guideItems: [
                '월 30회 이상 감지로 즉시 동물병원 방문이 필요합니다.',
                '3주차 패턴을 보면 특정 활동이나 환경이 원인일 가능성이 높습니다.',
                '수술을 고려해야 할 단계이므로 전문의와 상담하여 치료 계획을 세우세요.',
              ],
            ),
            const SizedBox(height: AppConstants.extraLargeSpacing - 2),

            // 월간 트렌드 분석
            MonthlyTrendAnalysis(
              title: '월간 트렌드 분석',
              radarEntries: const [
                RadarEntry(value: 4), // 행복함
                RadarEntry(value: 2), // 불안함
                RadarEntry(value: 3), // 편안함
                RadarEntry(value: 2), // 불쾌함
                RadarEntry(value: 4), // 활동량
                RadarEntry(value: 3), // 건강상태
              ],
              radarTitles: const ['행복함', '불안함', '편안함', '불쾌함', '활동량', '건강상태'],
            ),
            const SizedBox(height: AppConstants.defaultSpacing + 4),

            // 월간 요약
            MonthlySummary(
              title: '월간 요약',
              summaryText: '이번 달은 전반적으로 안정적인 감정 상태를 유지했습니다.',
              bulletPoints: const [
                '행복한 감정이 가장 많이 나타났습니다 (342회)',
                '주간별로 안정적인 패턴을 보였습니다',
                '활동량이 점진적으로 증가하는 추세입니다',
              ],
            ),
            const SizedBox(height: AppConstants.extraLargeSpacing),
          ],
        ),
      ),
    );
  }
}
