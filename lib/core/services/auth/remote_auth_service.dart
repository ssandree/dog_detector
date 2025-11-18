import '../../../models/auth_info.dart';
import 'auth_service.dart';

class RemoteAuthService implements AuthService {
  @override
  Future<AuthInfo> login(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<AuthInfo> signup(String email, String password, String name) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Future<AuthInfo> refreshToken(String refreshToken) {
    throw UnimplementedError();
  }

  @override
  Future<AuthInfo?> loadStoredAuthInfo() {
    throw UnimplementedError();
  }
}

