import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../logic/model/event_info.dart';
import '../../logic/provider/event_provider.dart';
import '../../../../core/widgets/app_cards.dart';
import '../../manager_home/utils/emotion_classifier.dart';
import '../../manager_home/utils/emotion_color_map.dart';

class RecentEmotionPanel extends ConsumerWidget {
  final int petId;
  const RecentEmotionPanel({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(
      petEventsProvider(PetEventsRequest(petId: petId, limit: 20)),
    );

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return _buildEmptyCard();
        }

        final latest = events.first;
        final recentItems = events.take(3).toList();

        // 24시간 이내인지 확인
        final now = DateTime.now();
        final timeDiff = now.difference(latest.startTime);
        final isWithin24Hours = timeDiff.inHours < 24;

        // 24시간 이상 전이면 날짜/시간 메시지만 표시
        if (!isWithin24Hours) {
          final dateStr = DateFormat('yy-MM-dd').format(latest.startTime);
          final hourStr = latest.startTime.hour.toString();
          return _buildDateMessageCard(dateStr, hourStr);
        }

        // finalEmotion이 있으면 표시 (analysisStatus와 무관하게)
        final currentInfo = _emotionInfo(latest.finalEmotion);
        final delayText = _formatDelay(latest.startTime);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 현재 감정 카드
            AppCards.basic(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '현재 감정',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.grey12,
                    ),
                  ),
                  AppConstants.h8,
                  const Text(
                    '※ 감정 분석은 최대 1분 지연될 수 있어요.',
                    style: TextStyle(fontSize: 12, color: AppColors.grey7),
                  ),
                  AppConstants.h12,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(currentInfo.emoji, style: const TextStyle(fontSize: 42)),
                      AppConstants.w12,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentInfo.label,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey12,
                            ),
                          ),
                          Text(
                            '최근 분석됨 ($delayText)',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grey7,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppConstants.h16,
            // 최근 분석된 감정 카드
            AppCards.basic(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '최근 분석된 감정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey12,
                    ),
                  ),
                  AppConstants.h12,
                  ...recentItems.map(_RecentEmotionRow.new),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => AppCards.basic(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _loadingBar(width: 140),
            AppConstants.h12,
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.grey2,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                AppConstants.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _loadingBar(),
                      AppConstants.h8,
                      _loadingBar(width: 120),
                    ],
                  ),
                ),
              ],
            ),
            AppConstants.h20,
            _loadingBar(width: 160),
            AppConstants.h12,
            _loadingBar(),
            AppConstants.h8,
            _loadingBar(),
          ],
        ),
      ),
      error: (error, _) => AppCards.basic(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '감정 정보를 불러올 수 없어요',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.errorRed,
              ),
            ),
            AppConstants.h8,
            Text(
              '$error',
              style: const TextStyle(color: AppColors.grey7, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return AppCards.basic(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '최근 감정 데이터가 없습니다.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.grey9,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '카메라가 새로운 이벤트를 감지하면 자동으로 감정 요약이 표시됩니다.',
            style: TextStyle(fontSize: 13, color: AppColors.grey7),
          ),
        ],
      ),
    );
  }

  Widget _buildDateMessageCard(String dateStr, String hourStr) {
    return SizedBox(
      width: double.infinity,
      child: AppCards.basic(
        child: Text(
          '최근 분석은 $dateStr, ${hourStr}시입니다',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.grey12,
          ),
        ),
      ),
    );
  }

  _EmotionDisplay _emotionInfo(String? emotion) {
    if (emotion == null || emotion.trim().isEmpty) {
      return const _EmotionDisplay('🤔', '분석 중');
    }
    
    // EmotionMapper.resolveColor()의 로직을 활용하여 감정 타입 추출
    final emotionType = _normalizeEmotion(emotion);
    
    // 감정 타입을 이모지와 라벨로 매핑
    return _emotionTypeToDisplay(emotionType);
  }

  /// EmotionMapper.resolveColor()의 로직을 활용하여 감정을 정규화
  String _normalizeEmotion(String emotion) {
    final raw = emotion.trim();
    final lower = raw.toLowerCase();
    
    // 직접 매칭 (EmotionColorMap.base와 keywords 활용)
    if (EmotionColorMap.base.containsKey(raw) || 
        EmotionColorMap.base.containsKey(lower) ||
        EmotionColorMap.keywords.containsKey(raw) ||
        EmotionColorMap.keywords.containsKey(lower)) {
      return raw;
    }
    
    // `/`로 구분된 복합 감정 처리
    if (raw.contains('/')) {
      for (final part in raw.split('/')) {
        final key = part.trim();
        final keyLower = key.toLowerCase();
        
        if (EmotionColorMap.base.containsKey(key) ||
            EmotionColorMap.base.containsKey(keyLower) ||
            EmotionColorMap.keywords.containsKey(key) ||
            EmotionColorMap.keywords.containsKey(keyLower)) {
          return key;
        }
      }
    }
    
    // 부분 문자열 매칭
    for (final k in EmotionColorMap.keywords.keys) {
      if (raw.contains(k) || lower.contains(k.toLowerCase())) {
        return k;
      }
    }
    
    for (final k in EmotionColorMap.base.keys) {
      if (raw.contains(k) || lower.contains(k.toLowerCase())) {
        return k;
      }
    }
    
    return raw;
  }

  /// 정규화된 감정 타입을 이모지와 라벨로 변환
  _EmotionDisplay _emotionTypeToDisplay(String emotionType) {
    final normalized = emotionType.toLowerCase().trim();
    
    // 행복 관련
    if (normalized == 'happy' || normalized == '행복') {
      return const _EmotionDisplay('😄', '행복');
    }
    
    // 평온/편안/안정 관련
    if (normalized == 'calm' || normalized == '평온' || 
        normalized == '편안' || normalized == '안정') {
      return const _EmotionDisplay('🙂', '평온');
    }
    
    // 불안 관련
    if (normalized == 'anxious' || normalized == 'anxiety' || 
        normalized == '불안') {
      return const _EmotionDisplay('😟', '약간 불안');
    }
    
    // 슬픔 관련
    if (normalized == 'sad' || normalized == '슬픔') {
      return const _EmotionDisplay('😢', '슬픔');
    }
    
    // 화남 관련
    if (normalized == 'angry' || normalized == 'aggressive' || 
        normalized == '화남' || normalized == '공격성') {
      return const _EmotionDisplay('😠', '화남');
    }
    
    // 중립
    if (normalized == 'neutral') {
      return const _EmotionDisplay('😐', '중립');
    }
    
    // 매칭되지 않는 경우
    return const _EmotionDisplay('🤔', '분석 중');
  }

  String _formatDelay(DateTime startTime) {
    final diff = DateTime.now().difference(startTime);
    if (diff.inSeconds < 5) {
      return '방금 전';
    }
    if (diff.inMinutes < 1) {
      return '${diff.inSeconds}초 전';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}분 전';
    }
    return '${diff.inHours}시간 전';
  }

  Widget _loadingBar({double? width}) {
    return Container(
      width: width ?? double.infinity,
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.grey2,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _RecentEmotionRow extends StatelessWidget {
  final EventInfo event;
  const _RecentEmotionRow(this.event);

  @override
  Widget build(BuildContext context) {
    // finalEmotion이 있으면 표시 (analysisStatus와 무관하게)
    final info = _emotionInfo(event.finalEmotion);
    final timeLabel = DateFormat('HH:mm').format(event.startTime);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '[$timeLabel]',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.grey9,
            ),
          ),
          AppConstants.w8,
          Text(
            '${info.emoji} ${info.label}',
            style: const TextStyle(fontSize: 15, color: AppColors.grey12),
          ),
        ],
      ),
    );
  }

  static _EmotionDisplay _emotionInfo(String? emotion) {
    if (emotion == null || emotion.trim().isEmpty) {
      return const _EmotionDisplay('🤔', '분석 중');
    }
    
    // EmotionMapper.resolveColor()의 로직을 활용하여 감정 타입 추출
    final emotionType = _normalizeEmotion(emotion);
    
    // 감정 타입을 이모지와 라벨로 매핑
    return _emotionTypeToDisplay(emotionType);
  }

  /// EmotionMapper.resolveColor()의 로직을 활용하여 감정을 정규화
  static String _normalizeEmotion(String emotion) {
    final raw = emotion.trim();
    final lower = raw.toLowerCase();
    
    // 직접 매칭 (EmotionColorMap.base와 keywords 활용)
    if (EmotionColorMap.base.containsKey(raw) || 
        EmotionColorMap.base.containsKey(lower) ||
        EmotionColorMap.keywords.containsKey(raw) ||
        EmotionColorMap.keywords.containsKey(lower)) {
      return raw;
    }
    
    // `/`로 구분된 복합 감정 처리
    if (raw.contains('/')) {
      for (final part in raw.split('/')) {
        final key = part.trim();
        final keyLower = key.toLowerCase();
        
        if (EmotionColorMap.base.containsKey(key) ||
            EmotionColorMap.base.containsKey(keyLower) ||
            EmotionColorMap.keywords.containsKey(key) ||
            EmotionColorMap.keywords.containsKey(keyLower)) {
          return key;
        }
      }
    }
    
    // 부분 문자열 매칭
    for (final k in EmotionColorMap.keywords.keys) {
      if (raw.contains(k) || lower.contains(k.toLowerCase())) {
        return k;
      }
    }
    
    for (final k in EmotionColorMap.base.keys) {
      if (raw.contains(k) || lower.contains(k.toLowerCase())) {
        return k;
      }
    }
    
    return raw;
  }

  /// 정규화된 감정 타입을 이모지와 라벨로 변환
  static _EmotionDisplay _emotionTypeToDisplay(String emotionType) {
    final normalized = emotionType.toLowerCase().trim();
    
    // 행복 관련
    if (normalized == 'happy' || normalized == '행복') {
      return const _EmotionDisplay('😊', '행복');
    }
    
    // 평온/편안/안정 관련
    if (normalized == 'calm' || normalized == '평온' || 
        normalized == '편안' || normalized == '안정') {
      return const _EmotionDisplay('🙂', '평온');
    }
    
    // 불안 관련
    if (normalized == 'anxious' || normalized == 'anxiety' || 
        normalized == '불안') {
      return const _EmotionDisplay('😟', '약간 불안');
    }
    
    // 슬픔 관련
    if (normalized == 'sad' || normalized == '슬픔') {
      return const _EmotionDisplay('😢', '슬픔');
    }
    
    // 화남 관련
    if (normalized == 'angry' || normalized == 'aggressive' || 
        normalized == '화남' || normalized == '공격성') {
      return const _EmotionDisplay('😠', '화남');
    }
    
    // 중립
    if (normalized == 'neutral') {
      return const _EmotionDisplay('😐', '중립');
    }
    
    // 매칭되지 않는 경우
    return const _EmotionDisplay('🤔', '분석 중');
  }
}

class _EmotionDisplay {
  final String emoji;
  final String label;
  const _EmotionDisplay(this.emoji, this.label);
}
