import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/app_constants.dart';
import '../../../../core/widgets/app_cards.dart';
import '../../../../core/provider/current_pet_provider.dart';
import '../../../../core/service/event/event_service.dart';
import '../../../../core/service/event/mock_event_service.dart';

/// 감정 데이터 Provider
final emotionDataProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final petInfo = ref.watch(currentPetProvider);
  
  if (petInfo == null || petInfo.petId == null) {
    return [];
  }

  final service = MockEventService();
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  // 오늘의 이벤트 조회
  final events = await service.getPetEvents(
    petId: petInfo.petId!,
    skip: 0,
    limit: 100,
  );

  // 오늘의 이벤트만 필터링
  final todayEvents = events.where((event) {
    return event.startTime.isAfter(startOfDay) && 
           event.startTime.isBefore(endOfDay) &&
           event.finalEmotion != null;
  }).toList();

  if (todayEvents.isEmpty) {
    return [];
  }

  // 감정별 카운트
  final emotionCount = <String, int>{};
  for (final event in todayEvents) {
    final emotion = event.finalEmotion!;
    emotionCount[emotion] = (emotionCount[emotion] ?? 0) + 1;
  }

  // 전체 이벤트 수
  final totalCount = todayEvents.length;

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
class EmotionGaugeCard extends ConsumerWidget {
  const EmotionGaugeCard({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emotionDataAsync = ref.watch(emotionDataProvider);

    return emotionDataAsync.when(
      data: (emotionData) {
        if (emotionData.isEmpty) {
          return const SizedBox.shrink();
        }

        // 부정/긍정 감정 비율 계산
        int positiveTotal = 0;
        int negativeTotal = 0;
        int totalPercentage = 0;

        for (final data in emotionData) {
          final emotion = data['emotion'] as String;
          final percentage = data['percentage'] as int;
          totalPercentage += percentage;

          if (_isPositiveEmotion(emotion)) {
            positiveTotal += percentage;
          } else {
            negativeTotal += percentage;
          }
        }

        // 긍정 비율 계산 (0.0 ~ 1.0)
        final positiveRatio = totalPercentage > 0 
            ? positiveTotal / totalPercentage 
            : 0.5; // 데이터가 없으면 중간값

        // 색상 계산
        final gaugeColor = _calculateEmotionColor(positiveRatio);

        // 감정별 감성적인 멘트 매핑
        String _getEmotionMessage(String emotion, int percentage) {
          switch (emotion) {
            case '행복':
              return percentage >= 50 
                ? '오늘도 행복한 하루였어요! 😊'
                : '행복한 순간들이 있었어요 💕';
            case '평온':
              return percentage >= 50
                ? '평온하고 편안한 하루였어요 🕊️'
                : '차분한 시간을 보냈어요 ✨';
            case '활발':
              return percentage >= 50
                ? '에너지 넘치는 하루였어요! 🎉'
                : '활기찬 모습을 보였어요 🌟';
            case '불안':
              return percentage >= 50
                ? '조금 불안해 보였어요, 안아주세요 🤗'
                : '가끔 불안한 순간이 있었어요 💙';
            case '화남':
              return percentage >= 50
                ? '화가 난 것 같아요, 따뜻하게 위로해주세요 💚'
                : '조금 화가 난 모습이었어요 🫂';
            case '외로움':
              return percentage >= 50
                ? '외로워 보였어요, 함께해주세요 💜'
                : '가끔 외로워 보였어요, 관심을 주세요 💛';
            default:
              return '$emotion의 감정이었어요';
          }
        }

        final positivePercent = (positiveRatio * 100).round();
        final negativePercent = ((1 - positiveRatio) * 100).round();
        
        // 감성적인 메시지 생성
        String _getMainMessage() {
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

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
              // 상단 헤더: 제목과 모아보기 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.help_outline,
                        color: AppColors.grey12,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '오늘의 감정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey12,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // 하단 네비게이션의 캘린더 탭으로 이동
                      // MainNavigation의 인덱스를 변경하기 위해 이벤트를 발생시킬 수 없으므로
                      // 사용자에게 하단 네비게이션을 사용하도록 안내하거나
                      // 간단히 무시 (실제로는 하단 네비게이션을 통해 이동)
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: AppColors.beige3.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      '모아보기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 큰 숫자 표시: 긍정/부정 비율
              Center(
                child: Text(
                  '$positivePercent / 100',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey12,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '긍정적인 감정',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.grey9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 작은 원형 인디케이터들 (감정별)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: emotionData.take(3).map((data) {
                  final emotion = data['emotion'] as String;
                  final percentage = data['percentage'] as int;
                  final color = Color(
                    int.parse((data['color'] as String).replaceFirst('#', '0xFF')),
                  );
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${emotion.substring(0, 1)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // 중앙 게이지와 강아지 이모지
              Center(
                child: SizedBox(
                  width: 320,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 반원 게이지 차트
                      CustomPaint(
                        size: const Size(320, 160),
                        painter: EmotionGaugePainter(
                          positiveRatio: positiveRatio,
                          gaugeColor: gaugeColor,
                        ),
                      ),
                      // 가운데 강아지 이모지 (게이지바와 겹치게)
                      const Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Text(
                          '🐕',
                          style: TextStyle(fontSize: 100),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // 감성적인 메시지
              Center(
                child: Text(
                  _getMainMessage(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.grey12,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
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
              const SizedBox(height: 32),
              
              // 하단 상세 감정 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.beige2.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
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

