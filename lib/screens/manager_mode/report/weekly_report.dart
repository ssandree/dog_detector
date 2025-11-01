import 'package:fl_chart/fl_chart.dart';
import '../../../core/index_export.dart';
import 'widgets/report_widgets.dart';

class WeeklyReport extends StatelessWidget {
  const WeeklyReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                // 주간 선택기
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () {
                        // 이전 주
                      },
                    ),
                    Column(
                      children: const [
                        Text(
                          '이번 주',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '25.09.30 - 25.10.06',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 20),
                      onPressed: () {
                        // 다음 주
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 감정 통계 섹션
                const Text(
                  '주간 감정 통계',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RankChip(
                      rankLabel: 'Top 1',
                      text: '행복함 89회',
                      backgroundColor: AppColors.green1,
                      borderColor: AppColors.green3,
                    ),
                    RankChip(
                      rankLabel: 'Top 2',
                      text: '불안함 67회',
                      backgroundColor: AppColors.coral1,
                      borderColor: AppColors.coral3,
                    ),
                    RankChip(
                      rankLabel: 'Top 3',
                      text: '편안함 54회',
                      backgroundColor: AppColors.green1,
                      borderColor: AppColors.green3,
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
                                color: const Color(0xFF4CAF50),
                                value: 15,
                                title: '15%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: const Color(0xFFFFAB91),
                                value: 28,
                                title: '28%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: const Color(0xFFA5D6A7),
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
                                color: const Color(0xFFE0B29F),
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
                                color: const Color(0xFFE0E0E0),
                                value: 14,
                                title: '14%',
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
                  negativePercent: 55,
                  positivePercent: 45,
                  negativeLabel: '부정 55%',
                  positiveLabel: '긍정 45%',
                  negativeColor: AppColors.coral3,
                  positiveColor: AppColors.green3,
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
                              '이번 주 슬개골 탈구 의심 행동이 8회 감지되었습니다.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
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
                                  '주간 감지 횟수',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '8회',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
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
                                  '요일별 분포',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildTimeSlot('월', '2회', AppColors.activityStatusColor),
                                    const SizedBox(width: 8),
                                    _buildTimeSlot('화', '1회', AppColors.activityStatusColor),
                                    const SizedBox(width: 8),
                                    _buildTimeSlot('수', '2회', AppColors.activityStatusColor),
                                    const SizedBox(width: 8),
                                    _buildTimeSlot('목', '1회', AppColors.activityStatusColor),
                                    const SizedBox(width: 8),
                                    _buildTimeSlot('금', '2회', AppColors.activityStatusColor),
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
                              color: AppColors.activityStatusColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '주의',
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
                        '이번 주 도도의 패턴을 AI가 분석했어요!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '주간 감정 분석 결과 불안·불쾌한 감정이 55%로 긍정적인 감정 45%보다 높았습니다.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '이번 주 슬개골 탈구 의심 행동이 총 8회 감지되었습니다. 월요일과 수요일, 금요일에 집중적으로 나타났으며, 현재 단계는 \'주의\'에 해당합니다.',
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
                      _buildGuideItem('주 3회 이상 감지되는 패턴이므로 활동량 조절이 필요합니다.'),
                      _buildGuideItem('특히 월요일, 수요일, 금요일에는 더욱 주의깊은 관찰이 필요합니다.'),
                      _buildGuideItem('동물병원 상담을 통해 정확한 진단과 치료 계획을 세우는 것을 권장합니다.'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 주간 활동 패턴
                const Text(
                  '주간 활동 패턴',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey3),
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.grey3,
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: AppColors.grey3,
                            strokeWidth: 1,
                          );
                        },
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
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              const style = TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              );
                              Widget text;
                              switch (value.toInt()) {
                                case 0:
                                  text = const Text('월', style: style);
                                  break;
                                case 1:
                                  text = const Text('화', style: style);
                                  break;
                                case 2:
                                  text = const Text('수', style: style);
                                  break;
                                case 3:
                                  text = const Text('목', style: style);
                                  break;
                                case 4:
                                  text = const Text('금', style: style);
                                  break;
                                case 5:
                                  text = const Text('토', style: style);
                                  break;
                                case 6:
                                  text = const Text('일', style: style);
                                  break;
                                default:
                                  text = const Text('', style: style);
                                  break;
                              }
                              return SideTitleWidget(
                                meta: meta,
                                space: 8,
                                child: text,
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 40,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              String text;
                              switch (value.toInt()) {
                                case 1:
                                  text = '낮음';
                                  break;
                                case 2:
                                  text = '보통';
                                  break;
                                case 3:
                                  text = '높음';
                                  break;
                                default:
                                  text = '';
                                  break;
                              }
                              return Text(
                                text,
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
                        show: true,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      minX: 0,
                      maxX: 6,
                      minY: 0,
                      maxY: 4,
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 3), // 월요일 - 높음
                            FlSpot(1, 2), // 화요일 - 보통
                            FlSpot(2, 1), // 수요일 - 낮음
                            FlSpot(3, 3), // 목요일 - 높음
                            FlSpot(4, 2), // 금요일 - 보통
                            FlSpot(5, 3), // 토요일 - 높음
                            FlSpot(6, 1), // 일요일 - 낮음
                          ],
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4CAF50),
                              const Color(0xFF81C784),
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: const Color(0xFF4CAF50),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4CAF50).withValues(alpha: 0.3),
                                const Color(0xFF4CAF50).withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ],
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
              color: Color(0xFF4CAF50),
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
