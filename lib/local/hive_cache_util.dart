// lib/local/hive_cache_util.dart
// Hive 캐시 관리 유틸리티
// - 앱 전역 Hive 박스 초기화 및 데이터 삭제 처리
// - 캐시 정리, 전체 초기화, 박스 존재 여부 확인 기능 제공
// - SettingsProvider.clearCache() 등에서 직접 호출됨

import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer' as dev;

class HiveCacheUtil {
  static Future<void> initialize() async {
    await Hive.initFlutter();
  }

  static Future<void> clearBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      } else if (await Hive.boxExists(boxName)) {
        final box = await Hive.openBox(boxName);
        await box.clear();
        await box.close();
      }
      dev.log('[HiveCacheUtil] Cleared box: $boxName');
    } catch (e) {
      dev.log('[HiveCacheUtil] Failed to clear box: $boxName ($e)');
    }
  }

  // 전체 캐시 초기화
  static Future<void> clearAll() async {
    try {
      await Hive.deleteFromDisk();
      dev.log('[HiveCacheUtil] All cache cleared');
    } catch (e) {
      dev.log('[HiveCacheUtil] Failed to clear all cache: $e');
    }
  }

  static Future<bool> exists(String boxName) async {
    return Hive.boxExists(boxName);
  }
}
