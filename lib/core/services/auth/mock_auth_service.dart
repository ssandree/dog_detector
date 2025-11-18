import '../../../data/auth_mock.dart';
import '../../../models/auth_info.dart';
import '../../exceptions.dart';
import '../../storage/local_storage_keys.dart';
import '../../storage/local_storage_repository.dart';
import 'auth_service.dart';

class MockAuthService implements AuthService {
  final LocalStorageRepository _storage;

  MockAuthService(this._storage);

  @override
  Future<AuthInfo> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw ValidationException('이메일과 비밀번호를 입력해주세요.');
      }

      await Future.delayed(const Duration(milliseconds: 400));

      final authInfo = AuthInfo.fromJson(mockUser);

      await _saveAuthTokens(authInfo);

      return authInfo;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '로그인에 실패했습니다. 네트워크 연결을 확인해주세요.',
        e,
      );
    }
  }

  @override
  Future<AuthInfo> signup(String email, String password, String name) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw ValidationException('모든 필드를 입력해주세요.');
      }

      await Future.delayed(const Duration(milliseconds: 600));

      final authInfo = AuthInfo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      await _saveAuthTokens(authInfo);

      return authInfo;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '회원가입에 실패했습니다. 네트워크 연결을 확인해주세요.',
        e,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      await _clearAuthTokens();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '로그아웃에 실패했습니다.',
        e,
      );
    }
  }

  @override
  Future<AuthInfo> refreshToken(String refreshToken) async {
    try {
      await Future.delayed(const Duration(milliseconds: 250));

      final currentAuth = AuthInfo.fromJson(mockUser);
      final refreshedAuth = currentAuth.copyWith(
        accessToken: 'refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      await _saveAuthTokens(refreshedAuth);

      return refreshedAuth;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(
        '토큰 갱신에 실패했습니다. 다시 로그인해주세요.',
        e,
      );
    }
  }

  @override
  Future<AuthInfo?> loadStoredAuthInfo() async {
    try {
      final accessToken = await _storage.loadString(LocalStorageKeys.accessToken);
      final refreshToken = await _storage.loadString(LocalStorageKeys.refreshToken);

      if (accessToken == null || refreshToken == null) {
        return null;
      }

      final isValid = await _validateToken(accessToken);
      if (!isValid) {
        await _clearAuthTokens();
        return null;
      }

      return AuthInfo(
        id: '1',
        email: 'test@example.com',
        name: '산들',
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DataException(
        '저장된 인증 정보를 불러오는데 실패했습니다.',
        e,
      );
    }
  }

  Future<bool> _validateToken(String token) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(
        '토큰 검증에 실패했습니다.',
        e,
      );
    }
  }
  Future<void> _saveAuthTokens(AuthInfo authInfo) async {
    await _storage.saveString(LocalStorageKeys.accessToken, authInfo.accessToken);
    await _storage.saveString(LocalStorageKeys.refreshToken, authInfo.refreshToken);
  }

  Future<void> _clearAuthTokens() async {
    await _storage.remove(LocalStorageKeys.accessToken);
    await _storage.remove(LocalStorageKeys.refreshToken);
  }
}

