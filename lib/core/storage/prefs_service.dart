// lib/core/storage/prefs_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  PrefsService._();
  static final PrefsService _instance = PrefsService._();
  factory PrefsService() => _instance;

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _sp {
    final p = _prefs;
    if (p == null) throw Exception("PrefsService not initialized");
    return p;
  }

  static const _keyHasSeenOnboarding = "has_seen_onboarding";
  static const _keySavedId = "saved_id";
  static const _keyAutoLogin = "auto_login";
  static const _keyMode = "app_mode";

  bool getHasSeenOnboarding() => _sp.getBool(_keyHasSeenOnboarding) ?? false;
  String? getSavedId() => _sp.getString(_keySavedId);
  bool getAutoLogin() => _sp.getBool(_keyAutoLogin) ?? false;
  String? getMode() => _sp.getString(_keyMode);

  Future<void> setHasSeenOnboarding(bool v) async =>
      _sp.setBool(_keyHasSeenOnboarding, v);

  Future<void> setSavedId(String? id) async {
    if (id == null) {
      await _sp.remove(_keySavedId);
    } else {
      await _sp.setString(_keySavedId, id);
    }
  }

  Future<void> setAutoLogin(bool v) async =>
      _sp.setBool(_keyAutoLogin, v);

  Future<void> setMode(String? m) async {
    if (m == null) {
      await _sp.remove(_keyMode);
    } else {
      await _sp.setString(_keyMode, m);
    }
  }
}
