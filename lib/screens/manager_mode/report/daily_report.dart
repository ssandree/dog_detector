import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widgets/report_widgets.dart';
import '../../../theme/app_colors.dart';

class DailyReport extends StatelessWidget {
  const DailyReport({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                // 날짜 선택기
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () {
                        // 이전 날
                      },
                    ),
                    Column(
                      children: const [
                        Text(
                          '오늘',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '25.10.01',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 20),
                      onPressed: () {
                        // 다음 날
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 감정 통계 섹션
                const Text(
                  '감정 통계',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RankChip(
                      rankLabel: 'Top 1',
                      text: '행복함 15회',
                      backgroundColor: const Color(0xFFE8F5E9),
                      borderColor: const Color(0xFFC8E6C9),
                    ),
                    RankChip(
                      rankLabel: 'Top 2',
                      text: '불안함 9회',
                      backgroundColor: const Color(0xFFFFF3E0),
                      borderColor: const Color(0xFFFFECB3),
                    ),
                    RankChip(
                      rankLabel: 'Top 3',
                      text: '편안함 8회',
                      backgroundColor: const Color(0xFFE8F5E9),
                      borderColor: const Color(0xFFC8E6C9),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                                value: 12,
                                title: '12%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: AppColors.coral4,
                                value: 34,
                                title: '34%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: AppColors.green3,
                                value: 30,
                                title: '30%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: AppColors.coral3,
                                value: 14,
                                title: '14%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: AppColors.grey4,
                                value: 10,
                                title: '10%',
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
                    const SizedBox(width: 20),
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
                const SizedBox(height: 20),

                // 감정 바
                EmotionRatioBar(
                  negativePercent: 60,
                  positivePercent: 40,
                  negativeLabel: '부정 60%',
                  positiveLabel: '긍정 40%',
                  negativeColor: AppColors.coral3,
                  positiveColor: AppColors.green3,
                ),
                const SizedBox(height: 20),

                // 시간대별 감정 변화 차트
                const Text(
                  '시간대별 감정 변화',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey3),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 20,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.round()}회',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              const style = TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              );
                              Widget text;
                              switch (value.toInt()) {
                                case 0:
                                  text = const Text('오전', style: style);
                                  break;
                                case 1:
                                  text = const Text('오후', style: style);
                                  break;
                                case 2:
                                  text = const Text('저녁', style: style);
                                  break;
                                default:
                                  text = const Text('', style: style);
                                  break;
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 16,
                                child: text,
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 5,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: 8,
                              color: AppColors.green5,
                              width: 22,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: 12,
                              color: AppColors.coral4,
                              width: 22,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: 6,
                              color: AppColors.green3,
                              width: 22,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 슬개골 탈구 의심 행동 감지 알림
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.green1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.green5,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.green5,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              '오늘은 슬개골 탈구 의심 행동이 2회 감지되었습니다.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.green8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '오늘 감지 횟수',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey7,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '2회',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.green8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '시간대별 분포',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey7,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildTimeSlot('오전', '1회', AppColors.activityStatusColor),
                                    const SizedBox(width: 12),
                                    _buildTimeSlot('오후', '1회', AppColors.activityStatusColor),
                                    const SizedBox(width: 12),
                                    _buildTimeSlot('저녁', '0회', AppColors.grey5),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // AI 리포트 섹션
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.grey1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'AI 리포트',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.green5,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '관심 필요',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '오늘 도도의 하루를 AI가 요약했어요!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '하루 중 불안·불쾌한 감정이 60%로 긍정적인 감정 40% 보다 약간 더 높았습니다.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '오늘 슬개골 탈구 의심 행동이 총 2회 감지되었습니다. 현재 단계는 \'관심\'에 해당하며, 무릎 관절에 부담이 있었을 수 있으니 보호자의 관찰이 필요합니다.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '보호자 가이드',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildGuideItem('오늘은 무리한 산책이나 계단 오르내리기, 잦은 점프 같은 활동은 피하는 것이 좋습니다.'),
                      _buildGuideItem('내일도 같은 행동이 반복된다면 가까운 동물병원에 상담을 권장합니다.'),
                      _buildGuideItem('대신 가벼운 산책이나 실내 놀이를 통해 스트레스를 완화시켜주는 것이 도도의 정서 안정에도 도움이 될 수 있습니다.'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String time, String count, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
          ),
        ),
        Text(
          count,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.green5,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
      child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
