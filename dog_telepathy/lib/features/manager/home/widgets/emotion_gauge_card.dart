import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/provider/current_pet_provider.dart';
import '../../../../core/provider/event_provider.dart';
import '../../../../core/widgets/app_cards.dart';

/// 감정을 긍정/부정으로 분류하는 헬퍼 함수
bool _isPositiveEmotionHelper(String emotion) {
  final normalized = emotion.toLowerCase().trim();
  
  // 긍정 감정 세트 (영어 + 한글)
  const positiveEmotions = {
    'happy', 'calm', 'joyful', 'excited', 'playful',
    '행복', '평온', '활발', '기대', '즐거움', '편안',
  };
  
  // 부정 감정 세트 (영어 + 한글)
  const negativeEmotions = {
    'anxiety', 'aggressive', 'angry', 'fear', 'sad', 'lonely', 'stressed',
    '불안', '화남', '외로움', '공포', '분노', '경계', '스트레스',
  };
  
  // 정확한 매칭 먼저 확인
  if (positiveEmotions.contains(normalized) || positiveEmotions.contains(emotion)) {
    return true;
  }
  
  if (negativeEmotions.contains(normalized) || negativeEmotions.contains(emotion)) {
    return false;
  }
  
  // 부분 매칭 (예: "happy_high" 같은 경우)
  for (final positive in positiveEmotions) {
    if (normalized.contains(positive) || emotion.contains(positive)) {
      return true;
    }
  }
  
  for (final negative in negativeEmotions) {
    if (normalized.contains(negative) || emotion.contains(negative)) {
      return false;
    }
  }
  
  // 기본값은 중립 (부정으로 처리)
  return false;
}

/// 감정 데이터 결과 모델
class EmotionDataResult {
  final List<Map<String, dynamic>> emotionData;
  final double positiveRatio;

  EmotionDataResult({
    required this.emotionData,
    required this.positiveRatio,
  });
}

/// 감정 데이터 Provider (날짜 파라미터 포함)
final emotionDataProvider = FutureProvider.autoDispose
    .family<EmotionDataResult, DateTime>((ref, date) async {
  final petInfo = ref.watch(currentPetProvider);
  final petId = petInfo?.petId;
  if (petId == null) {
    return EmotionDataResult(
      emotionData: <Map<String, dynamic>>[],
      positiveRatio: 0.5,
    );
  }

  final request = DailyEventRequest(
    petId: petId,
    date: date,
  );

  final dailyEvents = await ref.watch(dailyEventsProvider(request).future);
  final events = dailyEvents.events
      .where((event) => event.finalEmotion != null)
      .toList();

  if (events.isEmpty) {
    return EmotionDataResult(
      emotionData: <Map<String, dynamic>>[],
      positiveRatio: 0.5,
    );
  }

  // 감정별 카운트
  final emotionCount = <String, int>{};
  int positiveCount = 0;
  int totalCount = events.length;

  for (final event in events) {
    final emotion = event.finalEmotion!;
    emotionCount[emotion] = (emotionCount[emotion] ?? 0) + 1;
    if (_isPositiveEmotionHelper(emotion)) {
      positiveCount++;
    }
  }

  // 긍정 비율 계산 (실제 이벤트 수 기반)
  final positiveRatio = totalCount > 0 ? positiveCount / totalCount : 0.5;

  // 감정별 색상 매핑 (영어 + 한글 지원)
  final emotionColors = {
    // 긍정 감정
    'happy': '#FFD700',
    '행복': '#FFD700',
    'calm': '#87CEEB',
    '평온': '#87CEEB',
    '활발': '#FF6B6B',
    // 부정 감정
    'anxiety': '#FFA500',
    '불안': '#FFA500',
    'aggressive': '#FF4500',
    'angry': '#FF4500',
    '화남': '#FF4500',
    'fear': '#9370DB',
    '외로움': '#9370DB',
  };

  // 감정별 비율 계산 (퍼센트)
  final emotionData = emotionCount.entries.map((entry) {
    final percentage = ((entry.value / totalCount) * 100).round();
    final emotionKey = entry.key.toLowerCase().trim();
    // 영어/한글 모두 지원하는 색상 매핑
    final color = emotionColors[entry.key] ?? 
                  emotionColors[emotionKey] ?? 
                  '#808080';
    return {
      'emotion': entry.key,
      'percentage': percentage,
      'color': color,
    };
  }).toList();

  // 비율 순으로 정렬
  emotionData.sort((a, b) => (b['percentage'] as int).compareTo(a['percentage'] as int));

  return EmotionDataResult(
    emotionData: emotionData,
    positiveRatio: positiveRatio,
  );
});

