import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/provider/current_pet_provider.dart';
import '../../../../core/provider/event_provider.dart';
import '../../../../core/widgets/app_cards.dart';

/// 감정 데이터 Provider (날짜 파라미터 포함)
final emotionDataProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, DateTime>((ref, date) async {
  final petInfo = ref.watch(currentPetProvider);
  final petId = petInfo?.petId;
  if (petId == null) return [];

  final request = DailyEventRequest(
    petId: petId,
    date: date,
  );

  final dailyEvents = await ref.watch(dailyEventsProvider(request).future);
  final events = dailyEvents.events
      .where((event) => event.finalEmotion != null)
      .toList();

  if (events.isEmpty) return [];

  // 감정별 카운트
  final emotionCount = <String, int>{};
  for (final event in events) {
    final emotion = event.finalEmotion!;
    emotionCount[emotion] = (emotionCount[emotion] ?? 0) + 1;
  }

  final totalCount = events.length;

  // 감정별 색상 매핑
  final emotionColors = {
    '행복': '#FFD700',
    '평온': '#87CEEB',
    '활발': '#FF6B6B',
    '불안': '#FFA500',
    '화남': '#FF4500',
    '외로움': '#9370DB',
  };

  // 감정별 비율 계산 (퍼센트)
  final emotionData = emotionCount.entries.map((entry) {
    final percentage = ((entry.value / totalCount) * 100).round();
    return {
      'emotion': entry.key,
      'percentage': percentage,
      'color': emotionColors[entry.key] ?? '#808080',
    };
  }).toList();

  // 비율 순으로 정렬
  emotionData.sort((a, b) => (b['percentage'] as int).compareTo(a['percentage'] as int));

  return emotionData;
});

/// 오늘 탐지된 감정 데이터 기반 게이지 차트 카드
class EmotionGaugeCard extends ConsumerStatefulWidget {
  const EmotionGaugeCard({super.key});

  @override
  ConsumerState<EmotionGaugeCard> createState() => _EmotionGaugeCardState();
}

class _EmotionGaugeCardState extends ConsumerState<EmotionGaugeCard> {
  DateTime _selectedDate = DateTime.now();

  /// 감정을 긍정/부정으로 분류
  bool _isPositiveEmotion(String emotion) {
    switch (emotion) {
      case '행복':
      case '평온':
      case '활발':
        return true;
      case '불안':
      case '화남':
      case '외로움':
        return false;
      default:
        return false;
    }
  }

  /// 부정/긍정 비율에 따라 색상 계산 (0.0 = 빨강, 1.0 = 초록)
  Color _calculateEmotionColor(double positiveRatio) {
    // positiveRatio: 0.0 (완전 부정) ~ 1.0 (완전 긍정)
    final red = (255 * (1 - positiveRatio)).round();
    final green = (255 * positiveRatio).round();
    return Color.fromRGBO(red, green, 0, 1.0);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    
    if (selected == today) {
      return '오늘';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return '어제';
    } else {
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    }
  }

