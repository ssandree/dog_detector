import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/index_export.dart';

/// 주간 활동 패턴을 표시하는 라인 차트 위젯
class WeeklyActivityLineChart extends StatelessWidget {
  /// 주간 통계 데이터 (weeklyStats)
  /// 각 항목은 {'date': '10-06', 'bark': 10, 'howl': 2} 형태
  final List<dynamic> weeklyStats;

  const WeeklyActivityLineChart({
    super.key,
    required this.weeklyStats,
  });

  @override
  Widget build(BuildContext context) {
    // weeklyStats에서 활동 수준 계산 (bark + howl)
    // 주의: 주 시작일이 월요일이므로, 일~월 순서로 표시하려면 데이터를 재정렬해야 함
    // 일단 데이터가 월~일 순서로 오는 경우를 가정하고, 일~월 순서로 변환
    final reorderedStats = _reorderWeeklyStats(weeklyStats);
    
    final activityData = reorderedStats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final bark = (stat['bark'] as num?)?.toInt() ?? 0;
      final howl = (stat['howl'] as num?)?.toInt() ?? 0;
      final totalActivity = bark + howl;
      
      // 활동 수준을 0-3 범위로 정규화 (낮음: 0-3, 보통: 4-7, 높음: 8+)
      final activityLevel = totalActivity == 0 
          ? 0.0 
          : totalActivity <= 3 
              ? 1.0 
              : totalActivity <= 7 
                  ? 2.0 
                  : 3.0;
      
      return FlSpot(index.toDouble(), activityLevel);
    }).toList();

    // 최대 활동 수준 계산
    final maxActivity = activityData.isEmpty 
        ? 3.0 
        : activityData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey3),
      ),
      child: activityData.isEmpty
          ? const Center(child: Text('데이터가 없습니다'))
          : LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.grey3,
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (_) => FlLine(
                    color: AppColors.grey3,
                    strokeWidth: 1,
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
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (v, meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        // 주간 차트: 일~월 순서 (일요일부터 시작)
                        const days = ['일', '월', '화', '수', '목', '금', '토'];
                        final index = v.toInt();
                        final label = (index >= 0 && index < days.length)
                            ? days[index]
                            : '';
                        return SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Text(label, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) {
                        const labels = {0: '없음', 1: '낮음', 2: '보통', 3: '높음'};
                        final text = labels[v.toInt()] ?? '';
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
                maxX: (reorderedStats.length - 1).toDouble().clamp(0, 6),
                minY: 0,
                maxY: maxActivity.clamp(1, 4),
                lineBarsData: [
                  LineChartBarData(
                    spots: activityData,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
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
    );
  }

  /// 주간 통계 데이터를 일~월 순서로 재정렬
  /// 입력: 월~일 순서 (주 시작일이 월요일)
  /// 출력: 일~월 순서 (차트 표시용)
  List<dynamic> _reorderWeeklyStats(List<dynamic> stats) {
    if (stats.isEmpty) return stats;
    
    // 주 시작일이 월요일이므로, 월~일 순서를 일~월 순서로 변환
    // 월(0), 화(1), 수(2), 목(3), 금(4), 토(5), 일(6) -> 일(0), 월(1), 화(2), 수(3), 목(4), 금(5), 토(6)
    final reordered = <dynamic>[];
    
    // 일요일 데이터가 있으면 맨 앞에 추가 (보통 주간 데이터는 월~일 7일치)
    if (stats.length >= 7) {
      reordered.add(stats[6]); // 일요일
      // 월~토 추가
      for (int i = 0; i < 6; i++) {
        reordered.add(stats[i]);
      }
    } else {
      // 데이터가 7일 미만인 경우 그대로 반환 (일~월 순서로 표시되지만 데이터는 부족)
      return stats;
    }
    
    return reordered;
  }
}

