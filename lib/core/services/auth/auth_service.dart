import '../../../models/auth_info.dart';

abstract class AuthService {
  Future<AuthInfo> login(String email, String password);
  Future<AuthInfo> signup(String email, String password, String name);
  Future<void> logout();
  Future<AuthInfo> refreshToken(String refreshToken);
  Future<AuthInfo?> loadStoredAuthInfo();
}

