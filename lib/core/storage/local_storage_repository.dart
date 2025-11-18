import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../exceptions.dart';

class LocalStorageRepository {
  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<void> saveString(String key, String value) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(key, value);
    } catch (e) {
      throw DataException('데이터를 저장하는데 실패했습니다', e);
    }
  }

  Future<String?> loadString(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.getString(key);
    } catch (e) {
      throw DataException('데이터를 불러오는데 실패했습니다', e);
    }
  }

  Future<void> saveJson(String key, Map<String, dynamic> json) async {
    await saveString(key, jsonEncode(json));
  }

  Future<Map<String, dynamic>?> loadJson(String key) async {
    try {
      final raw = await loadString(key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw const FormatException('JSON 형식이 올바르지 않습니다');
    } on FormatException catch (e) {
      throw DataException('저장된 데이터를 파싱하는데 실패했습니다', e);
    }
  }

  Future<void> remove(String key) async {
    try {
      final prefs = await _prefs;
      await prefs.remove(key);
    } catch (e) {
      throw DataException('저장된 데이터를 삭제하는데 실패했습니다', e);
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await _prefs;
      await prefs.clear();
    } catch (e) {
      throw DataException('모든 저장된 데이터를 삭제하는데 실패했습니다', e);
    }
  }
}

