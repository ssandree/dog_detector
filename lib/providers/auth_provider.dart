import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/auth_info.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

/// 인증 상태를 관리하는 Notifier
/// 
/// 역할:
/// - UI 상태 관리 (AsyncValue)
/// - Service를 호출하여 인증 처리
/// - 상태 변경 시 UI 자동 업데이트
class AuthNotifier extends Notifier<AsyncValue<AuthInfo?>> {
  late final AuthService _authService;

  @override
  AsyncValue<AuthInfo?> build() {
    _authService = ref.watch(authServiceProvider);
    // 초기화 시 저장된 인증 정보 로드 (자동 로그인)
    _loadAuthInfo();
    return const AsyncValue.data(null);
  }

  /// 저장된 인증 정보 로드 (자동 로그인)
  /// Service를 호출하여 저장된 인증 정보를 확인합니다.
  Future<void> _loadAuthInfo() async {
    try {
      final authInfo = await _authService.loadStoredAuthInfo();
      if (authInfo != null) {
        state = AsyncValue.data(authInfo);
      }
    } catch (e, stackTrace) {
      // 자동 로그인 실패는 에러로 처리하지 않음 (로그인하지 않은 상태로 유지)
      state = const AsyncValue.data(null);
    }
  }

  /// 로그인
  /// Service를 호출하여 로그인 처리
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final authInfo = await _authService.login(email, password);
      state = AsyncValue.data(authInfo);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 회원가입
  /// Service를 호출하여 회원가입 처리
  Future<void> signup(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final authInfo = await _authService.signup(email, password, name);
      state = AsyncValue.data(authInfo);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 로그아웃
  /// Service를 호출하여 로그아웃 처리
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authService.logout();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      // 로그아웃 실패해도 상태는 null로 설정
      state = const AsyncValue.data(null);
    }
  }

  /// 토큰 갱신
  /// Service를 호출하여 토큰 갱신 처리
  Future<void> refreshToken() async {
    final currentAuth = state.value;
    if (currentAuth == null) return;

    try {
      final refreshedAuth = await _authService.refreshToken(currentAuth.refreshToken);
      state = AsyncValue.data(refreshedAuth);
    } catch (e, stackTrace) {
      // 토큰 갱신 실패 시 로그아웃 처리
      state = AsyncValue.error(e, stackTrace);
      await logout();
    }
  }
}

/// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return AuthService(storage);
});

/// 인증 상태를 관리하는 Provider
final authProvider = NotifierProvider<AuthNotifier, AsyncValue<AuthInfo?>>(AuthNotifier.new);

/// 현재 로그인 상태를 쉽게 접근하기 위한 Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.value != null;
});

/// 현재 사용자 정보를 쉽게 접근하기 위한 Provider
final currentUserProvider = Provider<AuthInfo?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.value;
});

