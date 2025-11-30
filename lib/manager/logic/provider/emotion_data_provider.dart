// lib/manager/provider/emotion_data_provider.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'event_provider.dart';
import '../../../features/pet/application/current_pet_provider.dart';
import '../../manager_home/utils/emotion_mapper.dart';

class EmotionDataResult {
  final List<Map<String, dynamic>> emotionData;
  final double positiveRatio;

  const EmotionDataResult({
    required this.emotionData,
    required this.positiveRatio,
  });
}

final emotionDataProvider =
    FutureProvider.autoDispose.family<EmotionDataResult, DateTime>((ref, date) async {
  
  final pet = ref.watch(currentPetProvider);
  final petId = pet?.petId;

  if (petId == null) {
    return const EmotionDataResult(
      emotionData: [],
      positiveRatio: 0.5,
    );
  }

  final request = DailyEventRequest(
    petId: petId,
    date: date,
  );

  final dailyEvents = await ref.watch(
    dailyEventsProvider(request).future,
  );

  final events = dailyEvents.events
      .where((e) => (e.finalEmotion ?? '').trim().isNotEmpty)
      .toList();

  if (events.isEmpty) {
    return const EmotionDataResult(
      emotionData: [],
      positiveRatio: 0.5,
    );
  }

  final emotionList = events.map((e) => e.finalEmotion!.trim()).toList();

  final countMap = EmotionMapper.countEmotions(emotionList);
  final ratio = EmotionMapper.positiveRatio(countMap);

  final total = events.length;

  final mapped = countMap.entries.map((entry) {
    final percentage = ((entry.value / total) * 100).round();
    final color = EmotionMapper.resolveColor(entry.key);

    return {
      'emotion': entry.key,
      'percentage': percentage,
      'color': color,
    };
  }).toList();

  mapped.sort((a, b) {
    return (b['percentage'] as int).compareTo(a['percentage'] as int);
  });

  return EmotionDataResult(
    emotionData: mapped,
    positiveRatio: ratio,
  );
});
