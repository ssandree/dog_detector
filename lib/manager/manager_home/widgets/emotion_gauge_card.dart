// lib/features/home/widgets/emotion_gauge_card.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_colors.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../features/pet/application/current_pet_provider.dart';
import '../../logic/provider/emotion_data_provider.dart';

class EmotionGaugeCard extends ConsumerStatefulWidget {
  const EmotionGaugeCard({super.key});

  @override
  ConsumerState<EmotionGaugeCard> createState() => _EmotionGaugeCardState();
}

class _EmotionGaugeCardState extends ConsumerState<EmotionGaugeCard> {
  DateTime _selectedDate = DateTime.now();

  Color _calculateEmotionColor(double positiveRatio) {
    final red = (255 * (1 - positiveRatio)).round();
    final green = (255 * positiveRatio).round();
    return Color.fromRGBO(red, green, 0, 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final asyncData = ref.watch(emotionDataProvider(date));

    final petInfo = ref.watch(currentPetProvider);
    final petName = petInfo?.name ?? '';

    return asyncData.when(
      data: (result) {
        final emotions = result.emotionData;
        final ratio = result.positiveRatio;
        final empty = emotions.isEmpty;

        // 데이터가 없으면 0%로 표시
        final progressValue = empty ? 0.0 : ratio;
        final score = empty ? 0 : (ratio * 100).round();
        final gaugeColor = _calculateEmotionColor(progressValue);

        final now = DateTime.now();
        final isToday =
            date.year == now.year && date.month == now.month && date.day == now.day;

        return AppCards.basic(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                empty
                    ? '${isToday ? '오늘' : '어제'} ${petName}의 기분 점수는 0점'
                    : '${isToday ? '오늘' : '어제'} ${petName}의 기분 점수는 $score점',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey12,
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = isToday
                        ? DateTime.now().subtract(const Duration(days: 1))
                        : DateTime.now();
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isToday ? '어제의 건강 보기' : '오늘의 건강 보기',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey9,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildProgressChart(
                progress: progressValue,
                score: score,
                isEmpty: empty,
                color: gaugeColor,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: empty
                    ? List.generate(
                        3,
                        (_) => _buildEmptyEmotionBox(),
                      )
                    : emotions.take(3).map((e) => _buildEmotionBox(e)).toList(),
              ),
            ],
          ),
        );
      },
      loading: () => AppCards.basic(
        padding: const EdgeInsets.all(20),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppCards.basic(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '건강 이벤트를 불러오지 못했어요',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            Text(e.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart({
    required double progress,
    required int score,
    required bool isEmpty,
    required Color color,
  }) {
    final progressValue = progress.clamp(0.0, 1.0);

    return SizedBox(
      height: 80,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          final indicatorLeft =
              progressValue == 0 ? 0.0 : (barWidth * progressValue) - 30.0;

          return Stack(
            children: [
              Center(
                child: Container(
                  width: double.infinity,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.grey3,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FractionallySizedBox(
                      widthFactor: progressValue,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isEmpty
                              ? null
                              : LinearGradient(
                                  colors: [
                                    color.withValues(alpha: 0.8),
                                    color,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                          color: isEmpty ? AppColors.grey3 : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: indicatorLeft.clamp(0.0, barWidth - 60.0),
                top: 0,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isEmpty ? AppColors.grey6 : color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isEmpty
                          ? AppColors.grey6
                          : color.withValues(alpha: 0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isEmpty ? AppColors.grey6 : color).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$score%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmotionBox(Map<String, dynamic> item) {
    final emotion = item['emotion'] as String;
    final percent = item['percentage'] as int;
    final colorHex = item['color'] as String;
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    final bg = color.withValues(alpha: 0.4);

    return Container(
      width: 85,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emotion,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.grey12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEmotionBox() {
    return Container(
      width: 70,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.grey5,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            '-',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.grey9,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '0%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.grey9,
            ),
          ),
        ],
      ),
    );
  }
}
