import '../../../../core/index_export.dart';
import '../../../../data/report_mock.dart';
import 'package:fl_chart/fl_chart.dart';

/// 오늘의 활동량을 표시하는 바 차트 위젯
class TodayActivityChart extends StatelessWidget {
  const TodayActivityChart({super.key});

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // 오늘 날짜 데이터 가져오기
    final todayKey = _formatDate(DateTime.now());
    final todayData = mockDailyReports[todayKey];
    final chartData = todayData?['chartData'] as List<dynamic>? ?? [];

    if (chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    // 최대 활동량 계산
    final maxActivity = chartData.isEmpty
        ? 10.0
        : (chartData.map((item) => (item['activity'] as int? ?? 0)).reduce((a, b) => a > b ? a : b) * 1.2).ceil().toDouble();

    return AppCards.basic(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 활동량',
            style: TextStyle(
              fontSize: AppConstants.titleFontSize - 6,
              fontWeight: FontWeight.bold,
              color: AppColors.grey12,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxActivity,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final hour = chartData[groupIndex]['hour'] as String;
                      return BarTooltipItem(
                        '${hour}시\n${rod.toY.round()}회',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < chartData.length) {
                          final hour = chartData[index]['hour'] as String;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${hour}시',
                              style: const TextStyle(
                                color: AppColors.grey7,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: maxActivity > 0 ? (maxActivity / 5).ceil().toDouble() : 2,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: AppColors.grey7,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: chartData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final activity = (item['activity'] as int? ?? 0).toDouble();
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: activity,
                        color: AppColors.green6,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

