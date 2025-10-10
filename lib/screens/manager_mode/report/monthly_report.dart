import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'widgets/report_widgets.dart';
import '../../../core/index_export.dart';

class MonthlyReport extends StatelessWidget {
  const MonthlyReport({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppConstants.cameraSettingPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                // 월간 선택기
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: AppConstants.appBarIconSize),
                      onPressed: () {
                        // 이전 달
                      },
                    ),
                    Column(
                      children: const [
                        Text(
                          '이번 달',
                          style: TextStyle(fontSize: AppConstants.titleFontSize - 6, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '2025년 9월',
                          style: TextStyle(fontSize: AppConstants.smallFontSize, color: AppColors.grey6),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: AppConstants.appBarIconSize),
                      onPressed: () {
                        // 다음 달
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultSpacing + 4),

                // 감정 통계 섹션
                const Text(
                  '월간 감정 통계',
                  style: TextStyle(fontSize: AppConstants.titleFontSize - 4, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppConstants.defaultSpacing - 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RankChip(
                      rankLabel: 'Top 1',
                      text: '행복함 342회',
                      backgroundColor: AppColors.green1,
                      borderColor: AppColors.green3,
                    ),
                    RankChip(
                      rankLabel: 'Top 2',
                      text: '불안함 267회',
                      backgroundColor: AppColors.coral1,
                      borderColor: AppColors.coral3,
                    ),
                    RankChip(
                      rankLabel: 'Top 3',
                      text: '편안함 198회',
                      backgroundColor: AppColors.green1,
                      borderColor: AppColors.green3,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultSpacing + 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
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
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultSpacing + 4),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LegendItem(color: AppColors.green5, label: '행복함'),
                          LegendItem(color: AppColors.coral4, label: '불안함'),
                          LegendItem(color: AppColors.green3, label: '편안함'),
                          LegendItem(color: AppColors.coral3, label: '불쾌함'),
                          LegendItem(color: AppColors.grey4, label: '기타'),
                        ],
                      ),
                    ),
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
                AppCards.alert(
                  message: '이번 달 슬개골 탈구 의심 행동이 32회 감지되었습니다.',
                  icon: Icons.warning_amber_rounded,
                  backgroundColor: AppColors.green1,
                  iconColor: AppColors.green5,
                  textColor: AppColors.green8,
                ),
                const SizedBox(height: AppConstants.defaultSpacing + 4),

                // AI 리포트 섹션
                Container(
                  padding: AppConstants.cameraSettingPadding,
                  decoration: BoxDecoration(
                    color: AppColors.grey1,
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'AI 리포트',
                            style: TextStyle(
                              fontSize: AppConstants.titleFontSize - 4,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.smallSpacing, vertical: AppConstants.smallSpacing - 4),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                            ),
                            child: const Text(
                              '위험',
                              style: TextStyle(
                                fontSize: AppConstants.smallFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.smallSpacing),
                      const Text(
                        '이번 달 도도의 종합 분석을 AI가 완료했어요!',
                        style: TextStyle(
                          fontSize: AppConstants.defaultFontSize - 2,
                          color: AppColors.grey7,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultSpacing),
                      const Text(
                        '월간 감정 분석 결과 불안·불쾌한 감정이 52%로 긍정적인 감정 48%보다 높았습니다.',
                        style: TextStyle(
                          fontSize: AppConstants.defaultFontSize,
                          color: AppColors.black,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallSpacing + 4),
                      const Text(
                        '이번 달 슬개골 탈구 의심 행동이 총 32회 감지되었습니다. 3주차에 집중적으로 나타났으며, 현재 단계는 \'위험\'에 해당합니다. 즉시 전문의 상담이 필요합니다.',
                        style: TextStyle(
                          fontSize: AppConstants.defaultFontSize,
                          color: AppColors.black,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultSpacing + 4),
                      const Text(
                        '보호자 가이드',
                        style: TextStyle(
                          fontSize: AppConstants.titleFontSize - 6,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallSpacing + 4),
                      _buildGuideItem('월 30회 이상 감지로 즉시 동물병원 방문이 필요합니다.'),
                      _buildGuideItem('3주차 패턴을 보면 특정 활동이나 환경이 원인일 가능성이 높습니다.'),
                      _buildGuideItem('수술을 고려해야 할 단계이므로 전문의와 상담하여 치료 계획을 세우세요.'),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.extraLargeSpacing - 2),

                // 월간 트렌드 분석
                const Text(
                  '월간 트렌드 분석',
                  style: TextStyle(fontSize: AppConstants.titleFontSize - 4, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppConstants.defaultSpacing - 1),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(AppConstants.defaultSpacing - 1),
                  decoration: BoxDecoration(
                    color: AppColors.grey1,
                    borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius + 2),
                  ),
                  child: RadarChart(
                    RadarChartData(
                      dataSets: [
                        RadarDataSet(
                          fillColor: AppColors.green5.withOpacity(0.3),
                          borderColor: AppColors.green5,
                          entryRadius: 5,
                          dataEntries: const [
                            RadarEntry(value: 4), // 행복함
                            RadarEntry(value: 2), // 불안함
                            RadarEntry(value: 3), // 편안함
                            RadarEntry(value: 2), // 불쾌함
                            RadarEntry(value: 4), // 활동량
                            RadarEntry(value: 3), // 건강상태
                          ],
                        ),
                      ],
                      radarBorderData: BorderSide(color: AppColors.grey4, width: 2),
                      titlePositionPercentageOffset: 0.2,
                      titleTextStyle: const TextStyle(
                        color: AppColors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      getTitle: (index, angle) {
                        const titles = ['행복함', '불안함', '편안함', '불쾌함', '활동량', '건강상태'];
                        return RadarChartTitle(
                          text: titles[index],
                          angle: angle,
                        );
                      },
                      tickBorderData: BorderSide(color: AppColors.grey4),
                      gridBorderData: BorderSide(color: AppColors.grey4, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultSpacing + 4),

                // 월간 요약
                const Text(
                  '월간 요약',
                  style: TextStyle(fontSize: AppConstants.titleFontSize - 4, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppConstants.defaultSpacing - 1),
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultSpacing - 1),
                  decoration: BoxDecoration(
                    color: AppColors.green1,
                    borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius + 2),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이번 달은 전반적으로 안정적인 감정 상태를 유지했습니다.',
                        style: TextStyle(fontSize: AppConstants.defaultFontSize, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: AppConstants.smallSpacing),
                      Text(
                        '• 행복한 감정이 가장 많이 나타났습니다 (342회)\n• 주간별로 안정적인 패턴을 보였습니다\n• 활동량이 점진적으로 증가하는 추세입니다',
                        style: TextStyle(fontSize: AppConstants.defaultFontSize - 2),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }



  Widget _buildTrendItem(String week, String trend, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallSpacing),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: AppConstants.appBarIconSize,
          ),
          const SizedBox(width: AppConstants.smallSpacing + 2),
          Expanded(
            child: Text(
              week,
              style: const TextStyle(fontSize: AppConstants.defaultFontSize - 2, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.smallSpacing, vertical: AppConstants.smallSpacing - 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius - 3),
            ),
            child: Text(
              trend,
              style: TextStyle(
                fontSize: AppConstants.smallFontSize,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String time, String count, Color color) {
    return Column(
      children: [
        Container(
          width: AppConstants.smallSpacing,
          height: AppConstants.smallSpacing,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing - 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: AppConstants.smallFontSize,
            color: AppColors.grey7,
          ),
        ),
        Text(
          count,
          style: TextStyle(
            fontSize: AppConstants.smallFontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppConstants.smallSpacing - 2, right: AppConstants.smallSpacing),
            width: AppConstants.smallSpacing - 4,
            height: AppConstants.smallSpacing - 4,
            decoration: const BoxDecoration(
              color: AppColors.green5,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: AppConstants.defaultFontSize - 2,
                color: AppColors.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
