// lib/features/auth/providers/auth_controller.dart

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/storage/app_prefs_provider.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class AuthState {
  final bool isLoading;
  final bool saveId;
  final bool autoLogin;
  final String? savedId;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.saveId = false,
    this.autoLogin = false,
    this.savedId,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? saveId,
    bool? autoLogin,
    String? savedId,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      saveId: saveId ?? this.saveId,
      autoLogin: autoLogin ?? this.autoLogin,
      savedId: savedId ?? this.savedId,
      errorMessage: errorMessage,
    );
  }

  factory AuthState.initial() => const AuthState();
}

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final prefs = await ref.watch(appPrefsProvider.future);

    return AuthState(
      savedId: prefs.savedId,
      saveId: prefs.savedId != null && prefs.savedId!.isNotEmpty,
      autoLogin: prefs.autoLogin,
    );
  }

  Dio get _dio => ref.read(dioProvider);
  SecureStorageService get _secure =>
      ref.read(secureStorageServiceProvider);

  AppPrefsNotifier get _prefsNotifier =>
      ref.read(appPrefsProvider.notifier);

  void toggleSaveId() {
    state = AsyncData(
      state.value!.copyWith(saveId: !state.value!.saveId),
    );
  }

  void toggleAutoLogin() {
    state = AsyncData(
      state.value!.copyWith(autoLogin: !state.value!.autoLogin),
    );
  }

  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    state = AsyncData(
      state.value!.copyWith(isLoading: true, errorMessage: null),
    );

    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          "grant_type": "password",
          "username": username,
          "password": password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final data = response.data;

      final token = data['access_token'] ??
          data['token'] ??
          data['detail']?['token'];

      if (token == null || token is! String || token.isEmpty) {
        state = AsyncData(
          state.value!.copyWith(
            isLoading: false,
            errorMessage: '서버 응답이 올바르지 않습니다.',
          ),
        );
        return false;
      }

      await _secure.writeToken(token);

      await _handlePostLogin(username);

      state = AsyncData(
        state.value!.copyWith(isLoading: false),
      );
      return true;

    } on DioException catch (e) {
      String msg = "아이디 또는 비밀번호를 확인해 주세요.";
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        if (data['detail'] is String) {
          msg = data['detail'];
        } else if (data['detail'] is List) {
          final List errors = data['detail'];
          if (errors.isNotEmpty && errors.first is Map) {
            msg = errors.first['msg'] ?? msg;
          } else if (errors.isNotEmpty) {
            msg = errors.first.toString();
          }
        }
      } else if (data is String) {
        msg = data;
      }

      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: msg,
        ),
      );
      return false;
    } catch (_) {
      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: '로그인 실패. 네트워크 상태를 확인하세요.',
        ),
      );
      return false;
    }
  }

  Future<void> _handlePostLogin(String username) async {
    final auth = state.value!;

    if (auth.saveId) {
      await _prefsNotifier.setSavedId(username);
    } else {
      await _prefsNotifier.setSavedId(null);
    }

    await _prefsNotifier.setAutoLogin(auth.autoLogin);
  }

  /// 로그아웃 처리
  Future<void> signOut() async {
    // 토큰 삭제
    await _secure.deleteToken();
    
    // 자동 로그인 해제
    await _prefsNotifier.setAutoLogin(false);
    
    // 상태 초기화
    state = AsyncData(AuthState.initial());
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
