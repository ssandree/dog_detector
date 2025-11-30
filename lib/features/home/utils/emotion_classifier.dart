// lib/features/home/utils/emotion_classifier.dart

class EmotionClassifier {
  static const _positive = {
    'happy', 'calm', 'joyful', 'excited', 'playful',
    '행복', '평온', '활발', '기대', '즐거움', '편안', '안정',
  };

  static const _negative = {
    'anxiety', 'aggressive', 'angry', 'fear', 'sad', 'lonely', 'stressed',
    '불안', '화남', '외로움', '공포', '분노', '경계', '스트레스',
  };

  static bool isPositive(String emotion) {
    final e = emotion.toLowerCase().trim();
    if (_positive.contains(e)) return true;
    if (_negative.contains(e)) return false;

    if (_positive.any((p) => e.contains(p))) return true;
    if (_negative.any((n) => e.contains(n))) return false;

    return false;
  }
}
