import 'package:flutter/material.dart';
import 'dart:math';

class MonthlyReport extends StatelessWidget {
  const MonthlyReport({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                // 월간 선택기
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () {
                        // 이전 달
                      },
                    ),
                    Column(
                      children: const [
                        Text(
                          '이번 달',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '2025년 9월',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 20),
                      onPressed: () {
                        // 다음 달
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 감정 통계 섹션
                const Text(
                  '월간 감정 통계',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildEmotionChip('Top 1', '행복함', '342회', const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)),
                    _buildEmotionChip('Top 2', '불안함', '267회', const Color(0xFFFFF3E0), const Color(0xFFFFECB3)),
                    _buildEmotionChip('Top 3', '편안함', '198회', const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)),
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
                        child: CustomPaint(
                          painter: DonutChartPainter(
                            percentages: [0.18, 0.25, 0.22, 0.20, 0.15],
                            colors: [
                              const Color(0xFF4CAF50), // 행복함
                              const Color(0xFFFFAB91), // 불안함
                              const Color(0xFFA5D6A7), // 편안함
                              const Color(0xFFE0B29F), // 불쾌함
                              const Color(0xFFE0E0E0), // 기타
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
                          _buildLegendItem(const Color(0xFF4CAF50), '행복함'),
                          _buildLegendItem(const Color(0xFFFFAB91), '불안함'),
                          _buildLegendItem(const Color(0xFFA5D6A7), '편안함'),
                          _buildLegendItem(const Color(0xFFE0B29F), '불쾌함'),
                          _buildLegendItem(const Color(0xFFE0E0E0), '기타'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 감정 바
                Row(
                  children: [
                    Expanded(
                      flex: 52,
                      child: Container(
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0B29F),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 10),
                        child: const Text(
                          '부정 52%',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 48,
                      child: Container(
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFA5D6A7),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 10),
                        child: const Text(
                          '긍정 48%',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 슬개골 탈구 의심 행동 감지 알림
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
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
                              color: const Color(0xFF4CAF50),
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
                              '이번 달 슬개골 탈구 의심 행동이 32회 감지되었습니다.',
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
                                  '월간 감지 횟수',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '32회',
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
                                  '주간별 분포',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildTimeSlot('1주', '8회', const Color(0xFFFF9800)),
                                    const SizedBox(width: 8),
                                    _buildTimeSlot('2주', '6회', const Color(0xFFFF9800)),
                                    const SizedBox(width: 8),
                                    _buildTimeSlot('3주', '10회', const Color(0xFFF44336)),
                                    const SizedBox(width: 8),
                                    _buildTimeSlot('4주', '8회', const Color(0xFFFF9800)),
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
                    color: const Color(0xFFF5F5F5),
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
                              color: const Color(0xFFF44336),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '위험',
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
                        '이번 달 도도의 종합 분석을 AI가 완료했어요!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '월간 감정 분석 결과 불안·불쾌한 감정이 52%로 긍정적인 감정 48%보다 높았습니다.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '이번 달 슬개골 탈구 의심 행동이 총 32회 감지되었습니다. 3주차에 집중적으로 나타났으며, 현재 단계는 \'위험\'에 해당합니다. 즉시 전문의 상담이 필요합니다.',
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
                      _buildGuideItem('월 30회 이상 감지로 즉시 동물병원 방문이 필요합니다.'),
                      _buildGuideItem('3주차 패턴을 보면 특정 활동이나 환경이 원인일 가능성이 높습니다.'),
                      _buildGuideItem('수술을 고려해야 할 단계이므로 전문의와 상담하여 치료 계획을 세우세요.'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 월간 트렌드 분석
                const Text(
                  '월간 트렌드 분석',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _buildTrendItem('1주차', '감정 안정', const Color(0xFF4CAF50), Icons.trending_up),
                      _buildTrendItem('2주차', '약간의 불안', const Color(0xFFFF9800), Icons.trending_flat),
                      _buildTrendItem('3주차', '감정 안정', const Color(0xFF4CAF50), Icons.trending_up),
                      _buildTrendItem('4주차', '활동 증가', const Color(0xFF4CAF50), Icons.trending_up),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 월간 요약
                const Text(
                  '월간 요약',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이번 달은 전반적으로 안정적인 감정 상태를 유지했습니다.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• 행복한 감정이 가장 많이 나타났습니다 (342회)\n• 주간별로 안정적인 패턴을 보였습니다\n• 활동량이 점진적으로 증가하는 추세입니다',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }


  Widget _buildEmotionChip(String top, String emotion, String count, Color bgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            top,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            '$emotion $count',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(String week, String trend, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              week,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              trend,
              style: TextStyle(
                fontSize: 12,
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

// 도넛 차트를 그리는 CustomPainter
class DonutChartPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;

  DonutChartPainter({required this.percentages, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.8; // 전체 크기를 80%로 줄임
    final innerRadius = radius * 0.7; // 빈 공간을 70%로 줄임

    double startAngle = -pi / 2;

    for (int i = 0; i < percentages.length; i++) {
      final sweepAngle = 2 * pi * percentages[i];
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // 퍼센트 텍스트 그리기
      final midAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.8;
      final textX = center.dx + textRadius * cos(midAngle);
      final textY = center.dy + textRadius * sin(midAngle);

      final textSpan = TextSpan(
        text: '${(percentages[i] * 100).round()}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, Offset(textX - textPainter.width / 2, textY - textPainter.height / 2));

      startAngle += sweepAngle;
    }

    // 도넛 구멍 그리기
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}