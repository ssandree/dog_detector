import 'dart:convert';
import '../models/auth_info.dart';
import '../data/auth_mock.dart';
import '../services/local_storage_service.dart';
import '../core/exceptions.dart';

/// 인증 관련 비즈니스 로직을 처리하는 Service
/// 
/// 역할:
/// - 인증 API 호출 (로그인, 회원가입, 로그아웃, 토큰 갱신)
/// - Mock 데이터를 Model로 변환
/// - 에러를 적절한 Exception으로 변환
/// - 토큰 저장/조회/삭제 (SharedPreferences)
class AuthService {
  final LocalStorageService _storage;

  AuthService(this._storage);
  /// 로그인
  /// 
  /// [email]: 사용자 이메일
  /// [password]: 사용자 비밀번호
  /// 반환값: AuthInfo 객체
  /// 예외: NetworkException, AuthException, ValidationException
  Future<AuthInfo> login(String email, String password) async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션

      // Mock: 간단한 검증 (실제로는 서버에서 검증)
      if (email.isEmpty || password.isEmpty) {
        throw ValidationException('이메일과 비밀번호를 입력해주세요.');
      }

      // Mock 데이터로 로그인 처리
      // 실제로는 API 응답을 받아서 AuthInfo 생성
      final authInfo = AuthInfo.fromJson(mockUser);

      // 토큰 저장
      await _storage.saveAccessToken(authInfo.accessToken);
      await _storage.saveRefreshToken(authInfo.refreshToken);

      return authInfo;
    } on AppException {
      rethrow; // AppException은 그대로 전달
    } catch (e) {
      throw NetworkException(
        '로그인에 실패했습니다. 네트워크 연결을 확인해주세요.',
        e,
      );
    }
  }

  /// 회원가입
  /// 
  /// [email]: 사용자 이메일
  /// [password]: 사용자 비밀번호
  /// [name]: 사용자 이름
  /// 반환값: AuthInfo 객체
  /// 예외: NetworkException, AuthException, ValidationException
  Future<AuthInfo> signup(String email, String password, String name) async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션

      // Mock: 간단한 검증 (실제로는 서버에서 검증)
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw ValidationException('모든 필드를 입력해주세요.');
      }

      // Mock 데이터로 회원가입 처리
      // 실제로는 API 응답을 받아서 AuthInfo 생성
      final authInfo = AuthInfo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      // 토큰 저장
      await _storage.saveAccessToken(authInfo.accessToken);
      await _storage.saveRefreshToken(authInfo.refreshToken);

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

  /// 로그아웃
  /// 
  /// 예외: NetworkException
  Future<void> logout() async {
    try {
      // TODO: 실제 API 호출로 로그아웃 (토큰 무효화)
      await Future.delayed(const Duration(milliseconds: 300));

      // 토큰 삭제
      await _storage.clearAuthTokens();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '로그아웃에 실패했습니다.',
        e,
      );
    }
  }

  /// 토큰 갱신
  /// 
  /// [refreshToken]: 갱신에 사용할 리프레시 토큰
  /// 반환값: 새로운 AuthInfo 객체
  /// 예외: NetworkException, AuthException
  Future<AuthInfo> refreshToken(String refreshToken) async {
    try {
      // TODO: 실제 API 호출로 토큰 갱신
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock: 토큰 갱신
      // 실제로는 API 응답을 받아서 새로운 토큰으로 AuthInfo 생성
      final currentAuth = AuthInfo.fromJson(mockUser);
      final refreshedAuth = currentAuth.copyWith(
        accessToken: 'refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      // 토큰 저장
      await _storage.saveAccessToken(refreshedAuth.accessToken);
      await _storage.saveRefreshToken(refreshedAuth.refreshToken);

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

  /// 저장된 인증 정보 조회 (자동 로그인)
  /// 
  /// 반환값: 저장된 AuthInfo 객체 (없으면 null)
  /// 예외: NetworkException, DataException
  Future<AuthInfo?> loadStoredAuthInfo() async {
    try {
      final accessToken = await _storage.getAccessToken();
      final refreshToken = await _storage.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        return null;
      }

      // TODO: 실제로는 토큰 유효성 검사 API 호출
      // 현재는 토큰이 있으면 유효하다고 가정
      final isValid = await validateToken(accessToken);
      if (!isValid) {
        await _storage.clearAuthTokens();
        return null;
      }

      // Mock 데이터로 AuthInfo 생성 (실제로는 토큰에서 사용자 정보 추출)
      return AuthInfo(
        id: '1', // 실제로는 토큰에서 추출
        email: 'test@example.com', // 실제로는 토큰에서 추출
        name: '산들', // 실제로는 토큰에서 추출
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

  /// 토큰 유효성 검사
  /// 
  /// [token]: 검사할 토큰
  /// 반환값: 토큰이 유효하면 true
  /// 예외: AuthException
  Future<bool> validateToken(String token) async {
    try {
      // TODO: 실제 토큰 유효성 검사 API 호출
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock: 항상 유효하다고 가정
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
}

