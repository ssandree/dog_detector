// lib/features/home/utils/emotion_mapper.dart

import 'emotion_classifier.dart';
import 'emotion_color_map.dart';

class EmotionMapper {
  static Map<String, int> countEmotions(List<String> emotions) {
    final map = <String, int>{};
    for (final e in emotions) {
      map[e] = (map[e] ?? 0) + 1;
    }
    return map;
  }

  static double positiveRatio(Map<String, int> map) {
    int total = map.values.fold(0, (p, c) => p + c);
    if (total == 0) return 0.5;

    int positiveCount = map.entries
        .where((e) => EmotionClassifier.isPositive(e.key))
        .fold(0, (p, e) => p + e.value);

    return positiveCount / total;
  }

  static String resolveColor(String emotion) {
    final raw = emotion.trim();
    final lower = raw.toLowerCase();

    String? color = EmotionColorMap.base[raw] ?? EmotionColorMap.base[lower];

    if (color != null) return color;

    for (final part in raw.split('/')) {
      final key = part.trim();
      color = EmotionColorMap.base[key] ??
          EmotionColorMap.base[key.toLowerCase()] ??
          EmotionColorMap.keywords[key] ??
          EmotionColorMap.keywords[key.toLowerCase()];

      if (color != null) return color;
    }

    for (final k in EmotionColorMap.keywords.keys) {
      if (raw.contains(k) || lower.contains(k.toLowerCase())) {
        return EmotionColorMap.keywords[k]!;
      }
    }

    return '#808080';
  }
}
