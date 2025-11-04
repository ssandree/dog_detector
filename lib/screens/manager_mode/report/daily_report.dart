import 'package:fl_chart/fl_chart.dart';
import '../../../core/index_export.dart';
import '../../../widgets/error_widget.dart';
import 'widgets/report_widgets.dart';

class DailyReport extends ConsumerStatefulWidget {
  const DailyReport({super.key});

  @override
  ConsumerState<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends ConsumerState<DailyReport> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final dailyReportAsync = ref.watch(dailyReportProvider(_selectedDate));

    return AsyncValueWidget<Map<String, dynamic>>(
      asyncValue: dailyReportAsync,
      data: (context, reportData) => _buildContent(reportData),
      onRetry: () => ref.invalidate(dailyReportProvider(_selectedDate)),
    );
  }

  Widget _buildContent(Map<String, dynamic> reportData) {
    final date = reportData['date'] as String? ?? '2025-10-11';
    final dateTime = DateTime.tryParse(date) ?? DateTime.now();
    final dateStr = '${dateTime.year.toString().substring(2)}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';

    // 감정 통계 계산 (mock 데이터 구조에 맞게)
    final events = reportData['events'] as List<dynamic>? ?? [];
    final emotionCounts = <String, int>{};
    for (var event in events) {
      final emotion = event['emotion'] as String? ?? '';
      emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
    }
    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topEmotions = sortedEmotions.take(3).toList();
    final rankChips = [
      if (topEmotions.isNotEmpty)
        RankChip(
          rankLabel: 'Top 1',
          text: '${topEmotions[0].key} ${topEmotions[0].value}회',
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFC8E6C9),
        ),
      if (topEmotions.length > 1)
        RankChip(
          rankLabel: 'Top 2',
          text: '${topEmotions[1].key} ${topEmotions[1].value}회',
          backgroundColor: const Color(0xFFFFF3E0),
          borderColor: const Color(0xFFFFECB3),
        ),
      if (topEmotions.length > 2)
        RankChip(
          rankLabel: 'Top 3',
          text: '${topEmotions[2].key} ${topEmotions[2].value}회',
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFC8E6C9),
        ),
    ];

    // 파이 차트 데이터 계산
    final totalCount = emotionCounts.values.fold(0, (sum, count) => sum + count);
    final pieChartSections = <PieChartSectionData>[];
    if (totalCount > 0) {
      final emotionColors = {
        '행복': AppColors.green5,
        '불안': AppColors.coral4,
        '편안': AppColors.green3,
        '불쾌': AppColors.coral3,
      };
      final defaultColor = AppColors.grey4;
      
      for (var entry in sortedEmotions.take(5)) {
        final percentage = (entry.value / totalCount * 100).round();
        final color = emotionColors[entry.key] ?? defaultColor;
        pieChartSections.add(
          PieChartSectionData(
            color: color,
            value: percentage.toDouble(),
            title: '$percentage%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color == AppColors.grey4 ? Colors.black : Colors.white,
            ),
          ),
        );
      }
    }

    // 감정 비율 계산 (긍정/부정)
    final positiveEmotions = ['행복', '편안'];
    final negativeEmotions = ['불안', '불쾌'];
    int positiveCount = 0;
    int negativeCount = 0;
    for (var entry in emotionCounts.entries) {
      if (positiveEmotions.contains(entry.key)) {
        positiveCount += entry.value;
      } else if (negativeEmotions.contains(entry.key)) {
        negativeCount += entry.value;
      }
    }
    final totalEmotionCount = positiveCount + negativeCount;
    final negativePercent = totalEmotionCount > 0 ? (negativeCount / totalEmotionCount * 100).round() : 0;
    final positivePercent = totalEmotionCount > 0 ? (positiveCount / totalEmotionCount * 100).round() : 0;

    // 시간대별 차트 데이터
    final chartData = reportData['chartData'] as List<dynamic>? ?? [];
    final timeSlotData = chartData.map((item) {
      final hour = item['hour'] as String? ?? '00';
      final activity = item['activity'] as int? ?? 0;
      return {'hour': hour, 'activity': activity};
    }).toList();

    // 건강 알림 데이터 (mock 데이터 기반)
    final healthAlertCount = events.length;
    final healthAlertMessage = '오늘은 슬개골 탈구 의심 행동이 $healthAlertCount회 감지되었습니다.';

    // AI 리포트 텍스트
    final aiComment = reportData['aiComment'] as String? ?? '오늘 도도의 하루를 AI가 요약했어요!';

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                // 날짜 선택기
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                    ),
                    Column(
                      children: [
                        const Text(
                          '오늘',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        });
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
                  children: rankChips.length >= 3 
                    ? rankChips
                    : [
                        ...rankChips,
                        ...List.generate(3 - rankChips.length, (index) => const SizedBox()),
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
                        child: pieChartSections.isNotEmpty
                          ? PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: pieChartSections,
                              ),
                            )
                          : const Center(child: Text('데이터가 없습니다')),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: sortedEmotions.take(5).map((entry) {
                          final emotionColors = {
                            '행복': AppColors.green5,
                            '불안': AppColors.coral4,
                            '편안': AppColors.green3,
                            '불쾌': AppColors.coral3,
                          };
                          return LegendItem(
                            color: emotionColors[entry.key] ?? AppColors.grey4,
                            label: entry.key,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 감정 바
                EmotionRatioBar(
                  negativePercent: negativePercent,
                  positivePercent: positivePercent,
                  negativeLabel: '부정 $negativePercent%',
                  positiveLabel: '긍정 $positivePercent%',
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
                                meta: meta,
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
                      barGroups: timeSlotData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        final activity = data['activity'] as int? ?? 0;
                        final hour = int.tryParse(data['hour'] as String? ?? '0') ?? 0;
                        final isMorning = hour < 12;
                        final isAfternoon = hour >= 12 && hour < 18;
                        final color = isMorning 
                          ? AppColors.green5 
                          : isAfternoon 
                            ? AppColors.coral4 
                            : AppColors.green3;
                        
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: activity.toDouble(),
                              color: color,
                              width: 22,
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
                          Expanded(
                            child: Text(
                              healthAlertMessage,
                              style: const TextStyle(
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
                                Text(
                                  '$healthAlertCount회',
                                  style: const TextStyle(
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
                      Text(
                        aiComment,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '하루 중 불안·불쾌한 감정이 $negativePercent%로 긍정적인 감정 $positivePercent%보다 ${negativePercent > positivePercent ? '높았습니다' : '낮았습니다'}.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '오늘 슬개골 탈구 의심 행동이 총 $healthAlertCount회 감지되었습니다. 현재 단계는 \'관심\'에 해당하며, 무릎 관절에 부담이 있었을 수 있으니 보호자의 관찰이 필요합니다.',
                        style: const TextStyle(
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
