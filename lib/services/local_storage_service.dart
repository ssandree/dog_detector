import 'package:shared_preferences/shared_preferences.dart';
import '../core/exceptions.dart';

/// 로컬 저장소 서비스
/// SharedPreferences를 사용하여 데이터를 저장/조회합니다.
class LocalStorageService {
  static const String _keyAppMode = 'app_mode';
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyAlarmSettings = 'alarm_settings';

  /// SharedPreferences 인스턴스 가져오기
  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  /// 앱 모드 저장
  Future<void> saveAppMode(String mode) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_keyAppMode, mode);
    } catch (e) {
      throw DataException(
        '앱 모드를 저장하는데 실패했습니다',
        e,
      );
    }
  }

  /// 앱 모드 조회
  Future<String?> getAppMode() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_keyAppMode);
    } catch (e) {
      throw DataException(
        '앱 모드를 불러오는데 실패했습니다',
        e,
      );
    }
  }

  /// 앱 모드 삭제
  Future<void> clearAppMode() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_keyAppMode);
    } catch (e) {
      throw DataException(
        '앱 모드를 삭제하는데 실패했습니다',
        e,
      );
    }
  }

  /// 액세스 토큰 저장
  Future<void> saveAccessToken(String token) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_keyAccessToken, token);
    } catch (e) {
      throw DataException(
        '액세스 토큰을 저장하는데 실패했습니다',
        e,
      );
    }
  }

  /// 액세스 토큰 조회
  Future<String?> getAccessToken() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_keyAccessToken);
    } catch (e) {
      throw DataException(
        '액세스 토큰을 불러오는데 실패했습니다',
        e,
      );
    }
  }

  /// 리프레시 토큰 저장
  Future<void> saveRefreshToken(String token) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_keyRefreshToken, token);
    } catch (e) {
      throw DataException(
        '리프레시 토큰을 저장하는데 실패했습니다',
        e,
      );
    }
  }

  /// 리프레시 토큰 조회
  Future<String?> getRefreshToken() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_keyRefreshToken);
    } catch (e) {
      throw DataException(
        '리프레시 토큰을 불러오는데 실패했습니다',
        e,
      );
    }
  }

  /// 인증 토큰 모두 삭제
  Future<void> clearAuthTokens() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_keyAccessToken);
      await prefs.remove(_keyRefreshToken);
    } catch (e) {
      throw DataException(
        '인증 토큰을 삭제하는데 실패했습니다',
        e,
      );
    }
  }

  /// 알림 설정 저장 (JSON 문자열)
  Future<void> saveAlarmSettings(String jsonString) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_keyAlarmSettings, jsonString);
    } catch (e) {
      throw DataException(
        '알림 설정을 저장하는데 실패했습니다',
        e,
      );
    }
  }

  /// 알림 설정 조회 (JSON 문자열)
  Future<String?> getAlarmSettings() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_keyAlarmSettings);
    } catch (e) {
      throw DataException(
        '알림 설정을 불러오는데 실패했습니다',
        e,
      );
    }
  }

  /// 알림 설정 삭제
  Future<void> clearAlarmSettings() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_keyAlarmSettings);
    } catch (e) {
      throw DataException(
        '알림 설정을 삭제하는데 실패했습니다',
        e,
      );
    }
  }

  /// 모든 데이터 삭제
  Future<void> clearAll() async {
    try {
      final prefs = await _prefs;
      await prefs.clear();
    } catch (e) {
      throw DataException(
        '저장된 데이터를 삭제하는데 실패했습니다',
        e,
      );
    }
  }
}