  double _calculatePositiveRatio(List<Map<String, dynamic>> emotionData) {
    if (emotionData.isEmpty) return 0.5;
    
        int positiveTotal = 0;
        int totalPercentage = 0;

        for (final data in emotionData) {
          final emotion = data['emotion'] as String;
          final percentage = data['percentage'] as int;
          totalPercentage += percentage;

          if (_isPositiveEmotion(emotion)) {
            positiveTotal += percentage;
      }
    }

    return totalPercentage > 0 ? positiveTotal / totalPercentage : 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final normalizedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final emotionDataAsync = ref.watch(emotionDataProvider(normalizedDate));

    return emotionDataAsync.when(
      data: (emotionData) {
        final isEmpty = emotionData.isEmpty;
        final positiveRatio = isEmpty ? 0.5 : _calculatePositiveRatio(emotionData);
        final positivePercent = (positiveRatio * 100).round();
        final negativePercent = ((1 - positiveRatio) * 100).round();
        final gaugeColor = _calculateEmotionColor(positiveRatio);
        
        // 감성적인 메시지 생성
        String _getMainMessage() {
          if (isEmpty) {
            return '감지된 이벤트가 없어요';
          }
          if (positiveRatio >= 0.7) {
            return '${positivePercent}% 긍정적인 하루였어요! 💚';
          } else if (positiveRatio >= 0.5) {
            return '${positivePercent}% 긍정적인 순간이 있었어요 ✨';
          } else if (positiveRatio >= 0.3) {
            return '${negativePercent}% 불안한 순간이 있었어요 💙';
          } else {
            return '${negativePercent}% 불안해 보였어요, 안아주세요 🤗';
          }
        }

        final isToday = _selectedDate.year == DateTime.now().year &&
            _selectedDate.month == DateTime.now().month &&
            _selectedDate.day == DateTime.now().day;
        final isYesterday = _selectedDate.year == DateTime.now().subtract(const Duration(days: 1)).year &&
            _selectedDate.month == DateTime.now().subtract(const Duration(days: 1)).month &&
            _selectedDate.day == DateTime.now().subtract(const Duration(days: 1)).day;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 카드
            Container(
          decoration: BoxDecoration(
                color: AppColors.beige1.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                // 왼쪽: 제목
                Text(
                  isToday ? '오늘의 감정' : '어제의 감정',
                  style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey12,
                        ),
                      ),
                // 오른쪽: 버튼
                  TextButton(
                    onPressed: () {
                    setState(() {
                      if (isToday) {
                        _selectedDate = DateTime.now().subtract(const Duration(days: 1));
                      } else {
                        _selectedDate = DateTime.now();
                      }
                    });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    backgroundColor: isToday ? AppColors.grey2 : AppColors.grey4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  child: Text(
                    isToday ? '어제의 건강 보기' : '오늘의 건강 보기',
                      style: TextStyle(
                      fontSize: 13,
                        fontWeight: FontWeight.w600,
                      color: isToday ? AppColors.grey8 : AppColors.grey9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 큰 숫자 표시: 긍정/부정 비율
              Center(
                child: Text(
                  isEmpty ? '0 / 100' : '$positivePercent / 100',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isEmpty ? AppColors.grey9 : AppColors.grey12,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '긍정적인 감정',
                  style: TextStyle(
                    fontSize: 16,
                    color: isEmpty ? AppColors.grey9 : AppColors.grey9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 작은 사각 인디케이터들 (감정별)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: isEmpty
                    ? List.generate(3, (index) {
                        return Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.grey5,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '-',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.grey9,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '0%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.grey9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })
                    : emotionData.take(3).map((data) {
                  final emotion = data['emotion'] as String;
                  final percentage = data['percentage'] as int;
                  final color = Color(
                    int.parse((data['color'] as String).replaceFirst('#', '0xFF')),
                  );

                        return Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
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
                            textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                              ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // 중앙 게이지
              Center(
                child: SizedBox(
                  width: 320,
                  height: 160,
                  child: CustomPaint(
                    size: const Size(320, 160),
                    painter: EmotionGaugePainter(
                      positiveRatio: positiveRatio,
                      gaugeColor: isEmpty ? AppColors.grey6 : gaugeColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // 감성적인 메시지
              Center(
                child: Text(
                  _getMainMessage(),
                  style: TextStyle(
                    fontSize: 18,
                    color: isEmpty ? AppColors.grey9 : AppColors.grey12,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (!isEmpty) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${negativePercent}% 더 긍정적인 하루를 만들어주세요 💕',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.grey9,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              ] else ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '카메라가 이벤트를 감지하면 자동으로\n감정 리포트가 표시됩니다.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey9,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              
              // 하단 상세 감정 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.grey3,
                  ),
                ),
                child: isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '아직 감지된 감정 데이터가 없습니다',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : Column(
                  children: emotionData.map((data) {
                    final emotion = data['emotion'] as String;
                    final percentage = data['percentage'] as int;
                    final color = Color(
                      int.parse((data['color'] as String).replaceFirst('#', '0xFF')),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              emotion,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.grey12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 15,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
            ),
          ],
        );
      },
      loading: () => AppCards.basic(
        padding: const EdgeInsets.all(20),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

/// 반원 게이지 차트를 그리는 CustomPainter
class EmotionGaugePainter extends CustomPainter {
  final double positiveRatio; // 0.0 (완전 부정) ~ 1.0 (완전 긍정)
  final Color gaugeColor;

  EmotionGaugePainter({
    required this.positiveRatio,
    required this.gaugeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 40; // 여백을 위해 40px 감소
    final strokeWidth = 50.0; // 더 두껍게

    // 반원 호 그리기 (180도)
    // 시작 각도: 왼쪽 끝 (180도 = math.pi)
    // 끝 각도: 오른쪽 끝 (0도 = 0)
    final startAngle = math.pi; // 180도 (왼쪽)
    final sweepAngle = math.pi; // 180도 (반원)

    // 배경 호 (회색)
    final backgroundPaint = Paint()
      ..color = AppColors.grey3
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // 긍정 비율에 따른 색상 호
    final gaugePaint = Paint()
      ..color = gaugeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 긍정 비율만큼만 그리기 (왼쪽에서 오른쪽으로)
    final filledAngle = sweepAngle * positiveRatio;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      filledAngle,
      false,
      gaugePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

