import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/local_storage_service.dart';

/// 앱 모드 열거형
enum AppMode {
  /// 캠 모드 - 실시간 감정 분석
  camera,

  /// 매니저 모드 - 데이터 관리 및 분석
  manager,

  /// 모드 미선택 상태
  none,
}

/// 앱 모드 상태를 관리하는 Notifier
/// 
/// 역할:
/// - 선택된 모드 상태 관리
/// - 모드 변경 시 UI 자동 업데이트
/// - 모드 상태 저장/복원 (SharedPreferences)
class AppModeNotifier extends Notifier<AppMode> {
  late final LocalStorageService _storage;

  @override
  AppMode build() {
    _storage = ref.watch(localStorageServiceProvider);
    // 초기화 시 저장된 모드 로드
    _loadSavedMode();
    return AppMode.none;
  }

  /// 저장된 모드 로드
  /// SharedPreferences에서 저장된 모드를 불러옵니다.
  Future<void> _loadSavedMode() async {
    try {
      final savedModeString = await _storage.getAppMode();
      if (savedModeString != null) {
        final savedMode = AppMode.values.firstWhere(
          (mode) => mode.name == savedModeString,
          orElse: () => AppMode.none,
        );
        if (savedMode != AppMode.none) {
          state = savedMode;
        }
      }
    } catch (e) {
      // 에러 발생 시 기본값(none) 유지
    }
  }

  /// 모드 설정
  /// 
  /// [mode]: 설정할 모드
  Future<void> setMode(AppMode mode) async {
    try {
      state = mode;
      if (mode == AppMode.none) {
        await _storage.clearAppMode();
      } else {
        await _storage.saveAppMode(mode.name);
      }
    } catch (e) {
      // 에러 발생 시에도 상태는 변경
      state = mode;
    }
  }

  /// 캠 모드로 설정
  Future<void> setCameraMode() async {
    await setMode(AppMode.camera);
  }

  /// 매니저 모드로 설정
  Future<void> setManagerMode() async {
    await setMode(AppMode.manager);
  }

  /// 모드 초기화 (모드 선택 화면으로 돌아갈 때 사용)
  Future<void> resetMode() async {
    await setMode(AppMode.none);
  }

  /// 현재 모드가 특정 모드인지 확인
  bool isMode(AppMode mode) {
    return state == mode;
  }

  /// 모드가 선택되었는지 확인
  bool get isModeSelected {
    return state != AppMode.none;
  }
}

/// LocalStorageService Provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// 앱 모드 상태를 관리하는 Provider
final appModeProvider = NotifierProvider<AppModeNotifier, AppMode>(AppModeNotifier.new);

/// 현재 선택된 모드를 쉽게 접근하기 위한 Provider
final currentAppModeProvider = Provider<AppMode>((ref) {
  return ref.watch(appModeProvider);
});

/// 모드가 선택되었는지 확인하는 Provider
final isModeSelectedProvider = Provider<bool>((ref) {
  final mode = ref.watch(appModeProvider);
  return mode != AppMode.none;
});

/// 현재 모드가 캠 모드인지 확인하는 Provider
final isCameraModeProvider = Provider<bool>((ref) {
  final mode = ref.watch(appModeProvider);
  return mode == AppMode.camera;
});

/// 현재 모드가 매니저 모드인지 확인하는 Provider
final isManagerModeProvider = Provider<bool>((ref) {
  final mode = ref.watch(appModeProvider);
  return mode == AppMode.manager;
});

