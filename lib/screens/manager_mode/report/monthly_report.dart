import 'package:flutter/material.dart';
import 'dart:math';
import '../../../widgets/cards/app_cards.dart';
import '../../../constants/app_constants.dart';
import '../../../theme/app_colors.dart';

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
                    _buildEmotionChip('Top 1', '행복함', '342회', AppColors.green1, AppColors.green3),
                    _buildEmotionChip('Top 2', '불안함', '267회', AppColors.coral1, AppColors.coral3),
                    _buildEmotionChip('Top 3', '편안함', '198회', AppColors.green1, AppColors.green3),
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
                        child: CustomPaint(
                          painter: DonutChartPainter(
                            percentages: [0.18, 0.25, 0.22, 0.20, 0.15],
                            colors: [
                              AppColors.green5, // 행복함
                              AppColors.coral4, // 불안함
                              AppColors.green3, // 편안함
                              AppColors.coral3, // 불쾌함
                              AppColors.grey4, // 기타
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
                          _buildLegendItem(AppColors.green5, '행복함'),
                          _buildLegendItem(AppColors.coral4, '불안함'),
                          _buildLegendItem(AppColors.green3, '편안함'),
                          _buildLegendItem(AppColors.coral3, '불쾌함'),
                          _buildLegendItem(AppColors.grey4, '기타'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultSpacing + 4),

                // 감정 바
                Row(
                  children: [
                    Expanded(
                      flex: 52,
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.coral2,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppConstants.smallBorderRadius - 2),
                            bottomLeft: Radius.circular(AppConstants.smallBorderRadius - 2),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: AppConstants.smallSpacing + 2),
                        child: const Text(
                          '부정 52%',
                          style: TextStyle(color: AppColors.black, fontSize: AppConstants.smallFontSize),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 48,
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.green2,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(AppConstants.smallBorderRadius - 2),
                            bottomRight: Radius.circular(AppConstants.smallBorderRadius - 2),
                          ),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppConstants.smallSpacing + 2),
                        child: const Text(
                          '긍정 48%',
                          style: TextStyle(color: AppColors.black, fontSize: AppConstants.smallFontSize),
                        ),
                      ),
                    ),
                  ],
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
                  padding: const EdgeInsets.all(AppConstants.defaultSpacing - 1),
                  decoration: BoxDecoration(
                    color: AppColors.grey1,
                    borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius + 2),
                  ),
                  child: Column(
                    children: [
                      _buildTrendItem('1주차', '감정 안정', AppColors.green5, Icons.trending_up),
                      _buildTrendItem('2주차', '약간의 불안', AppColors.coral5, Icons.trending_flat),
                      _buildTrendItem('3주차', '감정 안정', AppColors.green5, Icons.trending_up),
                      _buildTrendItem('4주차', '활동 증가', AppColors.green5, Icons.trending_up),
                    ],
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


  Widget _buildEmotionChip(String top, String emotion, String count, Color bgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.smallSpacing + 4, vertical: AppConstants.smallSpacing),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius + 2),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            top,
            style: const TextStyle(fontSize: AppConstants.smallFontSize, color: AppColors.grey6),
          ),
          Text(
            '$emotion $count',
            style: const TextStyle(fontSize: AppConstants.defaultFontSize, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallSpacing - 4),
      child: Row(
        children: [
          Container(
            width: AppConstants.defaultSpacing,
            height: AppConstants.defaultSpacing,
            color: color,
          ),
          const SizedBox(width: AppConstants.smallSpacing),
          Text(
            text,
            style: const TextStyle(fontSize: AppConstants.defaultFontSize - 2),
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
          color: AppColors.white,
          fontSize: AppConstants.smallFontSize,
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
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}