/// 오늘 탐지된 감정 데이터 기반 게이지 차트 카드
class EmotionGaugeCard extends ConsumerStatefulWidget {
  const EmotionGaugeCard({super.key});

  @override
  ConsumerState<EmotionGaugeCard> createState() => _EmotionGaugeCardState();
}

class _EmotionGaugeCardState extends ConsumerState<EmotionGaugeCard> {
  DateTime _selectedDate = DateTime.now();

  /// 부정/긍정 비율에 따라 색상 계산 (0.0 = 빨강, 1.0 = 초록)
  Color _calculateEmotionColor(double positiveRatio) {
    // positiveRatio: 0.0 (완전 부정) ~ 1.0 (완전 긍정)
    final red = (255 * (1 - positiveRatio)).round();
    final green = (255 * positiveRatio).round();
    return Color.fromRGBO(red, green, 0, 1.0);
  }



  @override
  Widget build(BuildContext context) {
    final normalizedDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final emotionDataAsync = ref.watch(emotionDataProvider(normalizedDate));
    final petInfo = ref.watch(currentPetProvider);
    final petName = petInfo?.name ?? '';

    return emotionDataAsync.when(
      data: (data) {
        final emotionData = data.emotionData;
        final positiveRatio = data.positiveRatio;
        final isEmpty = emotionData.isEmpty;
        final positivePercent = (positiveRatio * 100).round();
        final gaugeColor = _calculateEmotionColor(positiveRatio);

        final isToday = _selectedDate.year == DateTime.now().year &&
            _selectedDate.month == DateTime.now().month &&
            _selectedDate.day == DateTime.now().day;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 카드
            Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 감정 점수 텍스트 (왼쪽 정렬)
              Text(
                isEmpty 
                  ? '${isToday ? '오늘' : '어제'} ${petName}의 기분 점수는 0점'
                  : '${isToday ? '오늘' : '어제'} ${petName}의 기분 점수는 ${positivePercent}점',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isEmpty ? AppColors.grey9 : AppColors.grey12,
                ),
              ),
              const SizedBox(height: 12),
              // 버튼
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
              const SizedBox(height: 24),
              
              // Progress Chart
              _buildProgressChart(
                progress: positiveRatio,
                score: positivePercent,
                isEmpty: isEmpty,
                color: gaugeColor,
              ),
              
              const SizedBox(height: 32),
              
              // 작은 사각 인디케이터들 (감정별) - 그래프 아래
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: isEmpty
                    ? List.generate(3, (index) {
                        return Container(
                          width: 70, // 너비 줄임
                          margin: const EdgeInsets.symmetric(horizontal: 8), // 간격 조정
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                        );
                      })
                    : emotionData.take(3).map((data) {
                  final emotion = data['emotion'] as String;
                  final percentage = data['percentage'] as int;
                  final color = Color(
                    int.parse((data['color'] as String).replaceFirst('#', '0xFF')),
                  );

                        return Container(
                          width: 85, // 너비 줄임
                          margin: const EdgeInsets.symmetric(horizontal: 8), // 간격 조정
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
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
                        );
                }).toList(),
              ),
              const SizedBox(height: 24)
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

  /// Progress Chart 위젯 (progress bar + 인덱스)
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
          final progressWidth = progressValue; // 0.0 ~ 1.0
          
          // 인덱스 위치 계산 (progress bar의 왼쪽 끝부터 시작)
          final indicatorLeft = progressValue == 0.0
              ? 0.0
              : (barWidth * progressValue) - 30; // 인덱스 중앙이 progress 위치에 오도록
          
          return Stack(
            children: [
              // Progress Bar
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
                    child: Stack(
                      children: [
                        // 배경 (회색)
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: AppColors.grey3,
                        ),
                        // 채워진 부분 (그라데이션)
                        FractionallySizedBox(
                          widthFactor: progressWidth,
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
                      ],
                    ),
                  ),
                ),
              ),
              // 인덱스 (원형 + 점수)
              Positioned(
                left: indicatorLeft.clamp(0.0, barWidth - 60),
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
                        color: (isEmpty ? AppColors.grey6 : color)
                            .withValues(alpha: 0.3),
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
}



