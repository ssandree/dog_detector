// lib/local/analytics_cache.dart
// Hive 기반 로컬 캐시 관리
// - AnalyticsBundle 단위로 /analytics 응답 저장
// - 앱 재실행 시 캐시 로드 및 복원 지원

import 'package:hive/hive.dart';
import '../models/analytics_bundle.dart';

class AnalyticsCache {
  static const _boxName = 'analytics_bundle_box';

  // 캐시 저장
  static Future<void> saveBundle(AnalyticsBundle bundle) async {
    final box = await Hive.openBox<AnalyticsBundle>(_boxName);
    await box.put('latest', bundle);
    await box.close();
  }

  // 캐시 로드
  static Future<AnalyticsBundle?> loadBundle() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<AnalyticsBundle>(_boxName);
    }
    final box = Hive.box<AnalyticsBundle>(_boxName);
    return box.get('latest');
  }

  // 캐시 초기화
  static Future<void> clear() async {
    if (Hive.isBoxOpen(_boxName)) {
      final box = Hive.box<AnalyticsBundle>(_boxName);
      await box.clear();
      await box.close();
    }
  }
}
